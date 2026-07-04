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
      await SecureStorageService.saveSessionId(response.sessionId);
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
    try {
      final sessionId = await SecureStorageService.getSessionId();
      if (sessionId != null) {
        await _remoteDataSource.logout(sessionId);
      }
    } finally {
      await SecureStorageService.clear();
    }
  }

  @override
  Future<bool> hasDevices() async {
    // This could be moved to a DevicesRepository if appropriate, 
    // but adding it here as per the interface requirement.
    return false; // Default or actual implementation
  }

  @override
  Future<LoginResponse> oauthLogin(String provider, String idToken) async {
    try {
      final response = await _remoteDataSource.oauthLogin(provider, idToken);

      await SecureStorageService.saveAccessToken(response.accessToken);
      await SecureStorageService.saveRefreshToken(response.refreshToken);
      await SecureStorageService.saveSessionId(response.sessionId);
      await SecureStorageService.saveUser(response.user);

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
