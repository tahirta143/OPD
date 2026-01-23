// provider/shift_provider/shift_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/shift_model/shift_model.dart';

class ShiftProvider extends ChangeNotifier {
  List<ShiftModel> _shifts = [];
  List<ShiftModel> _filteredShifts = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Morning';
  String _selectedTimeFilter = 'All'; // Add time filter

  // Getters
  List<ShiftModel> get shifts => _shifts;
  List<ShiftModel> get filteredShifts => _filteredShifts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  String get selectedShift => _selectedShift;
  String get selectedTimeFilter => _selectedTimeFilter; // Add getter

  // API Base URL
  static const String _baseUrl = 'https://api.opd.afaqmis.com/api';

  // Add time filter setter
  void setSelectedTimeFilter(String filter) {
    _selectedTimeFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  // Fetch shift by date and type
  Future<void> fetchShiftByDateAndType(DateTime date, String shiftType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      print('Fetching shift for $formattedDate - $shiftType');

      final url = Uri.parse('$_baseUrl/shifts/by?date=$formattedDate&type=$shiftType');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final shift = ShiftModel.fromJson({
            ...data['shift'],
            'rows': data['rows'] ?? [],
          });

          _shifts = [shift];
          _applyFilters(); // Apply filters after loading
          _error = null;
          print('Successfully loaded shift with ${shift.rows.length} rows');
        } else {
          _error = 'API returned unsuccessful response';
          _shifts = [];
          _filteredShifts = [];
        }
      } else if (response.statusCode == 404) {
        _error = 'No shift data found for selected date and shift';
        _shifts = [];
        _filteredShifts = [];
      } else {
        _error = 'Failed to load shift: ${response.statusCode}';
        _shifts = [];
        _filteredShifts = [];
      }
    } catch (e) {
      _error = e.toString();
      _shifts = [];
      _filteredShifts = [];
      print('Error fetching shift: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters method
  void _applyFilters() {
    if (_shifts.isEmpty) {
      _filteredShifts = [];
      return;
    }

    // For now, just pass through since we only have one shift
    // In the future, you can implement actual time filtering
    _filteredShifts = List.from(_shifts);

    // Example of time filtering logic (for future implementation):
    /*
    if (_selectedTimeFilter == 'Week') {
      // Filter for this week
    } else if (_selectedTimeFilter == 'Month') {
      // Filter for this month
    } else {
      // All (default)
    }
    */
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Set selected shift
  void setSelectedShift(String shift) {
    _selectedShift = shift;
    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    if (_filteredShifts.isEmpty) {
      return {
        'shiftCount': 0,
        'totalAmount': 0.0,
        'totalPatients': 0,
        'averageAmount': 0.0,
        'opdTotal': 0.0,
        'expensesTotal': 0.0,
        'shiftTypeCount': {},
      };
    }

    try {
      final shiftCount = _filteredShifts.length;
      final totalAmount = _filteredShifts.fold(0.0, (sum, shift) => sum + shift.totalAmount);
      final totalPatients = _filteredShifts.fold(0, (sum, shift) => sum + shift.getPatientCount());
      final averageAmount = shiftCount > 0 ? totalAmount / shiftCount : 0.0;

      double opdTotal = 0.0;
      double expensesTotal = 0.0;

      for (var shift in _filteredShifts) {
        opdTotal += shift.getSectionTotal('opd');
        expensesTotal += shift.getSectionTotal('expenses');
      }

      final shiftTypeCount = <String, int>{};
      for (var shift in _filteredShifts) {
        shiftTypeCount[shift.shiftType] = (shiftTypeCount[shift.shiftType] ?? 0) + 1;
      }

      return {
        'shiftCount': shiftCount,
        'totalAmount': totalAmount,
        'totalPatients': totalPatients,
        'averageAmount': averageAmount,
        'opdTotal': opdTotal,
        'expensesTotal': expensesTotal,
        'shiftTypeCount': shiftTypeCount,
      };
    } catch (e) {
      print('Error in getStatistics: $e');
      return {
        'shiftCount': 0,
        'totalAmount': 0.0,
        'totalPatients': 0,
        'averageAmount': 0.0,
        'opdTotal': 0.0,
        'expensesTotal': 0.0,
        'shiftTypeCount': {},
      };
    }
  }

  // Get shift summary
  Map<String, dynamic> getShiftSummary() {
    try {
      final stats = getStatistics();
      final currentShift = _filteredShifts.isNotEmpty ? _filteredShifts.first : null;

      return {
        'stats': stats,
        'currentShift': currentShift,
        'opdRows': currentShift?.opdRows ?? [],
        'expenseRows': currentShift?.expenseRows ?? [],
        'opdTotal': currentShift?.getSectionTotal('opd') ?? 0.0,
        'expensesTotal': currentShift?.getSectionTotal('expenses') ?? 0.0,
        'opdPaid': currentShift?.getSectionPaid('opd') ?? 0.0,
        'opdBalance': currentShift?.getSectionBalance('opd') ?? 0.0,
        'shiftTypeDistribution': stats['shiftTypeCount'],
      };
    } catch (e) {
      print('Error in getShiftSummary: $e');
      return {
        'stats': {},
        'currentShift': null,
        'opdRows': [],
        'expenseRows': [],
        'opdTotal': 0.0,
        'expensesTotal': 0.0,
        'opdPaid': 0.0,
        'opdBalance': 0.0,
        'shiftTypeDistribution': {},
      };
    }
  }

  // Clear data
  void clear() {
    _shifts.clear();
    _filteredShifts.clear();
    _error = null;
    notifyListeners();
  }
}