import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../controllers/data/models/controller_device_model.dart';
import '../../../controllers/presentation/providers/controllers_provider.dart';
import '../../../device_groups/data/models/device_group_model.dart';
import '../../../device_groups/presentation/pages/device_group_detail_page.dart';
import '../../../device_groups/presentation/providers/device_groups_provider.dart';
import '../../../devices/presentation/providers/devices_provider.dart';
import '../../../devices/data/models/device_model.dart';
import '../../../irrigation/data/models/irrigation_command_model.dart';
import '../../../irrigation/presentation/providers/irrigation_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../weather/data/models/rain_forecast_model.dart';
import '../widgets/info_card.dart';
import '../widgets/garden_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _selectedDeviceUuid;

  @override
  Widget build(BuildContext context) {
    final controllersAsync = ref.watch(controllersProvider);
    final selectedController = ref.watch(selectedControllerProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final groupsAsync = ref.watch(deviceGroupsProvider);
    final irrigationState = ref.watch(irrigationControllerProvider);
    final rainForecastAsync = ref.watch(rainForecastProvider);

    ref.listen<AsyncValue<IrrigationCommandModel?>>(
      irrigationControllerProvider,
      (prev, next) {
        next.whenData((command) {
          if (command == null) return;

          if (command.status == IrrigationStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Falha na irrigação. Tente novamente.'),
                backgroundColor: Colors.red,
              ),
            );
            ref.read(irrigationControllerProvider.notifier).reset();
          } else if (command.status == IrrigationStatus.timeout) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('O dispositivo não respondeu (Timeout).'),
                backgroundColor: Colors.orange,
              ),
            );
            ref.read(irrigationControllerProvider.notifier).reset();
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(controllersProvider.notifier).fetchControllers();
          await ref.read(devicesProvider.notifier).fetchDevices();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: AppSpacing.bottomNavClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controllersAsync.when(
                data: (controllers) {
                  if (controllers.isEmpty) {
                    return _buildNoControllerEmptyState(context);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEÇÃO 1: CONTROLADORAS
                      _buildControllersSection(
                        context,
                        controllers,
                        selectedController,
                      ),

                      // SEÇÃO 1.5: GRUPOS ATIVOS
                      groupsAsync.when(
                        data: (groups) => groups.isEmpty
                            ? const SizedBox.shrink()
                            : _buildGroupsSection(context, groups),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),

                      // SEÇÃO 2: DISPOSITIVOS (SENSORES) E COMANDO DE IRRIGAÇÃO
                      devicesAsync.when(
                        data: (devices) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainCard(devices),
                                const SizedBox(height: 20),

                                // SEÇÃO DE COMANDO DE IRRIGAÇÃO (SEMPRE VISÍVEL)
                                _buildIrrigationControlSection(
                                  context,
                                  devices,
                                  selectedController,
                                  irrigationState,
                                ),

                                const SizedBox(height: 28),
                                _buildSensorsSectionTitle(context),
                                const SizedBox(height: 16),
                                if (devices.isEmpty)
                                  _buildNoSensorInlineCard(
                                    context,
                                    selectedController,
                                  )
                                else
                                  _buildSensorsGrid(devices),
                                rainForecastAsync.when(
                                  data: (rain) => rain.willRain
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 28,
                                          ),
                                          child: _buildWeatherAlert(rain),
                                        )
                                      : const SizedBox.shrink(),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Text('Erro ao carregar sensores: $err'),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, stack) =>
                    Center(child: Text('Erro ao carregar controladoras: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsSection(
    BuildContext context,
    List<DeviceGroupModel> groups,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GRUPOS ATIVOS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final group = groups[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DeviceGroupDetailPage(groupUuid: group.uuid),
                    ),
                  ),
                  child: Container(
                    width: 172,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.workspaces_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            if (group.avgSoilMoisture != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop_rounded,
                                    size: 14,
                                    color: Color(0xFF4A90D9),
                                  ),
                                  Text(
                                    ' ${group.avgSoilMoisture!.round()}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A90D9),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1D3520),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.onlineCount}/${group.deviceCount} online'
                          '${group.irrigatingCount > 0 ? ' · irrigando' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControllersSection(
    BuildContext context,
    List<ControllerDeviceModel> controllers,
    ControllerDeviceModel? selectedController,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'CONTROLADORA ATIVA',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addControllerBluetooth,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Nova',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: controllers.map((controller) {
                final isSelected = controller.uuid == selectedController?.uuid;
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedControllerProvider.notifier).state =
                        controller;
                    setState(() => _selectedDeviceUuid = null);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 170,
                      maxWidth: 220,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1D3520)
                          : const Color(0xFFF6F7F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1D3520)
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF1D3520).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.15)
                                : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.developer_board_rounded,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1D3520),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: controller.isOnline
                                          ? Colors.greenAccent
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.isOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIrrigationControlSection(
    BuildContext context,
    List<DeviceModel> devices,
    ControllerDeviceModel? selectedController,
    AsyncValue<IrrigationCommandModel?> irrigationState,
  ) {
    final selectedDevice = _getSelectedDevice(devices);

    final bool isAllMode = _selectedDeviceUuid == null;
    final bool isOnline = isAllMode
        ? (selectedController?.isOnline ?? devices.any((d) => d.isOnline))
        : (selectedDevice?.isOnline ?? false);

    final bool isIrrigating = isAllMode
        ? (devices.any((d) => d.isIrrigating) ||
              (selectedController?.isIrrigating ?? false))
        : (selectedDevice?.isIrrigating ?? false);

    final String targetName = isAllMode
        ? 'Todas as Zonas'
        : (selectedDevice?.name ?? 'Sensor');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMANDO DE IRRIGAÇÃO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          if (devices.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedDeviceUuid = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isAllMode
                            ? const Color(0xFF1D3520)
                            : const Color(0xFFF6F7F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.grass_rounded,
                            size: 16,
                            color: isAllMode ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Todas as Zonas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isAllMode
                                  ? Colors.white
                                  : const Color(0xFF1D3520),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  ...devices.map((device) {
                    final isSelected = device.uuid == _selectedDeviceUuid;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDeviceUuid = device.uuid),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1D3520)
                              : const Color(0xFFF6F7F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: device.isOnline
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                device.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1D3520),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildActionButton(
            isOnline: isOnline,
            isIrrigating: isIrrigating,
            isLoading: irrigationState.isLoading,
            targetName: targetName,
            onTap: () {
              if (!isOnline) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dispositivo offline. Não é possível irrigar no momento.',
                    ),
                    backgroundColor: Colors.grey,
                  ),
                );
                return;
              }

              if (isIrrigating) {
                if (isAllMode && selectedController != null) {
                  ref
                      .read(irrigationControllerProvider.notifier)
                      .stopIrrigation(selectedController.uuid);
                } else if (selectedDevice != null) {
                  ref
                      .read(irrigationControllerProvider.notifier)
                      .stopIrrigation(selectedDevice.uuid);
                }
              } else {
                if (isAllMode && selectedController != null) {
                  ref
                      .read(irrigationControllerProvider.notifier)
                      .startIrrigation(selectedController.uuid);
                } else if (selectedDevice != null) {
                  ref
                      .read(irrigationControllerProvider.notifier)
                      .startIrrigation(selectedDevice.uuid);
                }
              }
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              !isOnline
                  ? 'Dispositivo offline (Sem conexão)'
                  : (isIrrigating
                        ? 'Irrigação em andamento... Clique para parar.'
                        : 'Ciclo recomendado de 15 min'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required bool isOnline,
    required bool isIrrigating,
    required bool isLoading,
    required String targetName,
    required VoidCallback onTap,
  }) {
    if (!isOnline) {
      return Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 10),
            Text(
              'Dispositivo Offline',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Enviando comando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final color = isIrrigating ? Colors.red.shade600 : AppColors.primary;
    final icon = isIrrigating
        ? Icons.stop_circle_outlined
        : Icons.water_drop_rounded;
    final label = isIrrigating
        ? 'Parar Irrigação ($targetName)'
        : 'Irrigar $targetName';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsSectionTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'SENSORES DE SOLO',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
        ),
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.addDeviceQrCode),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4),
                Text(
                  'Adicionar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoControllerEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.developer_board_off_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bem-vindo ao Ground Guard!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3520),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Para começar a monitorar suas plantas, primeiro cadastre a sua Caixa de Comando (Controladora) via Bluetooth.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.addControllerBluetooth,
                ),
                icon: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Cadastrar Controladora (Bluetooth)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
      ),
    );
  }

  Widget _buildNoSensorInlineCard(
    BuildContext context,
    ControllerDeviceModel? selectedController,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.sensors_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Nenhum sensor nesta controladora',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escaneie o QR Code do seu sensor de solo para vinculá-lo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addDeviceQrCode),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Escanear QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DeviceModel? _getSelectedDevice(List<DeviceModel> devices) {
    if (_selectedDeviceUuid == null) return null;
    try {
      return devices.firstWhere((d) => d.uuid == _selectedDeviceUuid);
    } catch (_) {
      return null;
    }
  }

  Widget _buildMainCard(List<DeviceModel> devices) {
    final selectedDevice = _getSelectedDevice(devices);
    final moisture = selectedDevice?.soilMoisture;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedDevice != null
                      ? selectedDevice.name
                      : 'Média das Zonas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F4EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedDevice?.isOnline ?? true ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: selectedDevice?.isOnline ?? true
                        ? AppColors.primary
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: 'Umidade Solo',
                  value: moisture != null ? '$moisture%' : '-',
                  icon: Icons.water_drop_outlined,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: InfoCard(
                  title: 'Temperatura',
                  value: '-',
                  icon: Icons.thermostat_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsGrid(List<DeviceModel> devices) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final isSelected = device.uuid == _selectedDeviceUuid;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDeviceUuid = isSelected ? null : device.uuid;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GardenCard(
              icon: Icons.sensors_rounded,
              title: device.name,
              humidity: 'Umidade: ${device.soilMoisture ?? 0}%',
              humidityColor: Colors.blue,
              enabled: device.isIrrigating,
              iconBg: isSelected
                  ? const Color(0xFFD4E9D5)
                  : const Color(0xFFEFF4EA),
              isOnline: device.isOnline,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherAlert(RainForecastModel rain) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Previsão de Chuva',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
                Text(
                  '${rain.nextRainDay}: ${rain.nextRainProbability?.toStringAsFixed(0)}% de chance',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
