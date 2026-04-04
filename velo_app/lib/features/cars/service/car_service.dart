import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/car.dart';

part 'car_service.g.dart';

class CarService {
  final Dio _dio;

  CarService(this._dio);

  Future<List<Car>> getCars() async {
    final response = await _dio.get('/api/private/car/');
    final data = response.data as Map<String, dynamic>;
    final baseUrl = data['base_url'] as String;
    
    final carsList = data['cars'] as List;
    return carsList.map((c) {
      final json = c as Map<String, dynamic>;
      // Construct full photoUrl
      final photoFilename = json['photo_filename'] as String?;
      final photoUrl = photoFilename != null ? '$baseUrl$photoFilename' : null;
      json['photo_url'] = photoUrl;
      return Car.fromJson(json);
    }).toList();
  }

  Future<Car> getCar(String id) async {
    final response = await _dio.get('/api/private/car/$id');
    return Car.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Car> createCar({
    required Map<String, dynamic> data,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      'data': jsonEncode(data),
      if (photoPath != null)
        'photo': await MultipartFile.fromFile(photoPath),
    });

    final response = await _dio.post('/api/private/car/', data: formData);
    return Car.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Car> updateCar({
    required String id,
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
    final response = await _dio.patch('/api/private/car/$id', data: formData);
    return Car.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
CarService carService(Ref ref) {
  return CarService(ref.watch(dioProvider));
}
