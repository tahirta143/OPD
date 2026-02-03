import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/shift_model/shift_month_model.dart';
import '../../models/shift_model/shift_model.dart';
import '../../models/shift_model/opd_record_model.dart';
import '../../models/shift_model/expenses_model.dart';

// Enums - Add these if not already defined
enum FilterType {
  daily,
  monthly,
  dateRange,
  yearly,
}

enum ReportViewType {
  summary,
  detailed,
  comparative,
}

enum ExportFormat {
  json,
  csv,
  pdf,
}

// Data Models for Summary Views - Add these if not already defined
class ConsultationSummary {
  final String doctorName;
  final double totalAmount;
  final double drShare;
  final double hospitalShare;
  final int? count;

  ConsultationSummary({
    required this.doctorName,
    required this.totalAmount,
    required this.drShare,
    required this.hospitalShare,
    this.count,
  });
}

class ServiceSummary {
  final String serviceName;
  final double totalAmount;
  final double drShare;
  final double hospitalShare;
  final int? count;

  ServiceSummary({
    required this.serviceName,
    required this.totalAmount,
    required this.drShare,
    required this.hospitalShare,
    this.count,
  });
}

class ExpenseSummary {
  final String expenseHead;
  final String expenseDescription;
  final double expenseAmount;

  ExpenseSummary({
    required this.expenseHead,
    required this.expenseDescription,
    required this.expenseAmount,
  });
}

class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double totalExpensesWithDocShare;
  final double netHospitalRevenue;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalExpensesWithDocShare,
    required this.netHospitalRevenue,
  });
}

class ShiftSummary {
  final String shiftName;
  final int totalPatients;
  final double totalRevenue;
  final double totalExpenses;

  ShiftSummary({
    required this.shiftName,
    required this.totalPatients,
    required this.totalRevenue,
    required this.totalExpenses,
  });
}

class DateRangeData {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalExpenses;

  DateRangeData({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpenses,
  });
}

class MonthData {
  final int month;
  final String name;
  final int year;
  final double revenue;

  MonthData({
    required this.month,
    required this.name,
    required this.year,
    required this.revenue,
  });
}

class ShiftFilter {
  final int id;
  final String name;
  final String startTime;
  final String endTime;

  ShiftFilter({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });
}
// Add these new models after your existing models
class DailyReport {
  final DateTime date;
  final double morningRevenue;
  final double morningExpenses;
  final double eveningRevenue;
  final double eveningExpenses;
  final double nightRevenue;
  final double nightExpenses;
  final List<Map<String, dynamic>> morningRows;
  final List<Map<String, dynamic>> eveningRows;
  final List<Map<String, dynamic>> nightRows;

  DailyReport({
    required this.date,
    required this.morningRevenue,
    required this.morningExpenses,
    required this.eveningRevenue,
    required this.eveningExpenses,
    required this.nightRevenue,
    required this.nightExpenses,
    required this.morningRows,
    required this.eveningRows,
    required this.nightRows,
  });

  double get totalRevenue => morningRevenue + eveningRevenue + nightRevenue;
  double get totalExpenses => morningExpenses + eveningExpenses + nightExpenses;
  double get netAmount => totalRevenue - totalExpenses;
}

class MonthlySummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netAmount;
  final List<DailyReport> dailyReports;

  MonthlySummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netAmount,
    required this.dailyReports,
  });
}

class DailySummary {
  final DateTime date;
  final double totalRevenue;
  final double totalExpenses;
  final double netAmount;
  final int morningOpdCount;
  final int eveningOpdCount;
  final int nightOpdCount;

  DailySummary({
    required this.date,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netAmount,
    required this.morningOpdCount,
    required this.eveningOpdCount,
    required this.nightOpdCount,
  });
}

class YearlyBreakdownItem {
  final int month;
  final String shift;
  final String service;
  final double amount;

  YearlyBreakdownItem({
    required this.month,
    required this.shift,
    required this.service,
    required this.amount,
  });

