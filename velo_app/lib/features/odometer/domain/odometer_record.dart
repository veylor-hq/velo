class OdometerRecord {
  final String id;
  final String carId;
  final String date;
  final int odometer;
  final String? notes;

  OdometerRecord({
    required this.id,
    required this.carId,
    required this.date,
    required this.odometer,
    this.notes,
  });

  factory OdometerRecord.fromJson(Map<String, dynamic> json) {
    return OdometerRecord(
      id: json['id'] ?? (json['_id'] is Map ? json['_id']['\$oid'] : json['_id']?.toString()) ?? '',
      carId: (json['car_id'] is Map ? json['car_id']['\$oid'] : json['car_id']?.toString()) ?? '',
      date: json['date'] as String,
      odometer: json['odometer'] as int,
      notes: json['notes'] as String?,
    );
  }
}
