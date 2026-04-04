import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/odometer_record.dart';
import '../service/odometer_service.dart';

part 'odometer_provider.g.dart';

@riverpod
class OdometerRecords extends _$OdometerRecords {
  @override
  FutureOr<List<OdometerRecord>> build(String carId) async {
    return ref.watch(odometerServiceProvider).getRecords(carId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(odometerServiceProvider).getRecords(carId));
  }
}
