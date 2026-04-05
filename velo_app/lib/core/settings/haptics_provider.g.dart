// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HapticsConfig)
final hapticsConfigProvider = HapticsConfigProvider._();

final class HapticsConfigProvider
    extends $NotifierProvider<HapticsConfig, bool> {
  HapticsConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticsConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticsConfigHash();

  @$internal
  @override
  HapticsConfig create() => HapticsConfig();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hapticsConfigHash() => r'7e82a94df9c620c0b0cc3845ddfea6cb3cac40e7';

abstract class _$HapticsConfig extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
