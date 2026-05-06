import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/service_record.dart';
import '../service/service_service.dart';

part 'service_provider.g.dart';

@Riverpod(keepAlive: true)
class ServiceRecords extends _$ServiceRecords {
  @override
  FutureOr<List<ServiceRecord>> build(String carId) async {
    return _fetch();
  }

  Future<List<ServiceRecord>> _fetch() async {
    final service = ref.read(serviceServiceProvider);
    return await service.getServiceRecords(carId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}
