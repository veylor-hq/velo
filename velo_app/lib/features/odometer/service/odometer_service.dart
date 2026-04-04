import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/odometer_record.dart';

part 'odometer_service.g.dart';

class OdometerService {
  final Dio _dio;
  OdometerService(this._dio);

  Future<List<OdometerRecord>> getRecords(String carId) async {
    final response = await _dio.get('/api/private/car/$carId/odometer/');
    final list = response.data as List;
    return list.map((e) => OdometerRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OdometerRecord> createRecord(String carId, Map<String, dynamic> data) async {
    final response = await _dio.post('/api/private/car/$carId/odometer/', data: data);
    return OdometerRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OdometerRecord> updateRecord(String carId, String recordId, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/private/car/$carId/odometer/$recordId', data: data);
    return OdometerRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteRecord(String carId, String recordId) async {
    await _dio.delete('/api/private/car/$carId/odometer/$recordId');
  }
}

@riverpod
OdometerService odometerService(Ref ref) {
  return OdometerService(ref.watch(dioProvider));
}
