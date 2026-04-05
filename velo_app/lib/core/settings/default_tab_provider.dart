import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'default_tab_provider.g.dart';

@Riverpod(keepAlive: true)
class DefaultTabNotifier extends _$DefaultTabNotifier {
  @override
  Future<int> build() async {
    final val = await const FlutterSecureStorage().read(key: 'default_car_tab');
    return val != null ? (int.tryParse(val) ?? 1) : 1;
  }

  Future<void> setTab(int index) async {
    await const FlutterSecureStorage().write(key: 'default_car_tab', value: index.toString());
    state = AsyncData(index);
  }
}
