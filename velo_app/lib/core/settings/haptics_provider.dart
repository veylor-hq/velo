import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'haptics_provider.g.dart';

@riverpod
class HapticsConfig extends _$HapticsConfig {
  @override
  bool build() {
    _load();
    return true; // Default to true
  }

  Future<void> _load() async {
    final val = await const FlutterSecureStorage().read(key: 'haptics_enabled');
    if (val != null) {
      state = val == 'true';
    }
  }

  Future<void> toggle(bool val) async {
    await const FlutterSecureStorage().write(key: 'haptics_enabled', value: val.toString());
    state = val;
  }

  void light() {
    if (state) HapticFeedback.lightImpact();
  }

  void medium() {
    if (state) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (state) HapticFeedback.heavyImpact();
  }

  void success() {
    if (state) {
      // Simulate a success double beat
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
    }
  }
}
