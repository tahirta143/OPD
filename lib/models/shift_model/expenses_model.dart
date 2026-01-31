class ExpenseModel {
  final int? id;
  final String? expenseHead;
  final String? expenseDescription;
  final double expenseAmount;
  final int? shiftId;

  ExpenseModel({
    this.id,
    this.expenseHead,
    this.expenseDescription,
    required this.expenseAmount,
    this.shiftId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      expenseHead: json['expense_head']?.toString(),
      expenseDescription: json['expense_description']?.toString(),
      expenseAmount: _parseDouble(json['expense_amount']),
      shiftId: json['shift_id'] is int ? json['shift_id'] : int.tryParse(json['shift_id']?.toString() ?? ''),
    );
  }

  // Helper method to safely parse doubles
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_head': expenseHead,
      'expense_description': expenseDescription,
      'expense_amount': expenseAmount,
      'shift_id': shiftId,
    };
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, expenseHead: $expenseHead, expenseDescription: $expenseDescription, expenseAmount: $expenseAmount, shiftId: $shiftId)';
  }
}