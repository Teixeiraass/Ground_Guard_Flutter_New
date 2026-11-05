import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_preference_model.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_provider.dart';

final notificationPreferencesProvider =
    StateNotifierProvider<
      NotificationPreferencesNotifier,
      AsyncValue<List<NotificationPreferenceModel>>
    >((ref) {
      final repository = ref.watch(notificationsRepositoryProvider);
      return NotificationPreferencesNotifier(repository);
    });

class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<List<NotificationPreferenceModel>>> {
  final NotificationsRepository _repository;

  NotificationPreferencesNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    fetchPreferences();
  }

  Future<void> fetchPreferences() async {
    state = const AsyncValue.loading();
    try {
      final preferences = await _repository.getPreferences();
      if (!mounted) return;
      state = AsyncValue.data(preferences);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePreference(String type, bool enabled) async {
    final current = state.valueOrNull ?? [];
    final optimistic = current
        .map((p) => p.type == type ? p.copyWith(enabled: enabled) : p)
        .toList();
    state = AsyncValue.data(optimistic);

    try {
      await _repository.updatePreference(type, enabled);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }
}
