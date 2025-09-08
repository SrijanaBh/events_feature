
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static final SecureStorageHelper _instance = SecureStorageHelper._internal();
  factory SecureStorageHelper() => _instance;
  SecureStorageHelper._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyUserId = 'user_id';
  static const String _keyToken = 'token';
  final int clubId = 222;
  final String guestToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2ODE1NDUxNjN9.D4TE2NW6u8IiLAIDDdONehwppGeeVGy-ZUn6pVngR-s';

  Future<void> setUserId(int userId) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
  }

  Future<int?> getUserId() async {
    final userId = await _storage.read(key: _keyUserId);
    return int.tryParse(userId ?? '');
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: _keyUserId);
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

