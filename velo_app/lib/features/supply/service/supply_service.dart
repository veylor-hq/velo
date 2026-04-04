import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/supply_record.dart';

part 'supply_service.g.dart';

class SupplyService {
  final Dio _dio;
  SupplyService(this._dio);

  Future<List<SupplyRecord>> getRecords() async {
    final response = await _dio.get('/api/private/supply/');
    final list = response.data as List;
    return list.map((e) => SupplyRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SupplyRecord> createRecord(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/private/supply/', data: data);
    return SupplyRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SupplyRecord> updateRecord(String recordId, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/private/supply/$recordId', data: data);
    return SupplyRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteRecord(String recordId) async {
    await _dio.delete('/api/private/supply/$recordId');
  }
}

@riverpod
SupplyService supplyService(Ref ref) {
  return SupplyService(ref.watch(dioProvider));
}
