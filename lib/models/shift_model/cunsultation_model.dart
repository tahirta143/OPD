// consultation_summary.dart
class ConsultationSummary {
  final String doctorName;
  final double totalAmount;
  final double drShare;
  final double hospitalShare;
  final int count;

  ConsultationSummary({
    required this.doctorName,
    required this.totalAmount,
    required this.drShare,
    required this.hospitalShare,
    required this.count,
  });

  @override
  String toString() {
    return 'ConsultationSummary(doctorName: $doctorName, totalAmount: $totalAmount, drShare: $drShare, hospitalShare: $hospitalShare, count: $count)';
  }
}

// service_summary.dart
class ServiceSummary {
  final String serviceName;
  final double totalAmount;
  final double drShare;
  final double hospitalShare;
  final int count;

  ServiceSummary({
    required this.serviceName,
    required this.totalAmount,
    required this.drShare,
    required this.hospitalShare,
    required this.count,
  });

  @override
  String toString() {
    return 'ServiceSummary(serviceName: $serviceName, totalAmount: $totalAmount, drShare: $drShare, hospitalShare: $hospitalShare, count: $count)';
  }
}

// financial_summary.dart
class FinancialSummary {
  final double totalRevenue;
  final double totalExpensesWithDocShare;
  final double netHospitalRevenue;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpensesWithDocShare,
    required this.netHospitalRevenue,
  });

  @override
  String toString() {
    return 'FinancialSummary(totalRevenue: $totalRevenue, totalExpensesWithDocShare: $totalExpensesWithDocShare, netHospitalRevenue: $netHospitalRevenue)';
  }
}