import '../../data/models/notification_model.dart';
import '../../data/models/notification_preference_model.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> markAsRead(String uuid);
  Future<void> markAllAsRead();
  Future<List<NotificationPreferenceModel>> getPreferences();
  Future<void> updatePreference(String type, bool enabled);
  Future<void> registerPushToken(String token, String platform);
}
