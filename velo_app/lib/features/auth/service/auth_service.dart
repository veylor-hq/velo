import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

part 'auth_service.g.dart';

class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthService(this._dio, this._storage);

  Future<void> signUp(String email, String password) async {
    await _dio.post('/api/public/auth/signup', data: {
      'email': email,
      'password': password,
    });
  }

  Future<String> signIn(String email, String password) async {
    final response = await _dio.post('/api/public/auth/signin', data: {
      'email': email,
      'password': password,
    });

    final data = response.data as Map<String, dynamic>;
    if (data['ok'] == true && data['access_token'] != null) {
      final token = data['access_token'] as String;
      await _storage.saveToken(token);
      return token;
    } else {
      throw Exception('Invalid sign in response');
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post('/api/public/auth/logout');
    } catch (_) {
      // Ignore errors if the token is already invalid
    } finally {
      await _storage.deleteToken();
    }
  }

  Future<void> verify() async {
    await _dio.get('/api/public/auth/verify');
  }
}

@riverpod
AuthService authService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio, const SecureStorageService());
}
