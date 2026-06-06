import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ground_guard_app/features/user/presentation/providers/user_provider.dart';
import 'package:ground_guard_app/features/weather/presentation/providers/weather_provider.dart';
import 'package:ground_guard_app/features/weather/data/models/weather_model.dart';
import 'package:ground_guard_app/components/user_avatar.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProvider.notifier).fetchUserProfile();
          await ref.read(weatherProvider.notifier).fetchWeather('São Paulo');
        },
        child: userAsync.when(
          data: (user) => _buildProfileContent(context, ref, user, weatherAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildErrorState(context, ref, err),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserModel user, AsyncValue<WeatherModel> weatherAsync) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 20),
          _buildMenu(context, ref),
          const SizedBox(height: 20),
          _buildWeatherForecastSection(weatherAsync),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Erro ao carregar perfil'),
          TextButton(
            onPressed: () => ref.read(userProvider.notifier).fetchUserProfile(),
            child: const Text('Tentar novamente'),
          )
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                user: user,
                radius: 52,
                showBorder: true,
              ),
              Positioned(
                bottom: -4,
                right: -2,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5B544),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.edit, size: 18, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D3520),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _statusCard(
                  icon: Icons.eco,
                  iconColor: const Color(0xFF9FC88F),
                  title: 'Saúde do Solo',
                  value: 'Excelente',
                  valueColor: const Color(0xFF274029),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statusCard(
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
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _menuItem(
          icon: Icons.person_outline,
          title: 'Editar Perfil',
          onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
        ),
        _menuItem(
          icon: Icons.wifi_tethering_rounded,
          title: 'Meus Dispositivos IoT',
          onTap: () => Navigator.pushNamed(context, AppRoutes.devicesList),
        ),
        _menuItem(icon: Icons.water_drop_outlined, title: 'Preferências de Irrigação'),
        _menuItem(icon: Icons.notifications_none_rounded, title: 'Notificações'),
        _menuItem(icon: Icons.help_outline_rounded, title: 'Ajuda e Suporte'),
        const SizedBox(height: 14),
        InkWell(
          onTap: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Sair',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherForecastSection(AsyncValue<WeatherModel> weatherAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: weatherAsync.when(
        data: (weather) => Row(
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
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°C ${weather.description}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF274029)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getWeatherTip(weather.condition),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            _getWeatherIcon(weather.condition, weather.iconCode),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Text('Não foi possível carregar a previsão.'),
      ),
    );
  }

  String _getWeatherTip(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear': return 'Ótimo dia para regar suas plantas!';
      case 'clouds': return 'Céu nublado. Verifique a umidade do solo.';
      case 'rain': case 'drizzle': return 'Chovendo. Economize água hoje!';
      case 'thunderstorm': return 'Tempestade! Proteja as plantas sensíveis.';
      default: return 'Fique de olho no clima para sua horta.';
    }
  }

  Widget _getWeatherIcon(String condition, String iconCode) {
    IconData iconData;
    Color iconColor;

    switch (condition.toLowerCase()) {
      case 'clear':
        iconData = Icons.wb_sunny_rounded;
        iconColor = const Color(0xFFF5B544);
        break;
      case 'clouds':
        iconData = Icons.cloud_rounded;
        iconColor = Colors.grey.shade400;
        break;
      case 'rain':
      case 'drizzle':
        iconData = Icons.umbrella_rounded;
        iconColor = Colors.blue.shade300;
        break;
      case 'thunderstorm':
        iconData = Icons.thunderstorm_rounded;
        iconColor = Colors.deepPurple.shade300;
        break;
      case 'snow':
        iconData = Icons.ac_unit_rounded;
        iconColor = Colors.blue.shade100;
        break;
      case 'mist':
      case 'fog':
      case 'smoke':
      case 'haze':
        iconData = Icons.filter_drama_rounded;
        iconColor = Colors.grey.shade300;
        break;
      default:
        iconData = Icons.wb_cloudy_rounded;
        iconColor = Colors.orange.shade200;
    }

    return Icon(iconData, size: 52, color: iconColor);
  }

  Widget _statusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F6), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFEFF4EA), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF274029)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
