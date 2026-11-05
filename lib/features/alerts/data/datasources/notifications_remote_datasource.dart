import 'package:dio/dio.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<dynamic>> getNotifications();
  Future<Map<String, dynamic>> markAsRead(String uuid);
  Future<void> markAllAsRead();
  Future<List<dynamic>> getPreferences();
  Future<void> updatePreference(String type, bool enabled);
  Future<void> registerPushToken(String token, String platform);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getNotifications() async {
    final response = await _dio.get('/notifications');
    return response.data is List ? response.data as List<dynamic> : [];
  }

  @override
  Future<Map<String, dynamic>> markAsRead(String uuid) async {
    final response = await _dio.patch('/notifications/$uuid/read');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.patch('/notifications/read-all');
  }

  @override
  Future<List<dynamic>> getPreferences() async {
    final response = await _dio.get('/notification-preferences');
    return response.data is List ? response.data as List<dynamic> : [];
  }

  @override
  Future<void> updatePreference(String type, bool enabled) async {
    await _dio.put('/notification-preferences/$type', data: {'enabled': enabled});
  }

  @override
  Future<void> registerPushToken(String token, String platform) async {
    await _dio.post('/push-tokens', data: {'token': token, 'platform': platform});
  }
}
