class SupplyRecord {
  final String id;
  final String? partNumber;
  final String name;
  final int quantity;
  final double pricePerUnit;
  final bool isTool;
  final String? vendor;
  final String? notes;
  final String? date;

  SupplyRecord({
    required this.id,
    this.partNumber,
    required this.name,
    required this.quantity,
    required this.pricePerUnit,
    required this.isTool,
    this.vendor,
    this.notes,
    this.date,
  });

  factory SupplyRecord.fromJson(Map<String, dynamic> json) {
    return SupplyRecord(
      id: json['id'] ?? (json['_id'] is Map ? json['_id']['\$oid'] : json['_id']?.toString()) ?? '',
      partNumber: json['part_number'] as String?,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 0,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      isTool: json['is_tool'] as bool? ?? false,
      vendor: json['vendor'] as String?,
      notes: json['notes'] as String?,
      date: json['date'] as String?,
    );
  }
}
