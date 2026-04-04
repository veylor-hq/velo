// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supplyService)
final supplyServiceProvider = SupplyServiceProvider._();

final class SupplyServiceProvider
    extends $FunctionalProvider<SupplyService, SupplyService, SupplyService>
    with $Provider<SupplyService> {
  SupplyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplyServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplyServiceHash();

  @$internal
  @override
  $ProviderElement<SupplyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupplyService create(Ref ref) {
    return supplyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupplyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupplyService>(value),
    );
  }
}

String _$supplyServiceHash() => r'005576619f16b4f86690f5f2ea616a47121630cf';
