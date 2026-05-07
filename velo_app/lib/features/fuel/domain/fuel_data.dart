import 'fuel_record.dart';

class FuelData {
  final List<FuelRecord> records;
  final double avgMpgUk;
  final double avgLPer100Km;
  final double totalSpend;
  final double totalFuel;

  FuelData({
    required this.records,
    required this.avgMpgUk,
    required this.avgLPer100Km,
    required this.totalSpend,
    required this.totalFuel,
  });

  factory FuelData.fromJson(Map<String, dynamic> json) {
    return FuelData(
      records: (json['records'] as List).map((e) => FuelRecord.fromJson(e as Map<String, dynamic>)).toList(),
      avgMpgUk: (json['avg_mpg_uk'] as num?)?.toDouble() ?? 0.0,
      avgLPer100Km: (json['avg_l_per_100km'] as num?)?.toDouble() ?? 0.0,
      totalSpend: (json['total_spend'] as num?)?.toDouble() ?? 0.0,
      totalFuel: (json['total_fuel'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
