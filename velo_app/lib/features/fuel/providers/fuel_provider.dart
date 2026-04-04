import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/fuel_record.dart';
import '../service/fuel_service.dart';

part 'fuel_provider.g.dart';

@riverpod
class FuelRecords extends _$FuelRecords {
  @override
  FutureOr<List<FuelRecord>> build(String carId) async {
    return ref.watch(fuelServiceProvider).getFuelRecords(carId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(fuelServiceProvider).getFuelRecords(carId));
  }
}
