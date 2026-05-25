import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_routes.dart';
import '../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const CircleAvatar(
                                  radius: 52,
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/300',
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -4,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5B544),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user?.fullName ?? 'Carregando...',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D3520),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: statusCard(
                                  icon: Icons.eco,
                                  iconColor: const Color(0xFF9FC88F),
                                  title: 'Saúde do Solo',
                                  value: 'Excelente',
                                  valueColor: const Color(0xFF274029),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: statusCard(
                                  icon: Icons.water_drop_outlined,
                                  iconColor: const Color(0xFF9C6A00),
                                  title: 'Nível de Água',
                                  value: '85%',
                                  valueColor: const Color(0xFF9C6A00),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    menuItem(
                      icon: Icons.person_outline,
                      title: 'Editar Perfil',
                    ),
                    menuItem(
                      icon: Icons.wifi_tethering_rounded,
                      title: 'Meus Dispositivos IoT',
                    ),
                    menuItem(
                      icon: Icons.water_drop_outlined,
                      title: 'Preferências de Irrigação',
                    ),
                    menuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notificações',
                    ),
                    menuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Ajuda e Suporte',
                    ),
                    const SizedBox(height: 14),
                    
                    // BOTÃO SAIR COM LÓGICA
                    InkWell(
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Sair',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PREVISÃO LOCAL',
                                  style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '24°C ensolarado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF274029),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nenhuma chuva prevista para hoje.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.wb_sunny_rounded,
                            size: 52,
                            color: Color(0xFF9C6A00),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF274029),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