  factory YearlyBreakdownItem.fromJson(Map<String, dynamic> json) {
    return YearlyBreakdownItem(
      month: json['month'] as int,
      shift: json['shift'] as String,
      service: json['service'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
// Main Enhanced Provider that extends your existing functionality
class EnhancedShiftReportProvider extends ChangeNotifier {
  // API URLs for new features
  static const String _baseUrl = 'https://api.opd.afaqmis.com/api';
  static const String _monthlyReportUrl = '$_baseUrl/shifts/monthly-report';
  static const String _dateRangeReportUrl = '$_baseUrl/shifts/date-range-report';
  static const String _yearlyReportUrl = '$_baseUrl/shifts/yearly-report';
  static const String _detailedBreakdownUrl = '$_baseUrl/shifts/detailed-breakdown';
  // State for new features
  bool _isLoadingNew = false;
  String _errorMessageNew = '';
  ShiftReportModel? _shiftReport;
  List<MonthData> _monthlyData = [];
  DateRangeData? _dateRangeData;
  MonthlySummary? _monthlySummary;
  List<DailyReport> _dailyReports = [];
  List<DailySummary> _dailySummaries = [];
  Map<String, dynamic>? _yearlySummary;
  Map<String, dynamic>? _detailedBreakdownData;
  List<Map<String, dynamic>> _opdServiceBreakdown = [];
  List<Map<String, dynamic>> _expensesBreakdown = [];
  List<Map<String, dynamic>> _combinedServiceBreakdown = [];
  String _selectedYearlyView = 'All'; // 'All', 'OPD', 'Expenses', 'Consultation'
  String _selectedShiftFilter = 'All'; // 'All', 'Morning', 'Evening', 'Night'



  // Filter states for new features
  FilterType _selectedFilterType = FilterType.daily;
  ReportViewType _selectedViewType = ReportViewType.summary;
  int? _selectedYear;
  int? _selectedMonth;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Getters for new features
  bool get isLoadingNew => _isLoadingNew;
  String get errorMessageNew => _errorMessageNew;
  ShiftReportModel? get shiftReport => _shiftReport;
  List<MonthData> get monthlyData => _monthlyData;
  DateRangeData? get dateRangeData => _dateRangeData;
  Map<String, dynamic>? get yearlySummary => _yearlySummary;
  FilterType get selectedFilterType => _selectedFilterType;
  ReportViewType get selectedViewType => _selectedViewType;
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  DateTime? get selectedStartDate => _selectedStartDate;
  DateTime? get selectedEndDate => _selectedEndDate;
  MonthlySummary? get monthlySummary => _monthlySummary;
  List<DailyReport> get dailyReports => _dailyReports;
  List<DailySummary> get dailySummaries => _dailySummaries;
  Map<String, dynamic>? get detailedBreakdownData => _detailedBreakdownData;
  List<Map<String, dynamic>> get opdServiceBreakdown => _opdServiceBreakdown;
  List<Map<String, dynamic>> get expensesBreakdown => _expensesBreakdown;
  List<Map<String, dynamic>> get combinedServiceBreakdown => _combinedServiceBreakdown;
  String get selectedYearlyView => _selectedYearlyView;
  String get selectedShiftFilter => _selectedShiftFilter;


  // Setters for new features

  // Setters for filters
  void setSelectedYearlyView(String view) {
    _selectedYearlyView = view;
    notifyListeners();
  }

  void setSelectedShiftFilter(String shift) {
    _selectedShiftFilter = shift;
    notifyListeners();
  }

  // Reset filters
  void resetYearlyFilters() {
    _selectedYearlyView = 'All';
    _selectedShiftFilter = 'All';
    notifyListeners();
  }

  void setSelectedFilterType(FilterType type) {
    _selectedFilterType = type;
    notifyListeners();
  }

  void setSelectedViewType(ReportViewType type) {
    _selectedViewType = type;
    notifyListeners();
  }

  void setSelectedYear(int? year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setSelectedMonth(int? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setSelectedStartDate(DateTime? date) {
    _selectedStartDate = date;
    notifyListeners();
  }

  void setSelectedEndDate(DateTime? date) {
    _selectedEndDate = date;
    notifyListeners();
  }


  List<Map<String, dynamic>> get filteredServices {
    if (_combinedServiceBreakdown.isEmpty) return [];

    final selectedShift = _selectedShiftFilter;
    final selectedView = _selectedYearlyView;
    final isAllView = selectedView == 'All';
    final shiftFiltered = selectedShift != 'All';

    final result = <Map<String, dynamic>>[];

    for (final service in _combinedServiceBreakdown) {
      final serviceType = service['type'] as String? ?? '';
      final serviceName = service['service_name'] as String? ?? 'Unknown';

      // 1. Apply view type filter
      if (!isAllView && serviceType != selectedView.toUpperCase()) {
        continue;
      }

      // 2. Apply shift filter
      if (shiftFiltered) {
        final shift = selectedShift.toLowerCase();

        // Determine which keys to use for this shift
        String shiftTotalKey;
        String shiftAmountsKey;

        switch (shift) {
          case 'morning':
            shiftTotalKey = 'morning_total';
            shiftAmountsKey = 'morning_amounts';
            break;
          case 'evening':
            shiftTotalKey = 'evening_total';
            shiftAmountsKey = 'evening_amounts';
            break;
          case 'night':
            shiftTotalKey = 'night_total';
            shiftAmountsKey = 'night_amounts';
            break;
          default:
          // Should not happen, but fallback
            shiftTotalKey = 'total';
            shiftAmountsKey = 'monthly_amounts';
        }

        // Get shift data
        final shiftTotal = (service[shiftTotalKey] as num?)?.toDouble() ?? 0.0;
        final shiftAmounts = service[shiftAmountsKey] as Map<String, dynamic>?;

        // Handle different service types
        if (serviceType == 'CONSULTATION' || serviceType == 'OPD') {
          // For CONSULTATION and OPD, only include if shift has data
          if (shiftTotal > 0) {
            result.add(_createFilteredService(
              service,
              shiftTotal,
              shiftAmounts,
              selectedShift,
              true,  // has shift data
            ));
          }
          // If shiftTotal is 0, skip this service for this shift
        }
        else if (serviceType == 'EXPENSE') {
          // Check if expense has shift-specific data
          final hasShiftSpecificData = service.containsKey(shiftTotalKey) ||
              (shiftAmounts != null && shiftAmounts.isNotEmpty);

          if (hasShiftSpecificData && shiftTotal > 0) {
            // Expense WITH shift-specific data
            result.add(_createFilteredService(
              service,
              shiftTotal,
              shiftAmounts,
              selectedShift,
              true,  // has shift data
            ));
          }
          else if (!hasShiftSpecificData) {
            // Expense WITHOUT shift-specific data - include with note
            result.add(_addExpenseNote(service));
          }
          // If hasShiftSpecificData is true but shiftTotal is 0, skip
        }
        else {
          // For other service types (if any), include if shift has data
          if (shiftTotal > 0) {
            result.add(_createFilteredService(
              service,
              shiftTotal,
              shiftAmounts,
              selectedShift,
              true,
            ));
          }
        }
      } else {
        // No shift filter selected - include all services as-is
        result.add(service);
      }
    }

    return result;
  }

// Helper to create filtered service entry
  Map<String, dynamic> _createFilteredService(
      Map<String, dynamic> service,
      double shiftTotal,
      Map<String, dynamic>? shiftAmounts,
      String selectedShift,
      bool hasShiftData,
      ) {
    // Create new service map with shift-filtered data
    return {
      ...service,  // Spread operator copies the original map
      'total': shiftTotal,
      'shift_filtered_total': shiftTotal,
      'filtered_monthly_amounts': shiftAmounts ?? {},
      '_filtered_by_shift': selectedShift,
      '_has_shift_data': hasShiftData,
      if (!hasShiftData) '_shift_note': 'Not shift-specific',
    };
  }

// Helper for expenses without shift data
  Map<String, dynamic> _addExpenseNote(Map<String, dynamic> service) {
    return {
      ...service,
      '_has_shift_data': false,
      '_shift_note': 'Expenses are not shift-specific',
    };
  }
  // Get month names for dropdown
  List<Map<String, dynamic>> get availableMonths {
    return [
      {'id': 1, 'name': 'January'},
      {'id': 2, 'name': 'February'},
      {'id': 3, 'name': 'March'},
      {'id': 4, 'name': 'April'},
      {'id': 5, 'name': 'May'},
      {'id': 6, 'name': 'June'},
      {'id': 7, 'name': 'July'},
      {'id': 8, 'name': 'August'},
      {'id': 9, 'name': 'September'},
      {'id': 10, 'name': 'October'},
      {'id': 11, 'name': 'November'},
      {'id': 12, 'name': 'December'},
    ];
  }

  // Get available years for dropdown
  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 2 + index);
  }

  Future<void> fetchYearlyReport() async {
    try {
      _isLoadingNew = true;
      _errorMessageNew = '';
      _yearlySummary = null;
      notifyListeners();

      final year = _selectedYear ?? DateTime.now().year;
      print('🔵 Fetching yearly report for year: $year');

      final uri = Uri.parse(_yearlyReportUrl).replace(queryParameters: {
        'year': year.toString(),
      });

      final response = await http.get(uri);
      print('🟢 Yearly report response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('📊 Yearly report data received: ${data.keys}');

        if (data.containsKey('success') && data['success'] == true) {
          print('✅ API returned success: true');

          // Process the opdBreakdown data
          final List<dynamic> opdBreakdown = data['opdBreakdown'] ?? [];
          print('📈 OPD Breakdown items: ${opdBreakdown.length}');

          // Transform the data for your pivot table
          _processYearlyData(data);

          _yearlySummary = data;
        } else {
          _errorMessageNew = 'API did not return success';
        }
      } else {
        _errorMessageNew = 'Failed to load yearly report: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessageNew = 'Error loading yearly report: $e';
      print('💥 Exception: $e');
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }
  void _processYearlyData(Map<String, dynamic> data) {
    final List<dynamic> opdBreakdown = data['opdBreakdown'] ?? [];

    // 1. Get all unique services
    final Set<String> allServices = {};
    final Set<int> allMonths = {};

    for (var item in opdBreakdown) {
      if (item is Map) {
        final service = item['service']?.toString() ?? 'Unknown';
        final month = item['month'] as int? ?? 0;

        if (month > 0) allMonths.add(month);
        if (service.isNotEmpty) allServices.add(service);
      }
    }

    // 2. Create monthly breakdown structure with service_data
    final List<Map<String, dynamic>> monthlyBreakdown = [];

    for (int month = 1; month <= 12; month++) {
      double monthRevenue = 0;
      Map<String, double> serviceAmounts = {};

      for (var item in opdBreakdown) {
        if (item is Map && item['month'] == month) {
          final service = item['service']?.toString() ?? 'Unknown';
          final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;

          monthRevenue += amount;
          serviceAmounts[service] = (serviceAmounts[service] ?? 0) + amount;
        }
      }

      // Always add the month, even if no data
      monthlyBreakdown.add({
        'month': month,
        'month_name': _getMonthName(month),
        'revenue': monthRevenue,
        'service_data': serviceAmounts,
      });
    }

    // 3. Calculate yearly totals
    double totalRevenue = 0;
    Map<String, double> yearlyServiceTotals = {};

    for (var item in opdBreakdown) {
      if (item is Map) {
        final service = item['service']?.toString() ?? 'Unknown';
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;

        totalRevenue += amount;
        yearlyServiceTotals[service] = (yearlyServiceTotals[service] ?? 0) + amount;
      }
    }

    // 4. Prepare combined service breakdown for the UI - CRITICAL FIX
    _combinedServiceBreakdown.clear(); // Clear first

    yearlyServiceTotals.forEach((serviceName, totalAmount) {
      // Create service data with monthly breakdown
      Map<String, double> monthlyAmounts = {};

      for (int month = 1; month <= 12; month++) {
        monthlyAmounts['month_$month'] = 0.0;

        // Find amount for this service in this month
        for (var item in opdBreakdown) {
          if (item is Map &&
              item['month'] == month &&
              (item['service']?.toString() ?? 'Unknown') == serviceName) {
            monthlyAmounts['month_$month'] = (item['amount'] as num?)?.toDouble() ?? 0.0;
            break;
          }
        }
      }

      _combinedServiceBreakdown.add({
        'type': 'OPD',
        'service_name': serviceName,
        'total': totalAmount,
        'monthly_amounts': monthlyAmounts, // Store monthly data here
      });
    });

    // Sort services by total amount (descending)
    _combinedServiceBreakdown.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));

    // 5. Update yearly summary with processed data
    data['monthly_breakdown'] = monthlyBreakdown;
    data['total_revenue'] = totalRevenue;
    data['total_expenses'] = 0.0; // This endpoint only has revenue data
    data['net_amount'] = totalRevenue;
    data['total_opd_count'] = opdBreakdown.length;

    print('💰 Processed yearly data:');
    print('   Total Revenue: $totalRevenue');
    print('   Unique Services: ${allServices.length}');
    print('   Combined Services: ${_combinedServiceBreakdown.length}');

    // Debug: Print first few services
    if (_combinedServiceBreakdown.isNotEmpty) {
      print('📊 Sample services:');
      for (int i = 0; i < min(3, _combinedServiceBreakdown.length); i++) {
        print('   ${i + 1}. ${_combinedServiceBreakdown[i]['service_name']}: Rs ${_combinedServiceBreakdown[i]['total']}');
      }
    }
  }



  // fetch detailed breakdown
  Future<void> fetchDetailedBreakdown() async {
    try {
      _isLoadingNew = true;
      _errorMessageNew = '';
      _detailedBreakdownData = null;
      _opdServiceBreakdown = [];
      _expensesBreakdown = [];
      _combinedServiceBreakdown = [];
      notifyListeners();

      final queryParams = {
        'year': _selectedYear?.toString() ?? DateTime.now().year.toString(),
        'month': _selectedMonth?.toString() ?? DateTime.now().month.toString(),
      };

      print('🔵 Fetching detailed breakdown with params: $queryParams');

      final uri = Uri.parse(_detailedBreakdownUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      print('🟢 Detailed breakdown response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('📊 Parsed response type: ${responseData.runtimeType}');

        if (responseData is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(responseData);

          if (data.containsKey('success') && data['success'] == true) {
            print('✅ API returned success: true');
            _detailedBreakdownData = data;

            // Parse OPD particulars - CORRECT FIELD NAME: opdParticulars
            if (data.containsKey('opdParticulars') && data['opdParticulars'] is List) {
              final opdParticulars = data['opdParticulars'] as List;
              print('📈 OPD Particulars found: ${opdParticulars.length} items');

              _opdServiceBreakdown = opdParticulars.map<Map<String, dynamic>>((item) {
                if (item is Map) {
                  final itemMap = Map<String, dynamic>.from(item);
                  print('📊 OPD item: $itemMap'); // Debug log
                  return itemMap;
                }
                return {};
              }).toList();
              print('✅ OPD Services breakdown: ${_opdServiceBreakdown.length} items');
            } else {
              print('⚠️ No opdParticulars found in response');
            }

            // Parse expense particulars - CORRECT FIELD NAME: expenseParticulars
            if (data.containsKey('expenseParticulars') && data['expenseParticulars'] is List) {
              final expenseParticulars = data['expenseParticulars'] as List;
              print('💰 Expense Particulars found: ${expenseParticulars.length} items');

              _expensesBreakdown = expenseParticulars.map<Map<String, dynamic>>((item) {
                if (item is Map) {
                  final itemMap = Map<String, dynamic>.from(item);
                  print('📊 Expense item: $itemMap'); // Debug log
                  return itemMap;
                }
                return {};
              }).toList();
              print('✅ Expenses breakdown: ${_expensesBreakdown.length} items');
            } else {
              print('⚠️ No expenseParticulars found in response');
            }

            // Create combined list for display
            _createCombinedBreakdown();
          } else {
            _errorMessageNew = 'API did not return success';
          }
        } else {
          _errorMessageNew = 'Invalid response format';
        }
      } else {
        _errorMessageNew = 'Failed to load detailed breakdown: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessageNew = 'Error loading detailed breakdown: $e';
      print('💥 Exception: $e');
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }
// Helper method to create combined breakdown
  // Helper method to create combined breakdown
  void _createCombinedBreakdown() {
    _combinedServiceBreakdown = [];

    print('🔄 Creating combined breakdown...');
    print('📊 OPD items to process: ${_opdServiceBreakdown.length}');
    print('📊 Expense items to process: ${_expensesBreakdown.length}');

    // Debug: Show first OPD item structure
    if (_opdServiceBreakdown.isNotEmpty) {
      print('📊 First OPD item structure:');
      final firstOpd = _opdServiceBreakdown[0];
      firstOpd.forEach((key, value) {
        print('   "$key": $value (type: ${value.runtimeType})');
      });

      // Check if 'service' field exists
      if (firstOpd.containsKey('service')) {
        print('✅ Found "service" field in OPD: "${firstOpd['service']}"');
      } else {
        print('❌ "service" field NOT found in OPD. Available keys: ${firstOpd.keys.toList()}');
      }
    }

    // Debug: Show first Expense item structure
    if (_expensesBreakdown.isNotEmpty) {
      print('📊 First Expense item structure:');
      final firstExpense = _expensesBreakdown[0];
      firstExpense.forEach((key, value) {
        print('   "$key": $value (type: ${value.runtimeType})');
      });

      if (firstExpense.containsKey('service')) {
        print('✅ Found "service" field in Expense: "${firstExpense['service']}"');
      } else {
        print('❌ "service" field NOT found in Expense. Available keys: ${firstExpense.keys.toList()}');
      }
    }

    // Add OPD services from opdParticulars
    // Add OPD services from opdParticulars
    for (int i = 0; i < _opdServiceBreakdown.length; i++) {
      var opdService = _opdServiceBreakdown[i];

      // Try multiple field names - FIXED VERSION
      String serviceName = 'Unknown Service';

      // Check all possible field names - FIXED: Check for null and trim
      if (opdService.containsKey('service') && opdService['service'] != null) {
        serviceName = opdService['service'].toString().trim();
      } else if (opdService.containsKey('service_name') && opdService['service_name'] != null) {
        serviceName = opdService['service_name'].toString().trim();
      } else if (opdService.containsKey('name') && opdService['name'] != null) {
        serviceName = opdService['name'].toString().trim();
      } else if (opdService.containsKey('description') && opdService['description'] != null) {
        serviceName = opdService['description'].toString().trim();
      }

      // If still empty after trimming, use default
      if (serviceName.isEmpty) {
        serviceName = 'Unknown Service';
        print('⚠️ Empty service name found in OPD item $i');
      }

      print('📊 OPD Item $i service name: "$serviceName"');

      // Extract amounts
      final morning = (opdService['morning'] as num?)?.toDouble() ?? 0.0;
      final evening = (opdService['evening'] as num?)?.toDouble() ?? 0.0;
      final night = (opdService['night'] as num?)?.toDouble() ?? 0.0;
      final total = (opdService['total'] as num?)?.toDouble() ?? 0.0;

      _combinedServiceBreakdown.add({
        'type': 'OPD',
        'service_name': serviceName,
        'morning': morning,
        'evening': evening,
        'night': night,
        'total': total,
        'original_data': opdService, // Keep original for debugging
      });
    }
    // Add expenses from expenseParticulars
    for (int i = 0; i < _expensesBreakdown.length; i++) {
      var expense = _expensesBreakdown[i];

      // Try multiple field names
      String serviceName = 'Unknown Expense';

      if (expense.containsKey('service')) {
        serviceName = expense['service']?.toString() ?? 'Unknown Expense';
      } else if (expense.containsKey('expense_head')) {
        serviceName = expense['expense_head']?.toString() ?? 'Unknown Expense';
      } else if (expense.containsKey('expense_name')) {
        serviceName = expense['expense_name']?.toString() ?? 'Unknown Expense';
      } else if (expense.containsKey('description')) {
        serviceName = expense['description']?.toString() ?? 'Unknown Expense';
      } else if (expense.containsKey('name')) {
        serviceName = expense['name']?.toString() ?? 'Unknown Expense';
      }

      print('📊 Expense Item $i service name: "$serviceName"');

      final morning = (expense['morning'] as num?)?.toDouble() ?? 0.0;
      final evening = (expense['evening'] as num?)?.toDouble() ?? 0.0;
      final night = (expense['night'] as num?)?.toDouble() ?? 0.0;
      final total = (expense['total'] as num?)?.toDouble() ?? 0.0;

      _combinedServiceBreakdown.add({
        'type': 'EXPENSE',
        'service_name': serviceName,
        'morning': morning,
        'evening': evening,
        'night': night,
        'total': total,
        'original_data': expense, // Keep original for debugging
      });
    }

    print('🔄 Combined breakdown created: ${_combinedServiceBreakdown.length} items');

    // Print all service names for debugging
    print('📊 All service names in combined breakdown:');
    for (int i = 0; i < min(5, _combinedServiceBreakdown.length); i++) {
      print('   $i. Type: ${_combinedServiceBreakdown[i]['type']}, Name: "${_combinedServiceBreakdown[i]['service_name']}"');
    }
  }



  Future<Map<String, double>> getServiceMonthlyBreakdown(int year, int month) async {
    try {
      _isLoadingNew = true;
      notifyListeners();

      final queryParams = {
        'year': year.toString(),
        'month': month.toString(),
      };

      final uri = Uri.parse(_detailedBreakdownUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('success') && data['success'] == true) {
          // Parse the data and extract service-wise amounts
          final serviceAmounts = <String, double>{};

          // Process OPD particulars
          if (data.containsKey('opdParticulars') && data['opdParticulars'] is List) {
            final opdList = data['opdParticulars'] as List;
            for (var opd in opdList) {
              if (opd is Map) {
                final serviceName = opd['service']?.toString() ?? opd['service_name']?.toString() ?? 'Unknown';
                final total = (opd['total'] as num?)?.toDouble() ?? 0.0;
                serviceAmounts[serviceName] = total;
              }
            }
          }

          // Process expense particulars
          if (data.containsKey('expenseParticulars') && data['expenseParticulars'] is List) {
            final expenseList = data['expenseParticulars'] as List;
            for (var expense in expenseList) {
              if (expense is Map) {
                final serviceName = expense['expense_head']?.toString() ??
                    expense['service']?.toString() ??
                    'Unknown Expense';
                final total = (expense['total'] as num?)?.toDouble() ?? 0.0;
                serviceAmounts[serviceName] = total;
              }
            }
          }

          return serviceAmounts;
        }
      }
      return {};
    } catch (e) {
      print('Error fetching service monthly breakdown: $e');
      return {};
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }

  // New API methods (your existing daily functionality remains unchanged)
  // In your EnhancedShiftReportProvider, update the fetchMonthlyReport method:
  Future<void> fetchMonthlyReport() async {
    try {
      _isLoadingNew = true;
      _errorMessageNew = '';
      _monthlySummary = null;
      _dailyReports = [];
      _dailySummaries = [];
      notifyListeners();

      final queryParams = {
        'year': _selectedYear?.toString() ?? DateTime.now().year.toString(),
        'month': _selectedMonth?.toString() ?? DateTime.now().month.toString(),
      };

      print('🔵 Fetching monthly report with params: $queryParams');

      final uri = Uri.parse(_monthlyReportUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      print('🟢 Monthly report response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Monthly report data received');

        if (data is Map && data.containsKey('success') && data['success'] == true) {
          print('✅ API returned success: true');

          if (data.containsKey('report') && data['report'] is List) {
            final reportList = data['report'] as List;
            print('📅 Report contains ${reportList.length} days');

            if (reportList.isNotEmpty) {
              // Calculate totals and parse daily reports
              double totalRevenue = 0;
              double totalExpenses = 0;
              final dailyReports = <DailyReport>[];
              final dailySummaries = <DailySummary>[];

              for (var dayData in reportList) {
                if (dayData is Map) {
                  final dateStr = dayData['date'] as String?;
                  if (dateStr == null) continue;

                  final date = DateTime.parse(dateStr);

                  // Parse morning shift
                  final morning = dayData['morning'] as Map<String, dynamic>? ?? {};
                  final morningRevenue = (morning['opd_total'] ?? 0).toDouble();
                  final morningExpenses = (morning['expenses_total'] ?? 0).toDouble();
                  final morningRows = (morning['rows'] as List<dynamic>? ?? [])
                      .map((row) => row as Map<String, dynamic>)
                      .toList();
                  final morningOpdCount = (morning['opd_count'] ?? 0).toInt();

                  // Parse evening shift
                  final evening = dayData['evening'] as Map<String, dynamic>? ?? {};
                  final eveningRevenue = (evening['opd_total'] ?? 0).toDouble();
                  final eveningExpenses = (evening['expenses_total'] ?? 0).toDouble();
                  final eveningRows = (evening['rows'] as List<dynamic>? ?? [])
                      .map((row) => row as Map<String, dynamic>)
                      .toList();
                  final eveningOpdCount = (evening['opd_count'] ?? 0).toInt();

                  // Parse night shift
                  final night = dayData['night'] as Map<String, dynamic>? ?? {};
                  final nightRevenue = (night['opd_total'] ?? 0).toDouble();
                  final nightExpenses = (night['expenses_total'] ?? 0).toDouble();
                  final nightRows = (night['rows'] as List<dynamic>? ?? [])
                      .map((row) => row as Map<String, dynamic>)
                      .toList();
                  final nightOpdCount = (night['opd_count'] ?? 0).toInt();

                  // Create daily report
                  final dailyReport = DailyReport(
                    date: date,
                    morningRevenue: morningRevenue,
                    morningExpenses: morningExpenses,
                    eveningRevenue: eveningRevenue,
                    eveningExpenses: eveningExpenses,
                    nightRevenue: nightRevenue,
                    nightExpenses: nightExpenses,
                    morningRows: morningRows,
                    eveningRows: eveningRows,
                    nightRows: nightRows,
                  );

                  // Create daily summary
                  final dailySummary = DailySummary(
                    date: date,
                    totalRevenue: dailyReport.totalRevenue,
                    totalExpenses: dailyReport.totalExpenses,
                    netAmount: dailyReport.netAmount,
                    morningOpdCount: morningOpdCount,
                    eveningOpdCount: eveningOpdCount,
                    nightOpdCount: nightOpdCount,
                  );

                  dailyReports.add(dailyReport);
                  dailySummaries.add(dailySummary);

                  // Add to totals
                  totalRevenue += dailyReport.totalRevenue;
                  totalExpenses += dailyReport.totalExpenses;

                  print('📆 ${date.day}/${date.month}/${date.year}: '
                      'Revenue=${dailyReport.totalRevenue}, '
                      'Expenses=${dailyReport.totalExpenses}');
                }
              }

              // Create monthly summary
              _monthlySummary = MonthlySummary(
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
                netAmount: totalRevenue - totalExpenses,
                dailyReports: dailyReports,
              );

              _dailyReports = dailyReports;
              _dailySummaries = dailySummaries;

              print('💰 Monthly Summary: '
                  'Total Revenue: $totalRevenue, '
                  'Total Expenses: $totalExpenses, '
                  'Net Amount: ${totalRevenue - totalExpenses}');
            } else {
              print('⚠️ Report list is empty');
              _errorMessageNew = 'No data available for selected month';
            }
          } else {
            print('❌ No report key found in response or report is not a list');
            _errorMessageNew = 'Invalid response format';
          }
        } else {
          print('❌ API did not return success: true');
          _errorMessageNew = 'Failed to load data from server';
        }
      } else {
        _errorMessageNew = 'Failed to load monthly report: ${response.statusCode}';
        print('❌ Error response: ${response.body}');
      }
    } catch (e) {
      _errorMessageNew = 'Error loading monthly report: $e';
      print('💥 Exception: $e');
    } finally {
      _isLoadingNew = false;
      print('🔄 Loading completed, notifying listeners');
      notifyListeners();
    }
  }

  // date range
  Future<void> fetchDateRangeReport() async {
    try {
      _isLoadingNew = true;
      _errorMessageNew = '';
      _dateRangeData = null;
      notifyListeners();

      if (_selectedStartDate == null || _selectedEndDate == null) {
        _errorMessageNew = 'Please select both start and end dates';
        _isLoadingNew = false;
        notifyListeners();
        return;
      }

      // Use 'from' and 'to' parameters as the API expects
      final queryParams = {
        'from': _formatDate(_selectedStartDate!),
        'to': _formatDate(_selectedEndDate!),
      };

      print('🔵 Fetching date range report with params: $queryParams');

      final uri = Uri.parse(_dateRangeReportUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      print('🟢 Date range report response: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Date range report data: $data');

        double totalRevenue = 0;
        double totalExpenses = 0;
        List<DailyReport> dailyReports = [];
        List<DailySummary> dailySummaries = [];

        if (data is Map && data.containsKey('success') && data['success'] == true) {
          if (data.containsKey('report') && data['report'] is List) {
            final reportList = data['report'] as List;
            print('📅 Date range report contains ${reportList.length} days');

            if (reportList.isNotEmpty) {
              for (var dayData in reportList) {
                if (dayData is Map) {
                  final dateStr = dayData['date'] as String?;
                  if (dateStr == null) continue;

                  final date = DateTime.parse(dateStr);

                  // Parse morning shift
                  final morning = dayData['morning'] as Map<String, dynamic>? ?? {};
                  final morningRevenue = (morning['opd_total'] ?? 0).toDouble();
                  final morningExpenses = (morning['expenses_total'] ?? 0).toDouble();
                  final morningRows = (morning['rows'] as List<dynamic>? ?? [])
                      .map((row) => row as Map<String, dynamic>)
                      .toList();
                  final morningOpdCount = (morning['opd_count'] ?? 0).toInt();

                  // Parse evening shift
                  final evening = dayData['evening'] as Map<String, dynamic>? ?? {};
                  final eveningRevenue = (evening['opd_total'] ?? 0).toDouble();
                  final eveningExpenses = (evening['expenses_total'] ?? 0).toDouble();
                  final eveningRows = (evening['rows'] as List<dynamic>? ?? [])
                      .map((row) => row as Map<String, dynamic>)
                      .toList();
                  final eveningOpdCount = (evening['opd_count'] ?? 0).toInt();

                  // Parse night shift
                  final night = dayData['night'] as Map<String, dynamic>? ?? {};
                  final nightRevenue = (night['opd_total'] ?? 0).toDouble();
                  final nightExpenses = (night['expenses_total'] ?? 0).toDouble();
                  final nightRows = (night['rows'] as List<dynamic>? ?? [])
                      .map((row) => row as Map<String, dynamic>)
                      .toList();
                  final nightOpdCount = (night['opd_count'] ?? 0).toInt();

                  // Create daily report
                  final dailyReport = DailyReport(
                    date: date,
                    morningRevenue: morningRevenue,
                    morningExpenses: morningExpenses,
                    eveningRevenue: eveningRevenue,
                    eveningExpenses: eveningExpenses,
                    nightRevenue: nightRevenue,
                    nightExpenses: nightExpenses,
                    morningRows: morningRows,
                    eveningRows: eveningRows,
                    nightRows: nightRows,
                  );

                  // Create daily summary
                  final dailySummary = DailySummary(
                    date: date,
                    totalRevenue: dailyReport.totalRevenue,
                    totalExpenses: dailyReport.totalExpenses,
                    netAmount: dailyReport.netAmount,
                    morningOpdCount: morningOpdCount,
                    eveningOpdCount: eveningOpdCount,
                    nightOpdCount: nightOpdCount,
                  );

                  dailyReports.add(dailyReport);
                  dailySummaries.add(dailySummary);

                  // Add to totals
                  totalRevenue += dailyReport.totalRevenue;
                  totalExpenses += dailyReport.totalExpenses;

                  print('📆 ${date.day}/${date.month}/${date.year}: '
                      'Revenue=${dailyReport.totalRevenue}, '
                      'Expenses=${dailyReport.totalExpenses}');
                }
              }

              // Store daily data for date range
              _dailyReports = dailyReports;
              _dailySummaries = dailySummaries;

              // Create monthly summary for the date range
              _monthlySummary = MonthlySummary(
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
                netAmount: totalRevenue - totalExpenses,
                dailyReports: dailyReports,
              );

              // Also set date range data
              _dateRangeData = DateRangeData(
                startDate: _selectedStartDate!,
                endDate: _selectedEndDate!,
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
              );

              print('💰 Date Range Summary: '
                  'Total Revenue: $totalRevenue, '
                  'Total Expenses: $totalExpenses, '
                  'Net Amount: ${totalRevenue - totalExpenses}');
            } else {
              _errorMessageNew = 'No data available for selected date range';
            }
          } else if (data.containsKey('data') && data['data'] is Map) {
            // Alternative response format
            final reportData = data['data'] as Map<String, dynamic>;
            totalRevenue = (reportData['total_revenue'] ?? 0).toDouble();
            totalExpenses = (reportData['total_expenses'] ?? 0).toDouble();

            _dateRangeData = DateRangeData(
              startDate: _selectedStartDate!,
              endDate: _selectedEndDate!,
              totalRevenue: totalRevenue,
              totalExpenses: totalExpenses,
            );
          }
        } else {
          // Try to parse error message
          if (data is Map && data.containsKey('error')) {
            _errorMessageNew = data['error'].toString();
          } else {
            _errorMessageNew = 'Failed to load date range report';
          }
        }

        if (totalRevenue == 0 && totalExpenses == 0 && _errorMessageNew.isEmpty) {
          _errorMessageNew = 'No data available for selected date range';
        }
      } else {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('error')) {
          _errorMessageNew = errorData['error'].toString();
        } else {
          _errorMessageNew = 'Failed to load date range report: ${response.statusCode}';
        }
        print('❌ Error response: ${response.body}');
      }
    } catch (e) {
      _errorMessageNew = 'Error loading date range report: $e';
      print('💥 Exception: $e');
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }
  Future<void> fetchYearlyMonthlyData() async {
    try {
      _isLoadingNew = true;
      _errorMessageNew = '';
      notifyListeners();

      final year = _selectedYear ?? DateTime.now().year;
      final monthlyData = <MonthData>[];

      // Fetch data for each month
      for (int month = 1; month <= 12; month++) {
        try {
          final queryParams = {
            'year': year.toString(),
            'month': month.toString(),
          };

          final uri = Uri.parse(_monthlyReportUrl).replace(queryParameters: queryParams);
          final response = await http.get(uri);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            double totalRevenue = 0;

            // Parse based on your API response structure
            if (data is Map && data.containsKey('report')) {
              final report = ShiftReportModel.fromJson(
                Map<String, dynamic>.from(data),
              );

              totalRevenue = report.report.fold(0.0, (sum, daily) {
                return sum +
                    (daily.morning?.opdTotal ?? 0) +
                    (daily.evening?.opdTotal ?? 0) +
                    (daily.night?.opdTotal ?? 0);
              });
            } else if (data is Map && data.containsKey('total_revenue')) {
              totalRevenue = (data['total_revenue'] ?? 0).toDouble();
            }

            monthlyData.add(MonthData(
              month: month,
              name: _getMonthName(month),
              year: year,
              revenue: totalRevenue,
            ));
          } else {
            // If API call fails for a month, add 0 revenue
            monthlyData.add(MonthData(
              month: month,
              name: _getMonthName(month),
              year: year,
              revenue: 0,
            ));
          }
        } catch (e) {
          print('Error fetching month $month: $e');
          monthlyData.add(MonthData(
            month: month,
            name: _getMonthName(month),
            year: year,
            revenue: 0,
          ));
        }
      }

      _monthlyData = monthlyData;
    } catch (e) {
      _errorMessageNew = 'Error loading monthly data: $e';
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }

  // Update the fetchYearlySummary method:
  Future<void> fetchYearlySummary() async {
    try {
      _isLoadingNew = true;
      _errorMessageNew = '';
      _yearlySummary = null;
      _combinedServiceBreakdown.clear(); // Clear existing data
      notifyListeners();

      final year = _selectedYear ?? DateTime.now().year;
      print('🔵 Fetching yearly report for year: $year');

      final uri = Uri.parse(_yearlyReportUrl).replace(queryParameters: {
        'year': year.toString(),
      });

      final response = await http.get(uri);
      print('🟢 Yearly report response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('📊 Yearly report data received: ${data.keys}');

        if (data.containsKey('success') && data['success'] == true) {
          print('✅ API returned success: true');

          // Process OPD breakdown
          final List<dynamic> opdBreakdown = data['opdBreakdown'] ?? [];
          final List<dynamic> expensesBreakdown = data['expensesBreakdown'] ?? [];
          final List<dynamic> consultationBreakdown = data['consultationBreakdown'] ?? [];

          print('📈 Data counts:');
          print('   OPD Breakdown: ${opdBreakdown.length} items');
          print('   Expenses Breakdown: ${expensesBreakdown.length} items');
          print('   Consultation Breakdown: ${consultationBreakdown.length} items');

          // Process data for service-month breakdown
          _processYearlyOpdData(opdBreakdown);
          _processYearlyExpensesData(expensesBreakdown);
          _processYearlyConsultationData(consultationBreakdown);

          // Calculate totals
          double totalOpdRevenue = 0;
          double totalExpenses = 0;
          double totalConsultation = 0;

          // Calculate OPD revenue
          for (var item in opdBreakdown) {
            if (item is Map<String, dynamic>) {
              totalOpdRevenue += (item['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }

          // Calculate expenses
          for (var item in expensesBreakdown) {
            if (item is Map<String, dynamic>) {
              totalExpenses += (item['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }

          // Calculate consultation total
          for (var item in consultationBreakdown) {
            if (item is Map<String, dynamic>) {
              totalConsultation += (item['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }

          double totalRevenue = totalOpdRevenue + totalConsultation;
          double netAmount = totalRevenue - totalExpenses;

          // Create monthly breakdown
          final List<Map<String, dynamic>> monthlyBreakdown = [];
          for (int month = 1; month <= 12; month++) {
            double monthOpdRevenue = 0;
            double monthExpenses = 0;
            double monthConsultation = 0;

            // Calculate month OPD revenue
            for (var item in opdBreakdown) {
              if (item is Map<String, dynamic> && item['month'] == month) {
                monthOpdRevenue += (item['amount'] as num?)?.toDouble() ?? 0.0;
              }
            }

            // Calculate month expenses
            for (var item in expensesBreakdown) {
              if (item is Map<String, dynamic> && item['month'] == month) {
                monthExpenses += (item['amount'] as num?)?.toDouble() ?? 0.0;
              }
            }

            // Calculate month consultation
            for (var item in consultationBreakdown) {
              if (item is Map<String, dynamic> && item['month'] == month) {
                monthConsultation += (item['amount'] as num?)?.toDouble() ?? 0.0;
              }
            }

            double monthRevenue = monthOpdRevenue + monthConsultation;

            monthlyBreakdown.add({
              'month': month,
              'month_name': _getMonthName(month),
              'opd_revenue': monthOpdRevenue,
              'consultation_revenue': monthConsultation,
              'total_revenue': monthRevenue,
              'expenses': monthExpenses,
              'net': monthRevenue - monthExpenses,
            });
          }

          // Update yearly summary with detailed totals
          _yearlySummary = {
            'year': year,
            'total_opd_revenue': totalOpdRevenue,
            'total_consultation_revenue': totalConsultation,
            'total_revenue': totalRevenue,
            'total_expenses': totalExpenses,
            'net_amount': netAmount,
            'monthly_breakdown': monthlyBreakdown,
            'opdBreakdown': opdBreakdown,
            'expensesBreakdown': expensesBreakdown,
            'consultationBreakdown': consultationBreakdown,
          };

          print('💰 Yearly Summary created:');
          print('   Total OPD Revenue: $totalOpdRevenue');
          print('   Total Consultation Revenue: $totalConsultation');
          print('   Total Revenue: $totalRevenue');
          print('   Total Expenses: $totalExpenses');
          print('   Net Amount: $netAmount');
          print('   Unique Services: ${_combinedServiceBreakdown.length}');

          if (_combinedServiceBreakdown.isNotEmpty) {
            print('📊 Sample services:');
            for (int i = 0; i < min(3, _combinedServiceBreakdown.length); i++) {
              print('   ${i + 1}. ${_combinedServiceBreakdown[i]['service_name']}: Rs ${_combinedServiceBreakdown[i]['total']}');
            }
          }
        } else {
          _errorMessageNew = 'API did not return success';
        }
      } else {
        _errorMessageNew = 'Failed to load yearly report: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessageNew = 'Error loading yearly report: $e';
      print('💥 Exception: $e');
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }

// Process OPD data
  void _processYearlyOpdData(List<dynamic> opdBreakdown) {
    _combinedServiceBreakdown.clear();

    // Group by service name
    final Map<String, Map<String, double>> serviceData = {};

    for (var item in opdBreakdown) {
      if (item is Map<String, dynamic>) {
        final serviceName = item['service']?.toString() ?? 'Unknown';
        final month = (item['month'] as num?)?.toInt() ?? 0;
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final shift = item['shift']?.toString() ?? 'Unknown';

        if (!serviceData.containsKey(serviceName)) {
          serviceData[serviceName] = {
            'total': 0.0,
          };

          // Initialize shift totals
          serviceData[serviceName]!['morning_total'] = 0.0;
          serviceData[serviceName]!['evening_total'] = 0.0;
          serviceData[serviceName]!['night_total'] = 0.0;
        }

        // Add to total
        serviceData[serviceName]!['total'] = (serviceData[serviceName]!['total'] ?? 0.0) + amount;

        // Add to shift total
        final shiftLower = shift.toLowerCase();
        switch (shiftLower) {
          case 'morning':
            serviceData[serviceName]!['morning_total'] =
                (serviceData[serviceName]!['morning_total'] ?? 0.0) + amount;
            break;
          case 'evening':
            serviceData[serviceName]!['evening_total'] =
                (serviceData[serviceName]!['evening_total'] ?? 0.0) + amount;
            break;
          case 'night':
            serviceData[serviceName]!['night_total'] =
                (serviceData[serviceName]!['night_total'] ?? 0.0) + amount;
            break;
        }

        // Add month amount
        final monthKey = 'month_$month';
        final currentMonthAmount = serviceData[serviceName]![monthKey] ?? 0.0;
        serviceData[serviceName]![monthKey] = currentMonthAmount + amount;

        // Add shift-specific month amount
        final shiftMonthKey = '${shiftLower}_month_$month';
        final currentShiftMonthAmount = serviceData[serviceName]![shiftMonthKey] ?? 0.0;
        serviceData[serviceName]![shiftMonthKey] = currentShiftMonthAmount + amount;
      }
    }

    // Convert to list format
    serviceData.forEach((serviceName, data) {
      // Create monthly amounts maps
      final Map<String, double> monthlyAmounts = {};
      final Map<String, double> morningAmounts = {};
      final Map<String, double> eveningAmounts = {};
      final Map<String, double> nightAmounts = {};

      for (int month = 1; month <= 12; month++) {
        final monthKey = 'month_$month';
        final morningKey = 'morning_month_$month';
        final eveningKey = 'evening_month_$month';
        final nightKey = 'night_month_$month';

        monthlyAmounts[monthKey] = data[monthKey] ?? 0.0;
        morningAmounts[monthKey] = data[morningKey] ?? 0.0;
        eveningAmounts[monthKey] = data[eveningKey] ?? 0.0;
        nightAmounts[monthKey] = data[nightKey] ?? 0.0;
      }

      _combinedServiceBreakdown.add({
        'type': 'OPD',
        'service_name': serviceName,
        'total': data['total'] ?? 0.0,
        'morning_total': data['morning_total'] ?? 0.0,
        'evening_total': data['evening_total'] ?? 0.0,
        'night_total': data['night_total'] ?? 0.0,
        'monthly_amounts': monthlyAmounts,
        'morning_amounts': morningAmounts,
        'evening_amounts': eveningAmounts,
        'night_amounts': nightAmounts,
      });
    });

    // Sort by total amount (descending)
    _combinedServiceBreakdown.sort((a, b) {
      final totalA = (a['total'] as num?)?.toDouble() ?? 0.0;
      final totalB = (b['total'] as num?)?.toDouble() ?? 0.0;
      return totalB.compareTo(totalA);
    });
  }

// Process expenses data
  void _processYearlyExpensesData(List<dynamic> expensesBreakdown) {
    final Map<String, Map<String, dynamic>> expenseData = {};

    for (var item in expensesBreakdown) {
      if (item is Map<String, dynamic>) {
        final expenseHead = item['head']?.toString() ?? 'Unknown';
        final month = (item['month'] as num?)?.toInt() ?? 0;
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final shift = item['shift']?.toString()?.toLowerCase() ?? 'all'; // Assuming shift field exists

        if (!expenseData.containsKey(expenseHead)) {
          expenseData[expenseHead] = {
            'total': 0.0,
            'morning_total': 0.0,
            'evening_total': 0.0,
            'night_total': 0.0,
          };
        }

        // Add to total
        expenseData[expenseHead]!['total'] += amount;

        // Add to shift total
        switch (shift) {
          case 'morning':
            expenseData[expenseHead]!['morning_total'] += amount;
            break;
          case 'evening':
            expenseData[expenseHead]!['evening_total'] += amount;
            break;
          case 'night':
            expenseData[expenseHead]!['night_total'] += amount;
            break;
        }

        // Add month amount
        final monthKey = 'month_$month';
        expenseData[expenseHead]![monthKey] =
            (expenseData[expenseHead]![monthKey] ?? 0.0) + amount;

        // Add shift-month amount
        final shiftMonthKey = '${shift}_month_$month';
        expenseData[expenseHead]![shiftMonthKey] =
            (expenseData[expenseHead]![shiftMonthKey] ?? 0.0) + amount;
      }
    }

    // Add expenses to combined breakdown
    expenseData.forEach((expenseHead, data) {
      final Map<String, double> monthlyAmounts = {};
      final Map<String, double> morningAmounts = {};
      final Map<String, double> eveningAmounts = {};
      final Map<String, double> nightAmounts = {};

      for (int month = 1; month <= 12; month++) {
        final monthKey = 'month_$month';
        final morningKey = 'morning_month_$month';
        final eveningKey = 'evening_month_$month';
        final nightKey = 'night_month_$month';

        monthlyAmounts[monthKey] = data[monthKey] ?? 0.0;
        morningAmounts[monthKey] = data[morningKey] ?? 0.0;
        eveningAmounts[monthKey] = data[eveningKey] ?? 0.0;
        nightAmounts[monthKey] = data[nightKey] ?? 0.0;
      }

      _combinedServiceBreakdown.add({
        'type': 'EXPENSE',
        'service_name': expenseHead,
        'total': data['total'] ?? 0.0,
        'morning_total': data['morning_total'] ?? 0.0,
        'evening_total': data['evening_total'] ?? 0.0,
        'night_total': data['night_total'] ?? 0.0,
        'monthly_amounts': monthlyAmounts,
        'morning_amounts': morningAmounts,
        'evening_amounts': eveningAmounts,
        'night_amounts': nightAmounts,
      });
    });
  }
// Process consultation data
  void _processYearlyConsultationData(List<dynamic> consultationBreakdown) {
    final Map<String, Map<String, dynamic>> doctorData = {};

    for (var item in consultationBreakdown) {
      final doctor = item['doctorName']?.toString() ?? 'Unknown';
      final month = (item['month'] as num?)?.toInt() ?? 0;
      final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
      final shift = item['shift']?.toString().toLowerCase() ?? 'unknown';

      doctorData.putIfAbsent(doctor, () => {
        'total': 0.0,
        'morning_total': 0.0,
        'evening_total': 0.0,
        'night_total': 0.0,
      });

      // total
      doctorData[doctor]!['total'] += amount;

      // shift total
      final shiftTotalKey = '${shift}_total';
      if (doctorData[doctor]!.containsKey(shiftTotalKey)) {
        doctorData[doctor]![shiftTotalKey] += amount;
      }

      // month
      final monthKey = 'month_$month';
      doctorData[doctor]![monthKey] =
          (doctorData[doctor]![monthKey] ?? 0.0) + amount;

      // shift + month
      final shiftMonthKey = '${shift}_month_$month';
      doctorData[doctor]![shiftMonthKey] =
          (doctorData[doctor]![shiftMonthKey] ?? 0.0) + amount;
    }

    doctorData.forEach((doctor, data) {
      final Map<String, double> monthly = {};
      final Map<String, double> morning = {};
      final Map<String, double> evening = {};
      final Map<String, double> night = {};

      for (int m = 1; m <= 12; m++) {
        monthly['month_$m'] = data['month_$m'] ?? 0.0;
        morning['month_$m'] = data['morning_month_$m'] ?? 0.0;
        evening['month_$m'] = data['evening_month_$m'] ?? 0.0;
        night['month_$m'] = data['night_month_$m'] ?? 0.0;
      }

      _combinedServiceBreakdown.add({
        'type': 'CONSULTATION',
        'service_name': doctor,
        'total': data['total'],
        'morning_total': data['morning_total'],
        'evening_total': data['evening_total'],
        'night_total': data['night_total'],
        'monthly_amounts': monthly,
        'morning_amounts': morning,
        'evening_amounts': evening,
        'night_amounts': night,
      });
    });
  }

  // Main fetch method for new features
  Future<void> fetchNewData() async {
    switch (_selectedFilterType) {
      case FilterType.daily:
      // Daily reports should use your existing ShiftReportProvider
        break;
      case FilterType.monthly:
        await fetchYearlyMonthlyData();
        await fetchDetailedBreakdown(); // Add this line
        break;
      case FilterType.dateRange:
        await fetchDateRangeReport();
        break;
      case FilterType.yearly:
        await fetchYearlySummary();
        await fetchYearlyReport();
        break;
    }
  }

  // Reset new filters
  void resetNewFilters() {
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _selectedStartDate = null;
    _selectedEndDate = null;
    _selectedFilterType = FilterType.daily;
    _selectedViewType = ReportViewType.summary;
    _shiftReport = null;
    _monthlyData = [];
    _dateRangeData = null;
    _yearlySummary = null;
    notifyListeners();
  }

  // Helper methods
  String _formatDate(DateTime date) {
    // Try different formats based on what your API expects
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  String _getMonthName(int month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// This is your ORIGINAL provider - keep it exactly as is
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
      totalExpenses: expenseTotal, // This is just the expense amount without doc share
      totalExpensesWithDocShare: totalExpenses, // This includes doc share
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

  // Monthly Report Methods
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final url = Uri.parse('$_baseUrl/monthly-report').replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load monthly report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly report: $e');
      rethrow;
    }
  }

  // Date Range Report Methods
  Future<Map<String, dynamic>> getDateRangeReport(DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = _formatDateForAPI(startDate);
      final endFormatted = _formatDateForAPI(endDate);

      final url = Uri.parse('$_baseUrl/date-range-report').replace(queryParameters: {
        'startDate': startFormatted,
        'endDate': endFormatted,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load date range report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching date range report: $e');
      rethrow;
    }
  }

  // Shift Summary Methods
  Future<Map<String, dynamic>> getShiftSummary(int shiftId) async {
    try {
      final url = Uri.parse('$_baseUrl/shift-summary').replace(queryParameters: {
        'shiftId': shiftId.toString(),
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load shift summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching shift summary: $e');
      rethrow;
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