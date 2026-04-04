// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(carService)
final carServiceProvider = CarServiceProvider._();

final class CarServiceProvider
    extends $FunctionalProvider<CarService, CarService, CarService>
    with $Provider<CarService> {
  CarServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carServiceHash();

  @$internal
  @override
  $ProviderElement<CarService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CarService create(Ref ref) {
    return carService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CarService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CarService>(value),
    );
  }
}

String _$carServiceHash() => r'921de9f82dbb3413066fdbaa856d5010175b87bd';
