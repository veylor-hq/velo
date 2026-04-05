// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FuelRecords)
final fuelRecordsProvider = FuelRecordsFamily._();

final class FuelRecordsProvider
    extends $AsyncNotifierProvider<FuelRecords, List<FuelRecord>> {
  FuelRecordsProvider._({
    required FuelRecordsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fuelRecordsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fuelRecordsHash();

  @override
  String toString() {
    return r'fuelRecordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FuelRecords create() => FuelRecords();

  @override
  bool operator ==(Object other) {
    return other is FuelRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fuelRecordsHash() => r'a7e1c8f17cb1fa3d1bb6ccb0e2d8e88dbb042db7';

final class FuelRecordsFamily extends $Family
    with
        $ClassFamilyOverride<
          FuelRecords,
          AsyncValue<List<FuelRecord>>,
          List<FuelRecord>,
          FutureOr<List<FuelRecord>>,
          String
        > {
  FuelRecordsFamily._()
    : super(
        retry: null,
        name: r'fuelRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FuelRecordsProvider call(String carId) =>
      FuelRecordsProvider._(argument: carId, from: this);

  @override
  String toString() => r'fuelRecordsProvider';
}

abstract class _$FuelRecords extends $AsyncNotifier<List<FuelRecord>> {
  late final _$args = ref.$arg as String;
  String get carId => _$args;

  FutureOr<List<FuelRecord>> build(String carId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FuelRecord>>, List<FuelRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FuelRecord>>, List<FuelRecord>>,
              AsyncValue<List<FuelRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
