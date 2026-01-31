import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/shift_model/cunsultation_model.dart';
import '../../models/shift_model/expenses_model.dart';
import '../../models/shift_model/opd_record_model.dart';
import '../../models/shift_model/shift_model.dart';

class ShiftReportProvider extends ChangeNotifier {
  // API Base URL
  static const String _baseUrl = 'https://api.opd.afaqmis.com/api';

  // State variables
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String? _selectedShiftId = 'All';

  // Data
  List<ShiftModel> _availableShifts = [];
  List<OpdRecordModel> _opdRecords = [];
  List<ExpenseModel> _expenses = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  String? get selectedShiftId => _selectedShiftId;
  List<ShiftModel> get availableShifts => _availableShifts;
  List<OpdRecordModel> get opdRecords => _opdRecords;
  List<ExpenseModel> get expenses => _expenses;

  // Computed properties matching React implementation
  List<ConsultationSummary> get consultationSummaries {
    final Map<String, _ConsultationAccumulator> consultMap = {};

    for (var record in _opdRecords.where((r) => r.isConsultation)) {
      final doctorName = record.serviceDetail ?? 'Unknown Doctor';

      if (!consultMap.containsKey(doctorName)) {
        consultMap[doctorName] = _ConsultationAccumulator(
          doctorName: doctorName,
          totalAmount: 0,
          drShare: 0,
          hospitalShare: 0,
          count: 0,
        );
      }

      consultMap[doctorName]!.totalAmount += record.amount;
      consultMap[doctorName]!.drShare += record.docShare;
      consultMap[doctorName]!.hospitalShare += record.hospitalShare;
      consultMap[doctorName]!.count += 1;
    }

    return consultMap.values
        .map((acc) => ConsultationSummary(
      doctorName: acc.doctorName,
      totalAmount: acc.totalAmount,
      drShare: acc.drShare,
      hospitalShare: acc.hospitalShare,
      count: acc.count,
    ))
        .toList()
      ..sort((a, b) => a.doctorName.compareTo(b.doctorName));
  }

  List<ServiceSummary> get serviceSummaries {
    final Map<String, _ServiceAccumulator> serviceMap = {};

    for (var record in _opdRecords.where((r) => !r.isConsultation)) {
      final serviceName = record.opdService ?? 'Other';

      if (!serviceMap.containsKey(serviceName)) {
        serviceMap[serviceName] = _ServiceAccumulator(
          serviceName: serviceName,
          totalAmount: 0,
          drShare: 0,
          hospitalShare: 0,
          count: 0,
        );
      }

      serviceMap[serviceName]!.totalAmount += record.amount;
      serviceMap[serviceName]!.drShare += record.docShare;
      serviceMap[serviceName]!.hospitalShare += record.hospitalShare;
      serviceMap[serviceName]!.count += 1;
    }

    return serviceMap.values
        .map((acc) => ServiceSummary(
      serviceName: acc.serviceName,
      totalAmount: acc.totalAmount,
      drShare: acc.drShare,
      hospitalShare: acc.hospitalShare,
      count: acc.count,
    ))
        .toList()
      ..sort((a, b) => a.serviceName.compareTo(b.serviceName));
  }

  FinancialSummary get financialSummary {
    // Calculate total revenue (all amounts)
    final revenue = _opdRecords.fold<double>(0, (sum, r) => sum + r.amount);

    // Calculate total expenses from expenses table
    final expenseTotal = _expenses.fold<double>(0, (sum, e) => sum + e.expenseAmount);

    // Calculate total doctor share (considered as expense)
    final docShareTotal = _opdRecords.fold<double>(0, (sum, r) => sum + r.docShare);

    // Total expenses = expenses + doctor share
    final totalExpenses = expenseTotal + docShareTotal;

    // Net hospital revenue = total revenue - total expenses
    final netRevenue = revenue - totalExpenses;

    return FinancialSummary(
      totalRevenue: revenue,
      totalExpensesWithDocShare: totalExpenses,
      netHospitalRevenue: netRevenue,
    );
  }

  // Grand total calculations (matching React)
  Map<String, double> get grandTotal {
    double totalAmount = 0;
    double totalDrShare = 0;
    double totalHospitalShare = 0;

    for (var record in _opdRecords) {
      totalAmount += record.amount;
      totalDrShare += record.docShare;
      totalHospitalShare += record.hospitalShare;
    }

    return {
      'totalAmount': totalAmount,
      'totalDrShare': totalDrShare,
      'totalHospitalShare': totalHospitalShare,
    };
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedShiftId = null;
    notifyListeners();
  }

  // Set selected shift ID
  void setSelectedShiftId(String? shiftId) {
    _selectedShiftId = shiftId;
    notifyListeners();
  }

