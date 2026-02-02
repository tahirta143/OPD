// import 'dart:convert';
//
// class ShiftReportModel {
//   final bool success;
//   final List<DailyReport> report;
//   final Period period;
//
//   ShiftReportModel({
//     required this.success,
//     required this.report,
//     required this.period,
//   });
//
//   factory ShiftReportModel.fromJson(Map<String, dynamic> json) {
//     return ShiftReportModel(
//       success: json['success'] ?? false,
//       report: (json['report'] as List<dynamic>)
//           .map((item) => DailyReport.fromJson(item))
//           .toList(),
//       period: Period.fromJson(json['period']),
//     );
//   }
// }
//
// class DailyReport {
//   final String date;
//   final ShiftData morning;
//   final ShiftData evening;
//   final ShiftData night;
//
//   DailyReport({
//     required this.date,
//     required this.morning,
//     required this.evening,
//     required this.night,
//   });
//
//   factory DailyReport.fromJson(Map<String, dynamic> json) {
//     return DailyReport(
//       date: json['date'] ?? '',
//       morning: ShiftData.fromJson(json['morning'] ?? {}),
//       evening: ShiftData.fromJson(json['evening'] ?? {}),
//       night: ShiftData.fromJson(json['night'] ?? {}),
//     );
//   }
//
//   // Get all rows for the day
//   List<ReportRow> getAllRows() {
//     return [
//       ...morning.rows,
//       ...evening.rows,
//       ...night.rows,
//     ];
//   }
// }
//
// class ShiftData {
//   final int opdTotal;
//   final int opdCount;
//   final int expensesTotal;
//   final int expensesCount;
//   final List<ReportRow> rows;
//
//   ShiftData({
//     required this.opdTotal,
//     required this.opdCount,
//     required this.expensesTotal,
//     required this.expensesCount,
//     required this.rows,
//   });
//
//   factory ShiftData.fromJson(Map<String, dynamic> json) {
//     return ShiftData(
//       opdTotal: (json['opd_total'] as num?)?.toInt() ?? 0,
//       opdCount: (json['opd_count'] as num?)?.toInt() ?? 0,
//       expensesTotal: (json['expenses_total'] as num?)?.toInt() ?? 0,
//       expensesCount: (json['expenses_count'] as num?)?.toInt() ?? 0,
//       rows: (json['rows'] as List<dynamic>?)
//           ?.map((item) => ReportRow.fromJson(item))
//           .toList() ?? [],
//     );
//   }
// }
//
// class ReportRow {
//   final String section;
//   final String service;
//   final int count;
//   final int? hospitalShare;
//   final int total;
//   final bool? isTotalRow;
//
//   ReportRow({
//     required this.section,
//     required this.service,
//     required this.count,
//     this.hospitalShare,
//     required this.total,
//     this.isTotalRow,
//   });
//
//   factory ReportRow.fromJson(Map<String, dynamic> json) {
//     return ReportRow(
//       section: json['section'] ?? '',
//       service: json['service'] ?? '',
//       count: (json['count'] as num?)?.toInt() ?? 0,
//       hospitalShare: (json['hospital_share'] as num?)?.toInt(),
//       total: (json['total'] as num?)?.toInt() ?? 0,
//       isTotalRow: json['is_total_row'] ?? false,
//     );
//   }
// }
//
// class Period {
//   final int year;
//   final int month;
//   final String monthName;
//   final String startDate;
//   final String endDate;
//
//   Period({
//     required this.year,
//     required this.month,
//     required this.monthName,
//     required this.startDate,
//     required this.endDate,
//   });
//
//   factory Period.fromJson(Map<String, dynamic> json) {
//     return Period(
//       year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
//       month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
//       monthName: json['monthName'] ?? '',
//       startDate: json['startDate'] ?? '',
//       endDate: json['endDate'] ?? '',
//     );
//   }
// }
//
// // Summary Models
// class ConsultationSummary {
//   final String doctorName;
//   final double totalAmount;
//   final double drShare;
//   final double hospitalShare;
//
//   ConsultationSummary({
//     required this.doctorName,
//     required this.totalAmount,
//     required this.drShare,
//     required this.hospitalShare,
//   });
// }
//
// class ServiceSummary {
//   final String serviceName;
//   final double totalAmount;
//   final double drShare;
//   final double hospitalShare;
//
//   ServiceSummary({
//     required this.serviceName,
//     required this.totalAmount,
//     required this.drShare,
//     required this.hospitalShare,
//   });
// }
//
// class ExpenseSummary {
//   final String? expenseHead;
//   final String? expenseDescription;
//   final double expenseAmount;
//
//   ExpenseSummary({
//     this.expenseHead,
//     this.expenseDescription,
//     required this.expenseAmount,
//   });
// }
//
// class FinancialSummary {
//   final double totalRevenue;
//   final double totalExpenses;
//   final double totalExpensesWithDocShare;
//   final double netHospitalRevenue;
//
//   FinancialSummary({
//     required this.totalRevenue,
//     required this.totalExpenses,
//     required this.totalExpensesWithDocShare,
//     required this.netHospitalRevenue,
//   });
// }
//
// class ShiftSummary {
//   final String shiftName;
//   final int totalPatients;
//   final double totalRevenue;
//   final double totalExpenses;
//
//   ShiftSummary({
//     required this.shiftName,
//     required this.totalPatients,
//     required this.totalRevenue,
//     required this.totalExpenses,
//   });
// }
//
//
// // Filter Models
// class ShiftFilter {
//   final int id;
//   final String name;
//   final String startTime;
//   final String endTime;
//
//   ShiftFilter({
//     required this.id,
//     required this.name,
//     required this.startTime,
//     required this.endTime,
//   });
// }
//
// class MonthData {
//   final int month;
//   final String name;
//   final int year;
//   final double revenue;
//
//   MonthData({
//     required this.month,
//     required this.name,
//     required this.year,
//     required this.revenue,
//   });
// }
//
// class DateRangeData {
//   final DateTime startDate;
//   final DateTime endDate;
//   final double totalRevenue;
//   final double totalExpenses;
//
//   DateRangeData({
//     required this.startDate,
//     required this.endDate,
//     required this.totalRevenue,
//     required this.totalExpenses,
//   });
//
// }