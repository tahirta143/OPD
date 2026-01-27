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
  String _selectedShift = 'All';
  String _selectedTimeFilter = 'All';
  DateTime? _fromDate;
  DateTime? _toDate;

  // Getters
  List<ShiftModel> get shifts => _shifts;
  List<ShiftModel> get filteredShifts => _filteredShifts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  String get selectedShift => _selectedShift;
  String get selectedTimeFilter => _selectedTimeFilter;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  // API Base URL
  static const String _baseUrl = 'https://api.opd.afaqmis.com/api';

  // Setters with filter clearing logic
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    // Clear other filters when selecting single date
    _selectedTimeFilter = 'All';
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  void setSelectedShift(String shift) {
    _selectedShift = shift;
    notifyListeners();
  }

  void setSelectedTimeFilter(String filter) {
    _selectedTimeFilter = filter;
    // Clear date range when selecting time filter
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  void setFromDate(DateTime? date) {
    _fromDate = date;
    // Clear time filter when selecting date range
    _selectedTimeFilter = 'All';
    notifyListeners();

    // Auto-fetch if both dates are set
    if (_fromDate != null && _toDate != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        fetchData();
      });
    }
  }

  void setToDate(DateTime? date) {
    _toDate = date;
    // Clear time filter when selecting date range
    _selectedTimeFilter = 'All';
    notifyListeners();

    // Auto-fetch if both dates are set
    if (_fromDate != null && _toDate != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        fetchData();
      });
    }
  }

  // Main method to fetch data based on filters
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear previous data
      _shifts.clear();
      _filteredShifts.clear();

      print('Active filters: timeFilter=$_selectedTimeFilter, fromDate=$_fromDate, toDate=$_toDate, shift=$_selectedShift');

      // Determine which fetch method to use based on active filters
      if (_fromDate != null && _toDate != null) {
        print('Fetching by date range: $_fromDate to $_toDate');
        await _fetchByDateRange();
      } else if (_selectedTimeFilter != 'All') {
        print('Fetching by time filter: $_selectedTimeFilter');
        await _fetchByTimeRange();
      } else {
        print('Fetching by single date: $_selectedDate, shift: $_selectedShift');
        await _fetchByDateAndShift();
      }

      print('Total shifts loaded: ${_shifts.length}');
    } catch (e) {
      _error = e.toString();
      _shifts = [];
      _filteredShifts = [];
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch by single date and shift type
  Future<void> _fetchByDateAndShift() async {
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    List<String> shiftTypes =
    _selectedShift == 'All' ? ['Morning', 'Evening', 'Night'] : [_selectedShift];

    List<ShiftModel> loadedShifts = [];

    for (final type in shiftTypes) {
      try {
        final url = Uri.parse('$_baseUrl/shifts/by?date=$formattedDate&type=$type');
        print('Fetching shift: $url');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            final shift = ShiftModel.fromJson({
              ...data['shift'],
              'rows': data['rows'] ?? [],
            });
            loadedShifts.add(shift);
            print('✓ Loaded shift: ${shift.shiftType} - Date: ${shift.shiftDate}');
          } else {
            print('✗ No data for $formattedDate $type (success: false)');
          }
        } else if (response.statusCode == 404) {
          print('✗ No data found for $formattedDate $type (404)');
        } else {
          print('✗ API error ${response.statusCode} for $type');
        }
      } catch (e) {
        print('✗ Error fetching shift for $formattedDate $type: $e');
      }
    }

    if (loadedShifts.isEmpty) {
      _error = 'No shift data found for selected date';
      _shifts = [];
      _filteredShifts = [];
    } else {
      _shifts = loadedShifts;
      _filteredShifts = List.from(_shifts);
      print('✓ Successfully loaded ${loadedShifts.length} shifts');
    }
  }

  // Fetch by date range (fromDate to toDate)
  Future<void> _fetchByDateRange() async {
    // Ensure both dates are set
    if (_fromDate == null || _toDate == null) {
      _error = 'Both from date and to date must be selected';
      _shifts = [];
      _filteredShifts = [];
      return;
    }

    // Ensure fromDate is before toDate
    DateTime startDate = _fromDate!;
    DateTime endDate = _toDate!;

    if (endDate.isBefore(startDate)) {
      // Swap dates if they're in wrong order
      DateTime temp = startDate;
      startDate = endDate;
      endDate = temp;

      // Update the provider state
      _fromDate = startDate;
      _toDate = endDate;
    }

    // Format dates for display
    final fromDateStr = _formatDateForAPI(startDate);
    final toDateStr = _formatDateForAPI(endDate);

    print('📅 Fetching date range from $fromDateStr to $toDateStr');
    print('🔍 Selected shift: $_selectedShift');

    // Generate list of dates between fromDate and toDate
    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    print('📊 Will fetch ${dates.length} days of data');

    // Fetch shifts for each date
    List<ShiftModel> loadedShifts = [];
    int successCount = 0;
    int failCount = 0;

    for (final date in dates) {
      final formattedDate = _formatDateForAPI(date);

      // Determine which shifts to fetch based on selectedShift
      List<String> shiftTypes =
      _selectedShift == 'All' ? ['Morning', 'Evening', 'Night'] : [_selectedShift];

      for (final type in shiftTypes) {
        try {
          final url = Uri.parse('$_baseUrl/shifts/by?date=$formattedDate&type=$type');
          print('🔍 Fetching: $formattedDate - $type');
          final response = await http.get(url);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              final shift = ShiftModel.fromJson({
                ...data['shift'],
                'rows': data['rows'] ?? [],
              });
              loadedShifts.add(shift);
              successCount++;
              print('✓ Loaded shift for $formattedDate $type');
            } else {
              print('✗ No data for $formattedDate $type');
              failCount++;
            }
          } else if (response.statusCode == 404) {
            print('✗ 404: No data for $formattedDate $type');
            failCount++;
          } else {
            print('✗ Error ${response.statusCode} for $formattedDate $type');
            failCount++;
          }
        } catch (e) {
          print('✗ Error fetching shift for $formattedDate $type: $e');
          failCount++;
        }
      }
    }

    print('📊 Result: $successCount successes, $failCount failures');

    if (loadedShifts.isEmpty) {
      _error = 'No shift data found for the selected date range';
      _shifts = [];
      _filteredShifts = [];
    } else {
      _shifts = loadedShifts;
      _filteredShifts = List.from(_shifts);
      print('✅ Successfully loaded ${loadedShifts.length} shifts for date range');
    }
  }

  // Fetch by time range (Week, Month)
  Future<void> _fetchByTimeRange() async {
    DateTime startDate;
    DateTime endDate = DateTime.now();

    // Calculate start date based on time filter
    switch (_selectedTimeFilter) {
      case 'Week':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      default:
        startDate = endDate;
    }

    print('⏰ Time filter $_selectedTimeFilter: $startDate to $endDate');

    // Set fromDate and toDate for UI display
    _fromDate = startDate;
    _toDate = endDate;

    // Now fetch data for this date range
    await _fetchByDateRange();
  }

  // Fetch by shift type only (across all dates in range)
  Future<void> fetchByShift(String shiftType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shifts.clear();
      _filteredShifts.clear();

      final url = Uri.parse('$_baseUrl/shifts/by-shift?type=$shiftType');
      print('🔍 Fetching all shifts of type: $shiftType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['shifts'] != null) {
          List<ShiftModel> loadedShifts = [];
          for (var shiftData in data['shifts']) {
            final shift = ShiftModel.fromJson(shiftData);
            loadedShifts.add(shift);
          }

          _shifts = loadedShifts;
          _filteredShifts = List.from(_shifts);
          print('✅ Loaded ${loadedShifts.length} shifts for type: $shiftType');
        } else {
          _error = 'No shifts found for type: $shiftType';
          _shifts = [];
          _filteredShifts = [];
        }
      } else {
        _error = 'Failed to fetch shifts. Status: ${response.statusCode}';
        _shifts = [];
        _filteredShifts = [];
      }
    } catch (e) {
      _error = e.toString();
      _shifts = [];
      _filteredShifts = [];
      print('Error fetching by shift: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

      // Collect all rows from all shifts
      List<ShiftRow> allOpdRows = [];
      List<ShiftRow> allExpenseRows = [];

      for (var shift in _filteredShifts) {
        allOpdRows.addAll(shift.opdRows);
        allExpenseRows.addAll(shift.expenseRows);
      }

      return {
        'stats': stats,
        'currentShift': currentShift,
        'opdRows': allOpdRows,
        'expenseRows': allExpenseRows,
        'opdTotal': stats['opdTotal'] ?? 0.0,
        'expensesTotal': stats['expensesTotal'] ?? 0.0,
        'opdPaid': _calculateTotalPaid(),
        'opdBalance': _calculateTotalBalance(),
        'shiftTypeDistribution': stats['shiftTypeCount'],
        'dateRange': _fromDate != null && _toDate != null
            ? '${_formatDateForDisplay(_fromDate!)} - ${_formatDateForDisplay(_toDate!)}'
            : _formatDateForDisplay(_selectedDate),
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
        'dateRange': _formatDateForDisplay(_selectedDate),
      };
    }
  }

  // Helper methods
  double _calculateTotalPaid() {
    return _filteredShifts.fold(0.0, (sum, shift) => sum + shift.getSectionPaid('opd'));
  }

  double _calculateTotalBalance() {
    return _filteredShifts.fold(0.0, (sum, shift) => sum + shift.getSectionBalance('opd'));
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Check if date range is active
  bool get isDateRangeActive => _fromDate != null && _toDate != null;

  // Check if time filter is active
  bool get isTimeFilterActive => _selectedTimeFilter != 'All';

  // Clear all filters
  void clearAllFilters() {
    _selectedTimeFilter = 'All';
    _fromDate = null;
    _toDate = null;
    _selectedShift = 'All';
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  // Clear only specific filters
  void clearDateRange() {
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  void clearTimeFilter() {
    _selectedTimeFilter = 'All';
    notifyListeners();
  }

  // Clear data
  void clear() {
    _shifts.clear();
    _filteredShifts.clear();
    _error = null;
    notifyListeners();
  }
}