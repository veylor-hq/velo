import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/expense_record.dart';

part 'expense_service.g.dart';

class ExpenseService {
  final Dio _dio;
  ExpenseService(this._dio);

  Future<List<ExpenseRecord>> getExpenseRecords(String carId) async {
    final response = await _dio.get('/api/private/expense/', queryParameters: {'car_id': carId});
    return (response.data as List).map((e) => ExpenseRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExpenseRecord> createExpenseRecord({
    required String carId,
    required Map<String, dynamic> data,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      'data': jsonEncode(data),
      if (photoPath != null) 'photo': await MultipartFile.fromFile(photoPath),
    });

    final response = await _dio.post('/api/private/expense/', queryParameters: {'car_id': carId}, data: formData);
    return ExpenseRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ExpenseRecord> updateExpenseRecord({
    required String carId,
    required String recordId,
    Map<String, dynamic>? data,
    String? photoPath,
  }) async {
    final Map<String, dynamic> formMap = {};
    if (data != null && data.isNotEmpty) {
      formMap['data'] = jsonEncode(data);
    }
    if (photoPath != null) {
      formMap['photo'] = await MultipartFile.fromFile(photoPath);
    }

    final formData = FormData.fromMap(formMap);
    final response = await _dio.patch('/api/private/expense/$recordId', queryParameters: {'car_id': carId}, data: formData);
    return ExpenseRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteExpenseRecord(String carId, String recordId) async {
    await _dio.delete('/api/private/expense/$recordId', queryParameters: {'car_id': carId});
  }
}

@riverpod
ExpenseService expenseService(Ref ref) {
  return ExpenseService(ref.watch(dioProvider));
}
