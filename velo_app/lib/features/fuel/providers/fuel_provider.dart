import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/fuel_record.dart';
import '../domain/fuel_data.dart';
import '../service/fuel_service.dart';

part 'fuel_provider.g.dart';

@Riverpod(keepAlive: true)
class FuelRecords extends _$FuelRecords {
  @override
  FutureOr<FuelData> build(String carId) async {
    return ref.watch(fuelServiceProvider).getFuelRecords(carId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(fuelServiceProvider).getFuelRecords(carId));
  }
}
