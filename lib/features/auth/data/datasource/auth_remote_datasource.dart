import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> register(Map<String, dynamic> userData);
  Future<String> refreshToken(String refreshToken);
  Future<List<dynamic>> getDevices();
  Future<void> linkDevice(String deviceId);
  Future<void> updateDeviceName(String deviceId, String name);
  Future<void> unlinkDevice(String deviceId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await _dio.post(
        '/users',
        data: userData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/tokens/refresh',
        data: {'refresh_token': refreshToken},
      );
      return response.data['access_token'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getDevices() async {
    try {
      final response = await _dio.get(
        '/devices',
        queryParameters: {
          'page_id': 1,
          'page_size': 10,
        },
      );
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> linkDevice(String deviceId) async {
    try {
      await _dio.put('/devices/link/$deviceId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDeviceName(String deviceId, String name) async {
    try {
      await _dio.put('/devices/name/$deviceId', data: {'name': name});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlinkDevice(String deviceId) async {
    try {
      // Endpoint para desvincular dispositivo: /devices/unlink/{uuid}
      await _dio.delete('/devices/unlink/$deviceId');
    } catch (e) {
      rethrow;
    }
  }
}
