import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/websocket/websocket_message.dart';
import '../../../../core/websocket/websocket_provider.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return NotificationsRemoteDataSourceImpl(dio);
    });

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(notificationsRemoteDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource);
});

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((
      ref,
    ) {
      final repository = ref.watch(notificationsRepositoryProvider);
      return NotificationsNotifier(repository, ref);
    });

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationsRepository _repository;
  final Ref _ref;

  NotificationsNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<WebSocketMessage>>(webSocketMessagesProvider, (
      previous,
      next,
    ) {
      final message = next.valueOrNull;
      if (message == null || message.type != 'notification_created') return;
      _prependFromMessage(message);
    });
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotifications();
      if (!mounted) return;
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  void _prependFromMessage(WebSocketMessage message) {
    if (message.notificationUuid == null) return;
    final current = state.valueOrNull ?? [];
    if (current.any((n) => n.uuid == message.notificationUuid)) return;

    final notification = NotificationModel(
      uuid: message.notificationUuid!,
      type: message.notificationType ?? '',
      source: 'SYSTEM',
      title: message.title ?? '',
      body: message.body ?? '',
      createdAt: DateTime.now(),
    );
    state = AsyncValue.data([notification, ...current]);
  }

  Future<void> markAsRead(String uuid) async {
    try {
      final updated = await _repository.markAsRead(uuid);
      if (!mounted) return;
      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.map((n) => n.uuid == uuid ? updated : n).toList(),
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await fetchNotifications();
    } catch (e) {
      rethrow;
    }
  }
}
