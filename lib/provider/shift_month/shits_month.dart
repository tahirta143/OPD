/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/shift_model/shift_month_model.dart';
// import '../../models/shift_report.dart';

class EnhancedShiftReportProvider extends ChangeNotifier {
  // API URLs
  static const String _baseUrl = 'https://api.opd.afaqmis.com/api/shifts';
  static const String _monthlyReportUrl = '$_baseUrl/monthly-report';
  static const String _dateRangeReportUrl = '$_baseUrl/date-range-report';
  static const String _shiftSummaryUrl = '$_baseUrl/shift-summary';
  static const String _availableShiftsUrl = '$_baseUrl/available-shifts';
  static const String _yearlySummaryUrl = '$_baseUrl/yearly-summary';

  // State
  bool _isLoading = false;
  String _errorMessage = '';
  ShiftReportModel? _shiftReport;
  List<ShiftFilter> _availableShifts = [];
  List<MonthData> _monthlyData = [];
  List<ShiftSummary> _shiftSummaries = [];
  DateRangeData? _dateRangeData;
  Map<String, dynamic>? _yearlySummary;

  // Filter states
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedShiftId;
  int? _selectedYear;
  int? _selectedMonth;
  FilterType _selectedFilterType = FilterType.daily;
  ReportViewType _selectedViewType = ReportViewType.summary;

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ShiftReportModel? get shiftReport => _shiftReport;
  List<ShiftFilter> get availableShifts => _availableShifts;
  List<MonthData> get monthlyData => _monthlyData;
  List<ShiftSummary> get shiftSummaries => _shiftSummaries;
  DateRangeData? get dateRangeData => _dateRangeData;
  Map<String, dynamic>? get yearlySummary => _yearlySummary;
  DateTime get selectedDate => _selectedDate;
  DateTime? get selectedStartDate => _selectedStartDate;
  DateTime? get selectedEndDate => _selectedEndDate;
  String? get selectedShiftId => _selectedShiftId;
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  FilterType get selectedFilterType => _selectedFilterType;
  ReportViewType get selectedViewType => _selectedViewType;

  // Derived data
  List<DailyReport> get dailyReports => _shiftReport?.report ?? [];

  List<ConsultationSummary> get consultationSummaries {
    final consultations = <ConsultationSummary>[];
    final allRows = _getAllRows();

    // Group by service name that contains "consultation"
    final consultationRows = allRows.where((row) =>
    row.section == 'opd' &&
        row.service.toLowerCase().contains('consultation')).toList();

    final doctorGroups = <String, List<ReportRow>>{};

    for (final row in consultationRows) {
      final service = row.service;
      if (!doctorGroups.containsKey(service)) {
        doctorGroups[service] = [];
      }
      doctorGroups[service]!.add(row);
    }

    // Create summaries
    doctorGroups.forEach((doctorName, rows) {
      final totalAmount = rows.fold(0.0, (sum, row) => sum + row.total);
      final drShare = rows.fold(0.0, (sum, row) => sum + (row.hospitalShare ?? 0));
      final hospitalShare = totalAmount - drShare;

      consultations.add(ConsultationSummary(
        doctorName: doctorName,
        totalAmount: totalAmount,
        drShare: drShare,
        hospitalShare: hospitalShare,
      ));
    });

    return consultations;
  }

  List<ServiceSummary> get serviceSummaries {
    final services = <ServiceSummary>[];
    final allRows = _getAllRows();

    // Group by service name (excluding consultations)
    final serviceRows = allRows.where((row) =>
    row.section == 'opd' &&
        !row.service.toLowerCase().contains('consultation') &&
        !row.service.toLowerCase().contains('doctor')).toList();

    final serviceGroups = <String, List<ReportRow>>{};

    for (final row in serviceRows) {
      final serviceName = row.service;
      if (!serviceGroups.containsKey(serviceName)) {
        serviceGroups[serviceName] = [];
      }
      serviceGroups[serviceName]!.add(row);
    }

    // Create summaries
    serviceGroups.forEach((serviceName, rows) {
      final totalAmount = rows.fold(0.0, (sum, row) => sum + row.total);
      final drShare = rows.fold(0.0, (sum, row) => sum + (row.hospitalShare ?? 0));
      final hospitalShare = totalAmount - drShare;

      services.add(ServiceSummary(
        serviceName: serviceName,
        totalAmount: totalAmount,
        drShare: drShare,
        hospitalShare: hospitalShare,
      ));
    });

    // Sort by highest hospital share
    services.sort((a, b) => b.hospitalShare.compareTo(a.hospitalShare));

    return services;
  }

