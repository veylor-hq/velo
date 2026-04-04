// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'odometer_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(odometerService)
final odometerServiceProvider = OdometerServiceProvider._();

final class OdometerServiceProvider
    extends
        $FunctionalProvider<OdometerService, OdometerService, OdometerService>
    with $Provider<OdometerService> {
  OdometerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'odometerServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$odometerServiceHash();

  @$internal
  @override
  $ProviderElement<OdometerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OdometerService create(Ref ref) {
    return odometerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OdometerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OdometerService>(value),
    );
  }
}

String _$odometerServiceHash() => r'a5ad4612b6392c30cc5b72ee356740cc9895046b';
