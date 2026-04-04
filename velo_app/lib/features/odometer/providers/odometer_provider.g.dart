// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'odometer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OdometerRecords)
final odometerRecordsProvider = OdometerRecordsFamily._();

final class OdometerRecordsProvider
    extends $AsyncNotifierProvider<OdometerRecords, List<OdometerRecord>> {
  OdometerRecordsProvider._({
    required OdometerRecordsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'odometerRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$odometerRecordsHash();

  @override
  String toString() {
    return r'odometerRecordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OdometerRecords create() => OdometerRecords();

  @override
  bool operator ==(Object other) {
    return other is OdometerRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$odometerRecordsHash() => r'f0af8bf28ff2779b4a16e72ac9f4abaf33f3266b';

final class OdometerRecordsFamily extends $Family
    with
        $ClassFamilyOverride<
          OdometerRecords,
          AsyncValue<List<OdometerRecord>>,
          List<OdometerRecord>,
          FutureOr<List<OdometerRecord>>,
          String
        > {
  OdometerRecordsFamily._()
    : super(
        retry: null,
        name: r'odometerRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OdometerRecordsProvider call(String carId) =>
      OdometerRecordsProvider._(argument: carId, from: this);

  @override
  String toString() => r'odometerRecordsProvider';
}

abstract class _$OdometerRecords extends $AsyncNotifier<List<OdometerRecord>> {
  late final _$args = ref.$arg as String;
  String get carId => _$args;

  FutureOr<List<OdometerRecord>> build(String carId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<OdometerRecord>>, List<OdometerRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<OdometerRecord>>,
                List<OdometerRecord>
              >,
              AsyncValue<List<OdometerRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
