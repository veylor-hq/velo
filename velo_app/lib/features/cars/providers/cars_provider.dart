import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/car.dart';
import '../service/car_service.dart';

part 'cars_provider.g.dart';

@Riverpod(keepAlive: true)
class Cars extends _$Cars {
  @override
  FutureOr<List<Car>> build() async {
    return ref.watch(carServiceProvider).getCars();
  }

  Future<void> refreshCars() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(carServiceProvider).getCars());
  }
}

@riverpod
Future<Car> currentCar(Ref ref, String id) {
  return ref.watch(carServiceProvider).getCar(id);
}
