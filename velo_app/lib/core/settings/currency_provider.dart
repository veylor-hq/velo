import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'currency_provider.g.dart';

const _storage = FlutterSecureStorage();

@riverpod
class Currency extends _$Currency {
  @override
  String build() {
    _loadCurrency();
    return '£';
  }

  Future<void> _loadCurrency() async {
    final cur = await _storage.read(key: 'currency_symbol');
    if (cur != null && cur.isNotEmpty) {
      state = cur;
    }
  }

  Future<void> setCurrency(String symbol) async {
    await _storage.write(key: 'currency_symbol', value: symbol);
    state = symbol;
  }
}
