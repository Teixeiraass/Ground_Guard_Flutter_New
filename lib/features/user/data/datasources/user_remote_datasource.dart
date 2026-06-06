import 'package:dio/dio.dart';

abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile();
  Future<void> updateUserName(String uuid, String fullName);
  Future<void> updateProfileImage(String filePath);
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
  Future<void> updateUserName(String uuid, String fullName) async {
    try {
      await _dio.put('/users/name/$uuid', data: {'full_name': fullName});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfileImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      await _dio.put(
        '/users/profile-image',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