  List<ExpenseSummary> get expenses {
    final expenses = <ExpenseSummary>[];
    final allRows = _getAllRows();

    final expenseRows = allRows.where((row) =>
    row.section == 'expenses' && row.isTotalRow != true).toList();

    for (final row in expenseRows) {
      expenses.add(ExpenseSummary(
        expenseHead: row.service,
        expenseDescription: row.service,
        expenseAmount: row.total.toDouble(),
      ));
    }

    // Sort by highest expense
    expenses.sort((a, b) => b.expenseAmount.compareTo(a.expenseAmount));

    return expenses;
  }

  FinancialSummary get financialSummary {
    final allRows = _getAllRows();

    // Total revenue from OPD rows
    final totalRevenue = allRows
        .where((row) => row.section == 'opd' && row.isTotalRow != true)
        .fold(0.0, (sum, row) => sum + row.total);

    // Total expenses (excluding doctor share)
    final totalExpenses = allRows
        .where((row) => row.section == 'expenses' && row.isTotalRow != true)
        .fold(0.0, (sum, row) => sum + row.total);

    // Doctor share from OPD
    final totalDrShare = allRows
        .where((row) => row.section == 'opd' && row.isTotalRow != true)
        .fold(0.0, (sum, row) => sum + (row.hospitalShare ?? 0));

    final totalExpensesWithDocShare = totalExpenses + totalDrShare;
    final netHospitalRevenue = totalRevenue - totalExpensesWithDocShare;

    return FinancialSummary(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      totalExpensesWithDocShare: totalExpensesWithDocShare,
      netHospitalRevenue: netHospitalRevenue,
    );
  }

  List<ReportRow> get opdRecords {
    return _getAllRows().where((row) => row.section == 'opd').toList();
  }

  // Get shift-wise data
  Map<String, ShiftSummary> get shiftWiseData {
    final shiftData = <String, ShiftSummary>{};

    if (_shiftReport == null) return shiftData;

    for (final daily in _shiftReport!.report) {
      // Morning shift
      shiftData.update('Morning', (existing) {
        return ShiftSummary(
          shiftName: 'Morning',
          totalPatients: existing.totalPatients + daily.morning.opdCount,
          totalRevenue: existing.totalRevenue + daily.morning.opdTotal,
          totalExpenses: existing.totalExpenses + daily.morning.expensesTotal,
        );
      }, ifAbsent: () {
        return ShiftSummary(
          shiftName: 'Morning',
          totalPatients: daily.morning.opdCount,
          totalRevenue: daily.morning.opdTotal.toDouble(),
          totalExpenses: daily.morning.expensesTotal.toDouble(),
        );
      });

      // Evening shift
      shiftData.update('Evening', (existing) {
        return ShiftSummary(
          shiftName: 'Evening',
          totalPatients: existing.totalPatients + daily.evening.opdCount,
          totalRevenue: existing.totalRevenue + daily.evening.opdTotal,
          totalExpenses: existing.totalExpenses + daily.evening.expensesTotal,
        );
      }, ifAbsent: () {
        return ShiftSummary(
          shiftName: 'Evening',
          totalPatients: daily.evening.opdCount,
          totalRevenue: daily.evening.opdTotal.toDouble(),
          totalExpenses: daily.evening.expensesTotal.toDouble(),
        );
      });

      // Night shift
      shiftData.update('Night', (existing) {
        return ShiftSummary(
          shiftName: 'Night',
          totalPatients: existing.totalPatients + daily.night.opdCount,
          totalRevenue: existing.totalRevenue + daily.night.opdTotal,
          totalExpenses: existing.totalExpenses + daily.night.expensesTotal,
        );
      }, ifAbsent: () {
        return ShiftSummary(
          shiftName: 'Night',
          totalPatients: daily.night.opdCount,
          totalRevenue: daily.night.opdTotal.toDouble(),
          totalExpenses: daily.night.expensesTotal.toDouble(),
        );
      });
    }

    return shiftData;
  }

  // Private helper
  List<ReportRow> _getAllRows() {
    return _shiftReport?.report.expand((daily) => daily.getAllRows()).toList() ?? [];
  }

  // Setters
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
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

