import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';

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

  static Future<void> saveSessionId(String sessionId) async {
    await _storage.write(
      key: 'session_id',
      value: sessionId,
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

  static Future<String?> getSessionId() async {
    return _storage.read(key: 'session_id');
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

  // Biometric Login Helper
  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: 'saved_email', value: email);
    await _storage.write(key: 'saved_password', value: password);
  }

  static Future<Map<String, String>?> getSavedCredentials() async {
    final email = await _storage.read(key: 'saved_email');
    final password = await _storage.read(key: 'saved_password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  static Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: 'biometrics_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricsEnabled() async {
    final enabled = await _storage.read(key: 'biometrics_enabled');
    return enabled == 'true';
  }
}
