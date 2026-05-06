class ServiceSupplyItem {
  final String supplyId;
  final String name;
  final int quantity;
  final double pricePerUnit;

  ServiceSupplyItem({required this.supplyId, required this.name, required this.quantity, this.pricePerUnit = 0.0});

  factory ServiceSupplyItem.fromJson(Map<String, dynamic> json) {
    return ServiceSupplyItem(
      supplyId: (json['supply_id'] is Map ? json['supply_id']['\$oid'] : json['supply_id']?.toString()) ?? '',
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supply_id': supplyId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
    };
  }
}

class ServiceRecord {
  final String id;
  final String carId;
  final String date;
  final int odometer;
  final double totalCost;
  final String? notes;
  final List<ServiceSupplyItem> suppliesUsed;

  ServiceRecord({
    required this.id,
    required this.carId,
    required this.date,
    required this.odometer,
    required this.totalCost,
    this.notes,
    required this.suppliesUsed,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id']?.toString() ?? (json['_id'] is Map ? json['_id']['\$oid'] : json['_id']?.toString()) ?? '',
      carId: (json['car_id'] is Map ? json['car_id']['\$oid'] : json['car_id']?.toString()) ?? '',
      date: json['date'] as String,
      odometer: json['odometer'] as int,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      suppliesUsed: (json['supplies_used'] as List?)?.map((e) => ServiceSupplyItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
