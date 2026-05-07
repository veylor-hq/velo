class GarageStats {
  final double totalSpent;
  final double totalFuelCost;
  final double totalServices;
  final double totalExpenses;
  final Map<String, double> distanceByUnit;
  final Map<String, double> fuelAmountByUnit;

  GarageStats({
    required this.totalSpent,
    required this.totalFuelCost,
    required this.totalServices,
    required this.totalExpenses,
    required this.distanceByUnit,
    required this.fuelAmountByUnit,
  });

  factory GarageStats.fromJson(Map<String, dynamic> json) {
    return GarageStats(
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      totalFuelCost: (json['total_fuel_cost'] as num?)?.toDouble() ?? 0.0,
      totalServices: (json['total_services'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      distanceByUnit: (json['distance_by_unit'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      fuelAmountByUnit: (json['fuel_amount_by_unit'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
    );
  }
}
