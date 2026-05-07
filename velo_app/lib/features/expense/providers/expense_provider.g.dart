// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpenseRecords)
final expenseRecordsProvider = ExpenseRecordsFamily._();

final class ExpenseRecordsProvider
    extends $AsyncNotifierProvider<ExpenseRecords, List<ExpenseRecord>> {
  ExpenseRecordsProvider._({
    required ExpenseRecordsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expenseRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseRecordsHash();

  @override
  String toString() {
    return r'expenseRecordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExpenseRecords create() => ExpenseRecords();

  @override
  bool operator ==(Object other) {
    return other is ExpenseRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseRecordsHash() => r'253ad241aa6ca89351f56de922185b984a53218b';

final class ExpenseRecordsFamily extends $Family
    with
        $ClassFamilyOverride<
          ExpenseRecords,
          AsyncValue<List<ExpenseRecord>>,
          List<ExpenseRecord>,
          FutureOr<List<ExpenseRecord>>,
          String
        > {
  ExpenseRecordsFamily._()
    : super(
        retry: null,
        name: r'expenseRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseRecordsProvider call(String carId) =>
      ExpenseRecordsProvider._(argument: carId, from: this);

  @override
  String toString() => r'expenseRecordsProvider';
}

abstract class _$ExpenseRecords extends $AsyncNotifier<List<ExpenseRecord>> {
  late final _$args = ref.$arg as String;
  String get carId => _$args;

  FutureOr<List<ExpenseRecord>> build(String carId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ExpenseRecord>>, List<ExpenseRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ExpenseRecord>>, List<ExpenseRecord>>,
              AsyncValue<List<ExpenseRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
