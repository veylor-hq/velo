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
    extends $AsyncNotifierProvider<DefaultTabNotifier, int> {
  DefaultTabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultTabNotifierHash();

  @$internal
  @override
  DefaultTabNotifier create() => DefaultTabNotifier();
}

String _$defaultTabNotifierHash() =>
    r'b162aa14cbced3e4b7e508d337cd88fa04bcd85c';

abstract class _$DefaultTabNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
