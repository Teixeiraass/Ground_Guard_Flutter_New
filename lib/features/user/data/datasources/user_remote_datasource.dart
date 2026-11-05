import 'package:dio/dio.dart';

abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile();
  Future<void> updateUserName(String fullName);
  Future<void> updateProfileImage(String filePath);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String password);
  Future<void> resendVerificationEmail();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserName(String fullName) async {
    try {
      await _dio.put('/users/name', data: {'full_name': fullName});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfileImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      await _dio.put('/users/profile-image', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _dio.put(
        '/users/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      await _dio.delete('/users/me', data: {'password': password});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      await _dio.post('/users/verify-email/resend');
    } catch (e) {
      rethrow;
    }
  }
}
