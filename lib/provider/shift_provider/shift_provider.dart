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
// Main Enhanced Provider that extends your existing functionality
class EnhancedShiftReportProvider extends ChangeNotifier {
  // API URLs for new features
  static const String _baseUrl = 'https://api.opd.afaqmis.com/api';
  static const String _monthlyReportUrl = '$_baseUrl/shifts/monthly-report';
  static const String _dateRangeReportUrl = '$_baseUrl/shifts/date-range-report';
  static const String _yearlySummaryUrl = '$_baseUrl/shifts/yearly-summary';
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

  // Setters for new features
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
      notifyListeners();

      final year = _selectedYear ?? DateTime.now().year;

      print('🔵 Fetching yearly summary for year: $year');

      // We'll fetch data for each month and aggregate it
      double totalRevenue = 0;
      double totalExpenses = 0;
      int totalDays = 0;
      int totalOpdCount = 0;
      final monthlyBreakdown = <Map<String, dynamic>>[];

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

            if (data is Map && data.containsKey('success') && data['success'] == true) {
              if (data.containsKey('report') && data['report'] is List) {
                final reportList = data['report'] as List;

                if (reportList.isNotEmpty) {
                  double monthRevenue = 0;
                  double monthExpenses = 0;
                  int monthOpdCount = 0;

                  for (var dayData in reportList) {
                    if (dayData is Map) {
                      // Parse morning shift
                      final morning = dayData['morning'] as Map<String, dynamic>? ?? {};
                      monthRevenue += (morning['opd_total'] ?? 0).toDouble();
                      monthExpenses += (morning['expenses_total'] ?? 0).toDouble();
                      monthOpdCount += ((morning['opd_count'] ?? 0) as num).toInt();

                      // Parse evening shift
                      final evening = dayData['evening'] as Map<String, dynamic>? ?? {};
                      monthRevenue += (evening['opd_total'] ?? 0).toDouble();
                      monthExpenses += (evening['expenses_total'] ?? 0).toDouble();
                      monthOpdCount += ((evening['opd_count'] ?? 0) as num).toInt();

                      // Parse night shift
                      final night = dayData['night'] as Map<String, dynamic>? ?? {};
                      monthRevenue += (night['opd_total'] ?? 0).toDouble();
                      monthExpenses += (night['expenses_total'] ?? 0).toDouble();
                      monthOpdCount += ((night['opd_count'] ?? 0) as num).toInt();

                      totalDays++;
                    }
                  }

                  // Add to yearly totals
                  totalRevenue += monthRevenue;
                  totalExpenses += monthExpenses;
                  totalOpdCount += monthOpdCount;

                  // Add to monthly breakdown
                  monthlyBreakdown.add({
                    'month': month,
                    'month_name': _getMonthName(month),
                    'revenue': monthRevenue,
                    'expenses': monthExpenses,
                    'net': monthRevenue - monthExpenses,
                    'opd_count': monthOpdCount,
                    'days_with_data': reportList.length,
                  });

                  print('📊 Month $month: Revenue=$monthRevenue, Expenses=$monthExpenses');
                }
              }
            }
          } else {
            print('⚠️ Failed to fetch month $month: ${response.statusCode}');
            // Add zero data for this month
            monthlyBreakdown.add({
              'month': month,
              'month_name': _getMonthName(month),
              'revenue': 0,
              'expenses': 0,
              'net': 0,
              'opd_count': 0,
              'days_with_data': 0,
            });
          }
        } catch (e) {
          print('💥 Error fetching month $month: $e');
          // Add zero data for this month
          monthlyBreakdown.add({
            'month': month,
            'month_name': _getMonthName(month),
            'revenue': 0,
            'expenses': 0,
            'net': 0,
            'opd_count': 0,
            'days_with_data': 0,
          });
        }
      }

      // Calculate yearly totals
      final double netAmount = totalRevenue - totalExpenses;
      final double avgMonthlyRevenue = totalRevenue / 12;
      final double avgMonthlyExpenses = totalExpenses / 12;
      final double avgDailyRevenue = totalDays > 0 ? totalRevenue / totalDays : 0;

      // Create yearly summary
      _yearlySummary = {
        'year': year,
        'total_revenue': totalRevenue,
        'total_expenses': totalExpenses,
        'net_amount': netAmount,
        'total_opd_count': totalOpdCount,
        'total_days_with_data': totalDays,
        'avg_monthly_revenue': avgMonthlyRevenue,
        'avg_monthly_expenses': avgMonthlyExpenses,
        'avg_daily_revenue': avgDailyRevenue,
        'monthly_breakdown': monthlyBreakdown,
      };

      print('💰 Yearly Summary for $year:');
      print('   Total Revenue: $totalRevenue');
      print('   Total Expenses: $totalExpenses');
      print('   Net Amount: $netAmount');
      print('   Total OPD Count: $totalOpdCount');
      print('   Days with Data: $totalDays');

      if (totalRevenue == 0 && totalExpenses == 0) {
        _errorMessageNew = 'No data available for selected year';
      }
    } catch (e) {
      _errorMessageNew = 'Error loading yearly summary: $e';
      print('💥 Exception: $e');
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
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