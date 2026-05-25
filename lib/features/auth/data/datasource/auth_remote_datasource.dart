import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> register(Map<String, dynamic> userData);
  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // IMPORTANTE: Use apenas o caminho relativo para respeitar a baseUrl do Dio
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
}
