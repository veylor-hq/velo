import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/fuel_record.dart';

part 'fuel_service.g.dart';

class FuelService {
  final Dio _dio;
  FuelService(this._dio);

  Future<List<FuelRecord>> getFuelRecords(String carId) async {
    final response = await _dio.get('/api/private/car/$carId/fuel/');
    final list = response.data as List;
    return list.map((e) => FuelRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FuelRecord> createFuelRecord({
    required String carId,
    required Map<String, dynamic> data,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      'data': jsonEncode(data),
      if (photoPath != null) 'photo': await MultipartFile.fromFile(photoPath),
    });
    final response = await _dio.post('/api/private/car/$carId/fuel/', data: formData);
    return FuelRecord.fromJson(response.data['fuel_record'] as Map<String, dynamic>);
  }

  Future<FuelRecord> updateFuelRecord({
    required String carId,
    required String recordId,
    Map<String, dynamic>? data,
    String? photoPath,
  }) async {
    final Map<String, dynamic> map = {};
    if (data != null && data.isNotEmpty) map['data'] = jsonEncode(data);
    if (photoPath != null) map['photo'] = await MultipartFile.fromFile(photoPath);

    final formData = FormData.fromMap(map);
    final response = await _dio.patch('/api/private/car/$carId/fuel/$recordId', data: formData);
    return FuelRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteFuelRecord(String carId, String recordId) async {
    await _dio.delete('/api/private/car/$carId/fuel/$recordId');
  }
}

@riverpod
FuelService fuelService(Ref ref) {
  return FuelService(ref.watch(dioProvider));
}
