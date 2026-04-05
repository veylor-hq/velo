// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cars_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Cars)
final carsProvider = CarsProvider._();

final class CarsProvider extends $AsyncNotifierProvider<Cars, List<Car>> {
  CarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carsHash();

  @$internal
  @override
  Cars create() => Cars();
}

String _$carsHash() => r'f98c34c8aad0869c9b855aa934ae809ae9a491ed';

abstract class _$Cars extends $AsyncNotifier<List<Car>> {
  FutureOr<List<Car>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Car>>, List<Car>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Car>>, List<Car>>,
              AsyncValue<List<Car>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(currentCar)
final currentCarProvider = CurrentCarFamily._();

final class CurrentCarProvider
    extends $FunctionalProvider<AsyncValue<Car>, Car, FutureOr<Car>>
    with $FutureModifier<Car>, $FutureProvider<Car> {
  CurrentCarProvider._({
    required CurrentCarFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentCarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentCarHash();

  @override
  String toString() {
    return r'currentCarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Car> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Car> create(Ref ref) {
    final argument = this.argument as String;
    return currentCar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentCarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentCarHash() => r'8557c70328c5a274ffb7b8b6f93c81a1abbd2508';

final class CurrentCarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Car>, String> {
  CurrentCarFamily._()
    : super(
        retry: null,
        name: r'currentCarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentCarProvider call(String id) =>
      CurrentCarProvider._(argument: id, from: this);

  @override
  String toString() => r'currentCarProvider';
}
