import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../devices/data/models/device_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

  @override
  Future<bool> hasDevices() async {
    try {
      final devices = await _remoteDataSource.getDevices();
      return devices.isNotEmpty;
    } catch (e) {
      // Em check de background, falhar silenciosamente para não travar o app
      return true; 
    }
  }

  @override
  Future<List<DeviceModel>> getDevicesList() async {
    try {
      final List<dynamic> data = await _remoteDataSource.getDevices();
      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> linkDevice(String deviceId) async {
    try {
      await _remoteDataSource.linkDevice(deviceId);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateDeviceName(String deviceId, String name) async {
    try {
      await _remoteDataSource.updateDeviceName(deviceId, name);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