  void setSelectedShiftId(String? shiftId) {
    _selectedShiftId = shiftId;
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

  void setSelectedFilterType(FilterType type) {
    _selectedFilterType = type;
    notifyListeners();
  }

  void setSelectedViewType(ReportViewType type) {
    _selectedViewType = type;
    notifyListeners();
  }

  // API Calls
  Future<void> fetchAvailableShifts() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final response = await http.get(Uri.parse(_availableShiftsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _availableShifts = (data['shifts'] as List<dynamic>)
            .map((shift) => ShiftFilter(
          id: shift['id'] ?? 0,
          name: shift['name'] ?? '',
          startTime: shift['start_time'] ?? '',
          endTime: shift['end_time'] ?? '',
        ))
            .toList();
      } else {
        _errorMessage = 'Failed to load shifts: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading shifts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyReport() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final queryParams = {
        'year': _selectedYear?.toString() ?? DateTime.now().year.toString(),
        'month': _selectedMonth?.toString() ?? DateTime.now().month.toString(),
        if (_selectedShiftId != null && _selectedShiftId != 'All')
          'shift_id': _selectedShiftId!,
      };

      final uri = Uri.parse(_monthlyReportUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _shiftReport = ShiftReportModel.fromJson(data);
      } else {
        _errorMessage = 'Failed to load monthly report: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading monthly report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDateRangeReport() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      if (_selectedStartDate == null || _selectedEndDate == null) {
        _errorMessage = 'Please select both start and end dates';
        return;
      }

      final queryParams = {
        'start_date': _formatDate(_selectedStartDate!),
        'end_date': _formatDate(_selectedEndDate!),
        if (_selectedShiftId != null && _selectedShiftId != 'All')
          'shift_id': _selectedShiftId!,
      };

      final uri = Uri.parse(_dateRangeReportUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _shiftReport = ShiftReportModel.fromJson(data);

        // Calculate date range summary
        final totalRevenue = _shiftReport?.report.fold(0.0, (sum, daily) {
          return sum +
              daily.morning.opdTotal +
              daily.evening.opdTotal +
              daily.night.opdTotal;
        }) ?? 0.0;

        final totalExpenses = _shiftReport?.report.fold(0.0, (sum, daily) {
          return sum +
              daily.morning.expensesTotal +
              daily.evening.expensesTotal +
              daily.night.expensesTotal;
        }) ?? 0.0;

        _dateRangeData = DateRangeData(
          startDate: _selectedStartDate!,
          endDate: _selectedEndDate!,
          totalRevenue: totalRevenue,
          totalExpenses: totalExpenses,
        );
      } else {
        _errorMessage = 'Failed to load date range report: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading date range report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShiftSummary() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final queryParams = {
        'year': _selectedYear?.toString() ?? DateTime.now().year.toString(),
        'month': _selectedMonth?.toString() ?? DateTime.now().month.toString(),
      };

      final uri = Uri.parse(_shiftSummaryUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        _shiftSummaries = data.map((item) {
          return ShiftSummary(
            shiftName: item['shift_name'] ?? '',
            totalPatients: (item['total_patients'] as num?)?.toInt() ?? 0,
            totalRevenue: (item['total_revenue'] as num?)?.toDouble() ?? 0,
            totalExpenses: (item['total_expenses'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      } else {
        _errorMessage = 'Failed to load shift summary: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading shift summary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchYearlyMonthlyData() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final year = _selectedYear ?? DateTime.now().year;
      final monthlyData = <MonthData>[];

      // Fetch data for each month (this could be optimized with a single API call)
      for (int month = 1; month <= 12; month++) {
        final queryParams = {
          'year': year.toString(),
          'month': month.toString(),
          if (_selectedShiftId != null && _selectedShiftId != 'All')
            'shift_id': _selectedShiftId!,
        };

        final uri = Uri.parse(_monthlyReportUrl).replace(queryParameters: queryParams);
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final report = ShiftReportModel.fromJson(data);

          // Calculate total revenue for the month
          final totalRevenue = report.report.fold(0.0, (sum, daily) {
            return sum +
                daily.morning.opdTotal +
                daily.evening.opdTotal +
                daily.night.opdTotal;
          });

          monthlyData.add(MonthData(
            month: month,
            name: _getMonthName(month),
            year: year,
            revenue: totalRevenue,
          ));
        }
      }

      _monthlyData = monthlyData;
    } catch (e) {
      _errorMessage = 'Error loading monthly data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchYearlySummary() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final year = _selectedYear ?? DateTime.now().year;

      final queryParams = {
        'year': year.toString(),
      };

      final uri = Uri.parse(_yearlySummaryUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _yearlySummary = data;
      } else {
        _errorMessage = 'Failed to load yearly summary: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading yearly summary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Main fetch method
  Future<void> fetchData() async {
    switch (_selectedFilterType) {
      case FilterType.daily:
        await fetchMonthlyReport();
        break;
      case FilterType.monthly:
        await fetchYearlyMonthlyData();
        break;
      case FilterType.dateRange:
        await fetchDateRangeReport();
        break;
      case FilterType.yearly:
        await fetchYearlySummary();
        break;
    }

    // Fetch shift summary for the current filter
    await fetchShiftSummary();
  }

  // Refresh data
  Future<void> refresh() async {
    await fetchData();
  }

  // Reset filters
  void resetFilters() {
    _selectedDate = DateTime.now();
    _selectedStartDate = null;
    _selectedEndDate = null;
    _selectedShiftId = null;
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _selectedFilterType = FilterType.daily;
    _selectedViewType = ReportViewType.summary;
    notifyListeners();
  }

  // Export data
  Future<String> exportData({required ExportFormat format}) async {
    try {
      final data = <String, dynamic>{};

      switch (_selectedFilterType) {
        case FilterType.daily:
          data['report_type'] = 'Daily Report';
          data['date'] = _formatDate(_selectedDate);
          data['financial_summary'] = {
            'total_revenue': financialSummary.totalRevenue,
            'total_expenses': financialSummary.totalExpenses,
            'doctor_share': financialSummary.totalExpensesWithDocShare - financialSummary.totalExpenses,
            'net_revenue': financialSummary.netHospitalRevenue,
          };
          data['consultations'] = consultationSummaries.map((c) => {
            'doctor_name': c.doctorName,
            'total_amount': c.totalAmount,
            'doctor_share': c.drShare,
            'hospital_share': c.hospitalShare,
          }).toList();
          data['services'] = serviceSummaries.map((s) => {
            'service_name': s.serviceName,
            'total_amount': s.totalAmount,
            'doctor_share': s.drShare,
            'hospital_share': s.hospitalShare,
          }).toList();
          data['expenses'] = expenses.map((e) => {
            'expense_head': e.expenseHead,
            'description': e.expenseDescription,
            'amount': e.expenseAmount,
          }).toList();
          break;

        case FilterType.monthly:
          data['report_type'] = 'Monthly Summary';
          data['year'] = _selectedYear;
          data['monthly_data'] = monthlyData.map((m) => {
            'month': m.name,
            'revenue': m.revenue,
          }).toList();
          break;

        case FilterType.dateRange:
          data['report_type'] = 'Date Range Report';
          data['start_date'] = _selectedStartDate != null ? _formatDate(_selectedStartDate!) : null;
          data['end_date'] = _selectedEndDate != null ? _formatDate(_selectedEndDate!) : null;
          data['total_revenue'] = dateRangeData?.totalRevenue ?? 0;
          data['total_expenses'] = dateRangeData?.totalExpenses ?? 0;
          break;
        case FilterType.yearly:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      if (format == ExportFormat.csv) {
        return _convertToCsv(data);
      } else {
        return json.encode(data);
      }
    } catch (e) {
      return 'Error exporting data: $e';
    }
  }

  String _convertToCsv(Map<String, dynamic> data) {
    final csvBuffer = StringBuffer();

    if (data['report_type'] == 'Daily Report') {
      csvBuffer.writeln('Daily Report - ${data['date']}');
      csvBuffer.writeln();
      csvBuffer.writeln('Financial Summary');
      csvBuffer.writeln('Metric,Amount');
      csvBuffer.writeln('Total Revenue,${data['financial_summary']['total_revenue']}');
      csvBuffer.writeln('Total Expenses,${data['financial_summary']['total_expenses']}');
      csvBuffer.writeln('Doctor Share,${data['financial_summary']['doctor_share']}');
      csvBuffer.writeln('Net Revenue,${data['financial_summary']['net_revenue']}');
      csvBuffer.writeln();

      csvBuffer.writeln('Consultations');
      csvBuffer.writeln('Doctor Name,Total Amount,Doctor Share,Hospital Share');
      for (final consultation in data['consultations']) {
        csvBuffer.writeln('${consultation['doctor_name']},${consultation['total_amount']},${consultation['doctor_share']},${consultation['hospital_share']}');
      }
      csvBuffer.writeln();

      csvBuffer.writeln('Services');
      csvBuffer.writeln('Service Name,Total Amount,Doctor Share,Hospital Share');
      for (final service in data['services']) {
        csvBuffer.writeln('${service['service_name']},${service['total_amount']},${service['doctor_share']},${service['hospital_share']}');
      }
      csvBuffer.writeln();

      csvBuffer.writeln('Expenses');
      csvBuffer.writeln('Expense Head,Description,Amount');
      for (final expense in data['expenses']) {
        csvBuffer.writeln('${expense['expense_head']},${expense['description']},${expense['amount']}');
      }
    } else if (data['report_type'] == 'Monthly Summary') {
      csvBuffer.writeln('Monthly Summary - ${data['year']}');
      csvBuffer.writeln();
      csvBuffer.writeln('Month,Revenue');
      for (final month in data['monthly_data']) {
        csvBuffer.writeln('${month['month']},${month['revenue']}');
      }
    }

    return csvBuffer.toString();
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Get available years for dropdown
  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 2 + index);
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
}

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
}*/
