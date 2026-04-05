// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_tab_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DefaultTabNotifier)
final defaultTabProvider = DefaultTabNotifierProvider._();

final class DefaultTabNotifierProvider
    extends $NotifierProvider<DefaultTabNotifier, int> {
  DefaultTabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultTabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultTabNotifierHash();

  @$internal
  @override
  DefaultTabNotifier create() => DefaultTabNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$defaultTabNotifierHash() =>
    r'96ec96dc8351a8a7feb1bc7b200f3712540bd8b9';

abstract class _$DefaultTabNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
