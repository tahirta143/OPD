// models/shift_model/shift_model.dart
class ShiftModel {
  final int id;
  final DateTime shiftDate;
  final String shiftType;
  final String receiptFrom;
  final String receiptTo;
  final double totalAmount;
  final DateTime createdAt;
  final List<ShiftRow> rows;

  ShiftModel({
    required this.id,
    required this.shiftDate,
    required this.shiftType,
    required this.receiptFrom,
    required this.receiptTo,
    required this.totalAmount,
    required this.createdAt,
    required this.rows,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] ?? 0,
      shiftDate: DateTime.parse(json['shift_date'] ?? DateTime.now().toIso8601String()),
      shiftType: json['shift_type'] ?? '',
      receiptFrom: json['receipt_from'] ?? '',
      receiptTo: json['receipt_to'] ?? '',
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((row) => ShiftRow.fromJson(row))
          .toList(),
    );
  }

  // Calculate total patients based on receipt range
  int getPatientCount() {
    try {
      final from = int.tryParse(receiptFrom) ?? 0;
      final to = int.tryParse(receiptTo) ?? 0;
      return (to - from + 1).clamp(0, 1000);
    } catch (e) {
      return rows.fold(0, (sum, row) => sum + row.qty);
    }
  }

  // Get total amount by section
  double getSectionTotal(String section) {
    return rows
        .where((row) => row.section == section)
        .fold(0.0, (sum, row) => sum + row.total);
  }

  // Get total paid by section
  double getSectionPaid(String section) {
    return rows
        .where((row) => row.section == section)
        .fold(0.0, (sum, row) => sum + row.paid);
  }

  // Get total balance by section
  double getSectionBalance(String section) {
    return rows
        .where((row) => row.section == section)
        .fold(0.0, (sum, row) => sum + row.balance);
  }

  // Get OPD rows
  List<ShiftRow> get opdRows => rows.where((row) => row.section == 'opd').toList();

  // Get Expense rows
  List<ShiftRow> get expenseRows => rows.where((row) => row.section == 'expenses').toList();

  // Format date for display
  String getFormattedDate() {
    return '${shiftDate.day}/${shiftDate.month}/${shiftDate.year}';
  }

  // Get shift time range
  String getShiftTimeRange() {
    switch (shiftType.toLowerCase()) {
      case 'morning':
        return '08:00 AM - 02:00 PM';
      case 'evening':
        return '02:00 PM - 08:00 PM';
      case 'night':
        return '08:00 PM - 08:00 AM';
      default:
        return 'N/A';
    }
  }
}

class ShiftRow {
  final String section;
  final int sr;
  final String service;
  final int qty;
  final int discQty;
  final double discAmount;
  final double total;
  final double paid;
  final double balance;

  ShiftRow({
    required this.section,
    required this.sr,
    required this.service,
    required this.qty,
    required this.discQty,
    required this.discAmount,
    required this.total,
    required this.paid,
    required this.balance,
  });

  factory ShiftRow.fromJson(Map<String, dynamic> json) {
    return ShiftRow(
      section: json['section'] ?? '',
      sr: json['sr'] ?? 0,
      service: json['service'] ?? '',
      qty: json['qty'] ?? 0,
      discQty: json['discQty'] ?? 0,
      discAmount: double.parse(json['discAmount']?.toString() ?? '0'),
      total: double.parse(json['total']?.toString() ?? '0'),
      paid: double.parse(json['paid']?.toString() ?? '0'),
      balance: double.parse(json['balance']?.toString() ?? '0'),
    );
  }
}