import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/core/theme/app_spacing.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ground_guard_app/features/controllers/data/models/controller_device_model.dart';
import 'package:ground_guard_app/features/controllers/presentation/providers/controllers_provider.dart';
import 'package:ground_guard_app/features/devices/data/models/device_model.dart';
import 'package:ground_guard_app/features/devices/presentation/providers/devices_provider.dart';
import 'package:ground_guard_app/features/devices/presentation/providers/all_devices_provider.dart';
import 'package:ground_guard_app/features/firmware/data/controller_firmware_model.dart';
import 'package:ground_guard_app/features/firmware/presentation/firmware_provider.dart';
import 'package:ground_guard_app/features/soil_health/presentation/soil_health_provider.dart';
import 'package:ground_guard_app/features/soil_health/presentation/soil_health_ui.dart';
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
          ref.invalidate(soilHealthProvider);
          await ref.read(userProvider.notifier).fetchUserProfile();
          await ref.read(weatherProvider.notifier).fetchWeather();
        },
        child: userAsync.when(
          data: (user) =>
              _buildProfileContent(context, ref, user, weatherAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildErrorState(context, ref, err),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AsyncValue<WeatherModel> weatherAsync,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: AppSpacing.bottomNavClearance,
      ),
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
          ),
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
              UserAvatar(user: user, radius: 52, showBorder: true),
              Positioned(
                bottom: -4,
                right: -2,
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.editProfile),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5B544),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.black,
                    ),
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
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),
          const _SoilHealthCards(),
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
          icon: Icons.developer_board_rounded,
          title: 'Minhas Controladoras',
          onTap: () => _showControllersModal(context, ref),
        ),
        _menuItem(
          icon: Icons.sensors_rounded,
          title: 'Meus Dispositivos (Sensores)',
          onTap: () => _showSensorsModal(context, ref),
        ),
        _menuItem(
          icon: Icons.workspaces_outline,
          title: 'Grupos',
          onTap: () => Navigator.pushNamed(context, AppRoutes.deviceGroups),
        ),
        _menuItem(
          icon: Icons.water_drop_outlined,
          title: 'Preferências de Irrigação',
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.irrigationPreferences),
        ),
        _menuItem(
          icon: Icons.notifications_none_rounded,
          title: 'Notificações',
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        _menuItem(
          icon: Icons.tune_rounded,
          title: 'Preferências de Notificação',
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.notificationPreferences),
        ),
        _menuItem(
          icon: Icons.help_outline_rounded,
          title: 'Ajuda e Suporte',
          onTap: () => Navigator.pushNamed(context, AppRoutes.support),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () {
            ref.read(authProvider.notifier).logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
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
      ],
    );
  }

  void _showControllersModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final controllersAsync = ref.watch(controllersProvider);
            final latestFirmware = ref
                .watch(latestFirmwareVersionProvider)
                .valueOrNull;
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minhas Controladoras',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3520),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: controllersAsync.when(
                      data: (controllers) {
                        if (controllers.isEmpty) {
                          return const Center(
                            child: Text('Nenhuma controladora cadastrada.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: controllers.length,
                          itemBuilder: (context, index) {
                            final controller = controllers[index];
                            final hasUpdate =
                                latestFirmware != null &&
                                compareFirmwareVersions(
                                      latestFirmware,
                                      controller.firmwareVersion,
                                    ) >
                                    0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: const Color(0xFFF6F7F2),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.controllerFirmware,
                                    arguments: controller,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFD4E9D5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.developer_board_rounded,
                                            color: Color(0xFF1D3520),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'LoRa ID: ${controller.hardwareUid}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                hasUpdate
                                                    ? 'v${controller.firmwareVersion} · atualização v$latestFirmware disponível'
                                                    : 'Firmware v${controller.firmwareVersion}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: hasUpdate
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: hasUpdate
                                                      ? AppColors.primary
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (hasUpdate)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Icon(
                                              Icons.system_update_rounded,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: controller.isOnline
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            controller.isOnline
                                                ? 'Online'
                                                : 'Offline',
                                            style: TextStyle(
                                              color: controller.isOnline
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Erro: $err')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addControllerBluetooth,
                        );
                      },
                      icon: const Icon(
                        Icons.bluetooth_searching_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Nova Controladora (Bluetooth)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSensorsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final allDevicesAsync = ref.watch(allDevicesProvider);
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Meus Dispositivos (Sensores)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3520),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: allDevicesAsync.when(
                      data: (devices) {
                        if (devices.isEmpty) {
                          return const Center(
                            child: Text('Nenhum sensor de solo encontrado.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7F2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD4E9D5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sensors_rounded,
                                      color: Color(0xFF1D3520),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Umidade Solo: ${device.soilMoisture ?? 0}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: device.isOnline
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      device.isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color: device.isOnline
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Erro: $err')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.addDeviceQrCode);
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Adicionar Sensor (QR Code)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeatherForecastSection(AsyncValue<WeatherModel> weatherAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: weatherAsync.when(
        data: (weather) => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREVISÃO LOCAL: ${weather.cityName.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°C ${weather.description[0].toUpperCase()}${weather.description.substring(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF274029),
                    ),
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
        error: (err, stack) =>
            const Text('Não foi possível carregar a previsão.'),
      ),
    );
  }

  String _getWeatherTip(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Ótimo dia para regar suas plantas!';
      case 'clouds':
        return 'Céu nublado. Verifique a umidade do solo.';
      case 'rain':
      case 'drizzle':
        return 'Chovendo. Economize água hoje!';
      case 'thunderstorm':
        return 'Tempestade! Proteja as plantas sensíveis.';
      default:
        return 'Fique de olho no clima para sua horta.';
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

  Widget _menuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                child: Icon(icon, color: const Color(0xFF274029)),
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
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoilHealthCards extends ConsumerWidget {
  const _SoilHealthCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(soilHealthProvider);
    final data = health.valueOrNull;
    final loading = health.isLoading && data == null;

    void open() => Navigator.pushNamed(context, AppRoutes.soilHealth);

    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.eco,
            iconColor: const Color(0xFF9FC88F),
            title: 'Saúde do Solo',
            value: loading
                ? '...'
                : data == null
                ? '–'
                : soilHealthLabel(data.status),
            valueColor: data == null
                ? const Color(0xFF274029)
                : soilHealthColor(data.status),
            onTap: open,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatusCard(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFF9C6A00),
            title: 'Nível de Água',
            value: loading
                ? '...'
                : data?.avgMoisture == null
                ? '–'
                : '${data!.avgMoisture}%',
            valueColor: const Color(0xFF9C6A00),
            onTap: open,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Color valueColor;
  final VoidCallback onTap;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9F9F6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, color: iconColor),
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
        ),
      ),
    );
  }
}
