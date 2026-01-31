class OpdRecordModel {
  final String? opdService;
  final String? serviceDetail;
  final double amount;
  final double docShare;
  final int? shiftId;
  final String? shiftType;
  final DateTime? entryDate;

  OpdRecordModel({
    this.opdService,
    this.serviceDetail,
    required this.amount,
    required this.docShare,
    this.shiftId,
    this.shiftType,
    this.entryDate,
  });

  factory OpdRecordModel.fromJson(Map<String, dynamic> json) {
    return OpdRecordModel(
      opdService: json['opd_service']?.toString(),
      serviceDetail: json['service_detail']?.toString(),
      amount: _parseDouble(json['amount']),
      docShare: _parseDouble(json['doc_share']),
      shiftId: json['shift_id'] is int ? json['shift_id'] : int.tryParse(json['shift_id']?.toString() ?? ''),
      shiftType: json['shift_type']?.toString(),
      entryDate: json['entry_date'] != null
          ? DateTime.tryParse(json['entry_date'].toString())
          : null,
    );
  }

  // Calculate hospital share (amount - doc share)
  double get hospitalShare => amount - docShare;

  // Check if this is a consultation
  bool get isConsultation => opdService?.toLowerCase() == 'consultation';

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
      'opd_service': opdService,
      'service_detail': serviceDetail,
      'amount': amount,
      'doc_share': docShare,
      'shift_id': shiftId,
      'shift_type': shiftType,
      'entry_date': entryDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'OpdRecordModel(opdService: $opdService, serviceDetail: $serviceDetail, amount: $amount, docShare: $docShare, hospitalShare: $hospitalShare, shiftId: $shiftId, shiftType: $shiftType, entryDate: $entryDate)';
  }
}