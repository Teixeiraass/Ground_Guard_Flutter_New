import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_preference_model.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationPreferencesPage extends ConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Preferências de Notificação'),
        centerTitle: true,
      ),
      body: preferencesAsync.when(
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Escolha quais notificações automáticas você quer receber.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ...preferences.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPreferenceCard(context, ref, p),
              ),
            ),
          ],
        ),
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
                'Falha ao carregar preferências.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref
                    .read(notificationPreferencesProvider.notifier)
                    .fetchPreferences(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferenceModel preference,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificationTypeLabel(preference.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1D3520),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notificationTypeDescription(preference.type),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: preference.enabled,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: (value) async {
              try {
                await ref
                    .read(notificationPreferencesProvider.notifier)
                    .updatePreference(preference.type, value);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao salvar: ${e.toString().replaceAll("Exception: ", "")}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
