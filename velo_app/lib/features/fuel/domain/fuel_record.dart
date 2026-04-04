class FuelRecord {
  final String id;
  final String carId;
  final String date;
  final int odometer;
  final double fuelAmount;
  final double pricePerUnit;
  final double totalCost;
  final bool isFullTank;
  final bool skipMpgCalculation;
  final String? notes;
  final int? deltaMileage;

  FuelRecord({
    required this.id,
    required this.carId,
    required this.date,
    required this.odometer,
    required this.fuelAmount,
    required this.pricePerUnit,
    required this.totalCost,
    required this.isFullTank,
    required this.skipMpgCalculation,
    this.notes,
    this.deltaMileage,
  });

  factory FuelRecord.fromJson(Map<String, dynamic> json) {
    return FuelRecord(
      id: json['id']?.toString() ?? (json['_id'] is Map ? json['_id']['\$oid'] : json['_id']?.toString()) ?? '',
      carId: (json['car_id'] is Map ? json['car_id']['\$oid'] : json['car_id']?.toString()) ?? '',
      date: json['date'] as String,
      odometer: json['odometer'] as int,
      fuelAmount: (json['fuel_amount'] as num).toDouble(),
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      isFullTank: json['is_full_tank'] as bool,
      skipMpgCalculation: json['skip_mpg_calculation'] as bool,
      notes: json['notes'] as String?,
      deltaMileage: json['delta_mileage'] as int?,
    );
  }
}
