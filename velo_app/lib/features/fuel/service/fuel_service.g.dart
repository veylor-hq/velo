// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fuelService)
final fuelServiceProvider = FuelServiceProvider._();

final class FuelServiceProvider
    extends $FunctionalProvider<FuelService, FuelService, FuelService>
    with $Provider<FuelService> {
  FuelServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fuelServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fuelServiceHash();

  @$internal
  @override
  $ProviderElement<FuelService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FuelService create(Ref ref) {
    return fuelService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FuelService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FuelService>(value),
    );
  }
}

String _$fuelServiceHash() => r'b01d665c52ee61b455dc6009b03a4d72cafa2067';
