// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceRecords)
final serviceRecordsProvider = ServiceRecordsFamily._();

final class ServiceRecordsProvider
    extends $AsyncNotifierProvider<ServiceRecords, List<ServiceRecord>> {
  ServiceRecordsProvider._({
    required ServiceRecordsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serviceRecordsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceRecordsHash();

  @override
  String toString() {
    return r'serviceRecordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ServiceRecords create() => ServiceRecords();

  @override
  bool operator ==(Object other) {
    return other is ServiceRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceRecordsHash() => r'22e4300a091a7cf323fdd6c165d4281bd1f365fc';

final class ServiceRecordsFamily extends $Family
    with
        $ClassFamilyOverride<
          ServiceRecords,
          AsyncValue<List<ServiceRecord>>,
          List<ServiceRecord>,
          FutureOr<List<ServiceRecord>>,
          String
        > {
  ServiceRecordsFamily._()
    : super(
        retry: null,
        name: r'serviceRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ServiceRecordsProvider call(String carId) =>
      ServiceRecordsProvider._(argument: carId, from: this);

  @override
  String toString() => r'serviceRecordsProvider';
}

abstract class _$ServiceRecords extends $AsyncNotifier<List<ServiceRecord>> {
  late final _$args = ref.$arg as String;
  String get carId => _$args;

  FutureOr<List<ServiceRecord>> build(String carId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ServiceRecord>>, List<ServiceRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ServiceRecord>>, List<ServiceRecord>>,
              AsyncValue<List<ServiceRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
