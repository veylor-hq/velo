import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/expense_record.dart';
import '../service/expense_service.dart';

part 'expense_provider.g.dart';

@riverpod
class ExpenseRecords extends _$ExpenseRecords {
  @override
  FutureOr<List<ExpenseRecord>> build(String carId) async {
    return _fetch();
  }

  Future<List<ExpenseRecord>> _fetch() async {
    return ref.read(expenseServiceProvider).getExpenseRecords(carId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}
