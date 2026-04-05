import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/supply_record.dart';
import '../service/supply_service.dart';

part 'supply_provider.g.dart';

@Riverpod(keepAlive: true)
class SupplyRecords extends _$SupplyRecords {
  @override
  FutureOr<List<SupplyRecord>> build() async {
    return ref.watch(supplyServiceProvider).getRecords();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(supplyServiceProvider).getRecords());
  }
}
