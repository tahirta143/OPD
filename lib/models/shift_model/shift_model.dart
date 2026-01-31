class ShiftModel {
  final int shiftId;
  final String shiftType;
  final DateTime? entryDate;

  ShiftModel({
    required this.shiftId,
    required this.shiftType,
    this.entryDate,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      shiftId: json['shift_id'] is int
          ? json['shift_id']
          : int.tryParse(json['shift_id']?.toString() ?? '0') ?? 0,
      shiftType: json['shift_type']?.toString() ?? 'Unknown',
      entryDate: json['entry_date'] != null
          ? DateTime.tryParse(json['entry_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift_id': shiftId,
      'shift_type': shiftType,
      'entry_date': entryDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ShiftModel(shiftId: $shiftId, shiftType: $shiftType, entryDate: $entryDate)';
  }
}