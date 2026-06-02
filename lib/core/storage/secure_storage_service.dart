import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/models/user_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: 'access_token',
      value: token,
    );
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: 'refresh_token',
      value: token,
    );
  }

  static Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: 'user_data',
      value: jsonEncode(user.toJson()),
    );
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: 'refresh_token');
  }

  static Future<UserModel?> getUser() async {
    final data = await _storage.read(key: 'user_data');
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
