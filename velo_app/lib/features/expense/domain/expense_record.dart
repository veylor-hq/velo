class ExpenseRecord {
  final String id;
  final String carId;
  final String date;
  final double amount;
  final String type;
  final String? notes;
  final String? photoUrl;

  ExpenseRecord({
    required this.id,
    required this.carId,
    required this.date,
    required this.amount,
    this.type = 'other',
    this.notes,
    this.photoUrl,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseRecord(
      id: json['id']?.toString() ?? (json['_id'] is Map ? json['_id']['\$oid'] : json['_id']?.toString()) ?? '',
      carId: (json['car_id'] is Map ? json['car_id']['\$oid'] : json['car_id']?.toString()) ?? '',
      date: json['date'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'other',
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
