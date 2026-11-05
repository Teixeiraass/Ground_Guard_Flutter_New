import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../presentation/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final hasUnread = ref.watch(unreadNotificationsCountProvider) > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notificações'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).fetchNotifications(),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState();
            }
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (hasUnread)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => ref
                            .read(notificationsProvider.notifier)
                            .markAllAsRead(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Marcar todas como lidas',
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                ...notifications.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNotificationItem(context, ref, n),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Falha ao carregar notificações.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(notificationsProvider.notifier).fetchNotifications(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF4EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma notificação',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3520),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você ainda não tem notificações por aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    final icon = _iconFor(notification.type);
    final isUnread = !notification.isRead;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: isUnread
          ? () => ref
              .read(notificationsProvider.notifier)
              .markAsRead(notification.uuid)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isUnread
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: icon.$2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon.$1, color: icon.$3, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3520),
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _iconFor(String type) {
    switch (type) {
      case 'AUTO_IRRIGATION_START':
        return (Icons.water_drop_outlined, const Color(0xFFEFF4EA), Colors.green);
      case 'LOW_HUMIDITY':
        return (Icons.water_drop_outlined, const Color(0xFFFFF4E5), Colors.orange);
      case 'BATTERY_LOW':
        return (Icons.battery_alert_rounded, const Color(0xFFFFF4E5), Colors.brown);
      case 'PLATFORM_ANNOUNCEMENT':
        return (Icons.campaign_outlined, const Color(0xFFF5F5F5), Colors.blueGrey);
      case 'SUPPORT_REPLY':
        return (Icons.chat_bubble_outline_rounded, const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case 'FIRMWARE_UPDATE':
        return (Icons.system_update_rounded, const Color(0xFFE8F5E9), const Color(0xFF173518));
      default:
        return (Icons.notifications_none_rounded, const Color(0xFFF5F5F5), Colors.grey);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays == 1) return 'Ontem, ${DateFormat('HH:mm').format(dateTime)}';
    return DateFormat('dd/MM, HH:mm').format(dateTime);
  }
}
