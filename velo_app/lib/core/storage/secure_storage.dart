import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService([this._storage = const FlutterSecureStorage()]);

  static const _tokenKey = 'access_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> setServerUrl(String url) async {
    await _storage.write(key: 'custom_api_url', value: url.trim());
  }

  Future<String?> getServerUrl() async {
    return await _storage.read(key: 'custom_api_url');
  }
}
