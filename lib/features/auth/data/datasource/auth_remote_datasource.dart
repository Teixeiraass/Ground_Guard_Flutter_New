import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> register(Map<String, dynamic> userData);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout(String sessionId);
  Future<LoginResponse> oauthLogin(String provider, String idToken);
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
  Future<LoginResponse> oauthLogin(String provider, String idToken) async {
    try {
      final response = await _dio.post(
        '/users/oauth/$provider',
        data: {'id_token': idToken},
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
  Future<void> logout(String sessionId) async {
    try {
      await _dio.post(
        '/users/logout',
        data: {'session_id': sessionId},
      );
    } catch (e) {
      rethrow;
    }
  }
}