  // Fetch available shifts for the selected date
  Future<void> fetchAvailableShifts() async {
    if (_selectedDate == null) return;

    try {
      final formattedDate = _formatDateForAPI(_selectedDate);

      final url = Uri.parse('$_baseUrl/patient-opd/list').replace(queryParameters: {
        'page': '1',
        'limit': '10000',
        'dateFrom': formattedDate,
        'dateTo': formattedDate,
      });

      print('Fetching available shifts for $formattedDate');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> records = data['data'];

          // Extract unique shift_id and shift_type combinations
          final Map<int, ShiftModel> shiftsMap = {};

          for (var record in records) {
            final shiftId = record['shift_id'];
            final shiftType = record['shift_type'];

            if (shiftId != null && !shiftsMap.containsKey(shiftId)) {
              shiftsMap[shiftId] = ShiftModel(
                shiftId: shiftId,
                shiftType: shiftType ?? 'Unknown',
                entryDate: record['entry_date'] != null
                    ? DateTime.tryParse(record['entry_date'])
                    : null,
              );
            }
          }

          var allShifts = shiftsMap.values.toList()
            ..sort((a, b) => a.shiftId.compareTo(b.shiftId));

          // Filter out the previous night shift
          // If there are multiple "Night" shifts, exclude the one with the lower shift_id
          final nightShifts = allShifts
              .where((s) => s.shiftType.toLowerCase() == 'night')
              .toList();

          int? shiftIdToExclude;

          if (nightShifts.length > 1) {
            // Exclude the night shift with the lowest ID (previous night)
            shiftIdToExclude = nightShifts.first.shiftId;
          }

          _availableShifts = allShifts
              .where((shift) => shift.shiftId != shiftIdToExclude)
              .toList();

          print('Found ${_availableShifts.length} available shifts');

          // Auto-select "All" when date changes
          _selectedShiftId = 'All';
        } else {
          _availableShifts = [];
          _selectedShiftId = 'All';
        }
      } else {
        print('Error fetching available shifts: ${response.statusCode}');
        _availableShifts = [];
        _selectedShiftId = 'All';
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching available shifts: $e');
      _availableShifts = [];
      _selectedShiftId = 'All';
      notifyListeners();
    }
  }

  // Fetch data based on shift_id or all shifts for the date
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Determine which shift_ids to fetch
      List<int> shiftIdsToFetch = [];

      if (_selectedShiftId == 'All') {
        // Get all shift_ids for the selected date
        shiftIdsToFetch = _availableShifts.map((s) => s.shiftId).toList();
      } else {
        // Get specific shift_id
        try {
          shiftIdsToFetch = [int.parse(_selectedShiftId!)];
        } catch (e) {
          print('Error parsing shift ID: $e');
          _opdRecords = [];
          _expenses = [];
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (shiftIdsToFetch.isEmpty) {
        _opdRecords = [];
        _expenses = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Fetching data for shift IDs: $shiftIdsToFetch');

      // Fetch Patient OPD Data for all relevant shift_ids
      List<OpdRecordModel> allOpdData = [];

      for (final shiftId in shiftIdsToFetch) {
        try {
          final url = Uri.parse('$_baseUrl/patient-opd/list').replace(queryParameters: {
            'page': '1',
            'limit': '10000',
            'shiftId': shiftId.toString(),
          });

          final response = await http.get(url);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['success'] == true && data['data'] != null) {
              final List<dynamic> records = data['data'];
              final opdRecords = records.map((json) => OpdRecordModel.fromJson(json)).toList();
              allOpdData.addAll(opdRecords);
            }
          }
        } catch (e) {
          print('Error fetching OPD records for shift $shiftId: $e');
        }
      }

      _opdRecords = allOpdData;
      print('Loaded ${_opdRecords.length} OPD records');

      // Fetch Expenses Data for all relevant shift_ids
      List<ExpenseModel> allExpenses = [];

      for (final shiftId in shiftIdsToFetch) {
        try {
          final url = Uri.parse('$_baseUrl/expenses/list').replace(queryParameters: {
            'shiftId': shiftId.toString(),
          });

          final response = await http.get(url);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['success'] == true && data['data'] != null) {
              final List<dynamic> records = data['data'];
              final expenseRecords = records.map((json) => ExpenseModel.fromJson(json)).toList();
              allExpenses.addAll(expenseRecords);
            }
          }
        } catch (e) {
          print('Error fetching expenses for shift $shiftId: $e');
        }
      }

      _expenses = allExpenses;
      print('Loaded ${_expenses.length} expense records');
    } catch (e) {
      print('Error fetching data: $e');
      _error = 'Failed to load shift report data';
      _opdRecords = [];
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await fetchAvailableShifts();
    await fetchData();
  }

  // Helper method to format date for API
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Helper classes for accumulation
class _ConsultationAccumulator {
  final String doctorName;
  double totalAmount;
  double drShare;
  double hospitalShare;
  int count;

  _ConsultationAccumulator({
    required this.doctorName,
    required this.totalAmount,
    required this.drShare,
    required this.hospitalShare,
    required this.count,
  });
}

class _ServiceAccumulator {
  final String serviceName;
  double totalAmount;
  double drShare;
  double hospitalShare;
  int count;

  _ServiceAccumulator({
    required this.serviceName,
    required this.totalAmount,
    required this.drShare,
    required this.hospitalShare,
    required this.count,
  });
}