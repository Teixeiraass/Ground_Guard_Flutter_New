import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final data = await _remoteDataSource.getNotifications();
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<NotificationModel> markAsRead(String uuid) async {
    try {
      final data = await _remoteDataSource.markAsRead(uuid);
      return NotificationModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<NotificationPreferenceModel>> getPreferences() async {
    try {
      final data = await _remoteDataSource.getPreferences();
      return data
          .map((json) => NotificationPreferenceModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updatePreference(String type, bool enabled) async {
    try {
      await _remoteDataSource.updatePreference(type, enabled);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> registerPushToken(String token, String platform) async {
    try {
      await _remoteDataSource.registerPushToken(token, platform);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
