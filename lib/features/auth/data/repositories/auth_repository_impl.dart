import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/api_exception.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _remoteDataSource.login(request);
      
      await SecureStorageService.saveAccessToken(response.accessToken);
      await SecureStorageService.saveRefreshToken(response.refreshToken);
      await SecureStorageService.saveUser(response.user);
      
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.register({
        'username': username,
        'full_name': fullName,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final newAccessToken = await _remoteDataSource.refreshToken(refreshToken);
      await SecureStorageService.saveAccessToken(newAccessToken);
      return newAccessToken;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    await SecureStorageService.clear();
  }
}
