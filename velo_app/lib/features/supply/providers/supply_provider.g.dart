// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SupplyRecords)
final supplyRecordsProvider = SupplyRecordsProvider._();

final class SupplyRecordsProvider
    extends $AsyncNotifierProvider<SupplyRecords, List<SupplyRecord>> {
  SupplyRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyRecordsHash();

  @$internal
  @override
  SupplyRecords create() => SupplyRecords();
}

String _$supplyRecordsHash() => r'2d78880ad9856a39a1380d6ea747df96f47a7e5c';

abstract class _$SupplyRecords extends $AsyncNotifier<List<SupplyRecord>> {
  FutureOr<List<SupplyRecord>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SupplyRecord>>, List<SupplyRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SupplyRecord>>, List<SupplyRecord>>,
              AsyncValue<List<SupplyRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
