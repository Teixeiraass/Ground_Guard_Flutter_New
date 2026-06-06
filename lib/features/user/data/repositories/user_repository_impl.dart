import 'package:dio/dio.dart';
import 'package:ground_guard_app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';
import 'package:ground_guard_app/features/user/domain/repositories/user_repository.dart';
import 'package:ground_guard_app/core/network/api_exception.dart';
import 'package:ground_guard_app/core/storage/secure_storage_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final data = await _remoteDataSource.getUserProfile();
      final user = UserModel.fromJson(data);
      await SecureStorageService.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateUserName(String uuid, String fullName) async {
    try {
      await _remoteDataSource.updateUserName(uuid, fullName);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateProfileImage(String filePath) async {
    try {
      await _remoteDataSource.updateProfileImage(filePath);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
