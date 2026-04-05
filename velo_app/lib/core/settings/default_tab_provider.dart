import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'default_tab_provider.g.dart';

@riverpod
class DefaultTabNotifier extends _$DefaultTabNotifier {
  @override
  int build() {
    _load();
    return 1; // Default to Fuel (Index 1)
  }

  Future<void> _load() async {
    final val = await const FlutterSecureStorage().read(key: 'default_car_tab');
    if (val != null) {
      state = int.tryParse(val) ?? 1;
    }
  }

  Future<void> setTab(int index) async {
    await const FlutterSecureStorage().write(key: 'default_car_tab', value: index.toString());
    state = index;
  }
}
