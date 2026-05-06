import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/service_record.dart';

final serviceServiceProvider = Provider((ref) => ServiceService(ref.watch(dioProvider)));

class ServiceService {
  final Dio _dio;

  ServiceService(this._dio);

  Future<List<ServiceRecord>> getServiceRecords(String carId) async {
    final response = await _dio.get('/api/private/service/', queryParameters: {'car_id': carId});
    final List data = response.data;
    return data.map((json) => ServiceRecord.fromJson(json)).toList();
  }

  Future<void> createServiceRecord({required String carId, required Map<String, dynamic> data}) async {
    await _dio.post('/api/private/service/', queryParameters: {'car_id': carId}, data: data);
  }

  Future<void> updateServiceRecord({required String carId, required String recordId, required Map<String, dynamic> data}) async {
    await _dio.patch('/api/private/service/$recordId', queryParameters: {'car_id': carId}, data: data);
  }

  Future<void> deleteServiceRecord(String carId, String recordId) async {
    await _dio.delete('/api/private/service/$recordId', queryParameters: {'car_id': carId});
  }
}
