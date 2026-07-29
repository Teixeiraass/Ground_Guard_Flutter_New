import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
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
  String? _selectedDeviceUuid; // Agora usamos o UUID em vez do índice

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);
    final irrigationState = ref.watch(irrigationControllerProvider);
    final rainForecastAsync = ref.watch(rainForecastProvider);

    // Escuta mudanças de estado para mostrar Snackbars de erro ou timeout
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
      backgroundColor: Colors.transparent,
      body: devicesAsync.when(
        data: (devices) => SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeviceSelector(devices),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(devices),
                    if (_selectedDeviceUuid != null) ...[
                      const SizedBox(height: 28),
                      _buildDynamicIrrigationButton(devices, irrigationState),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _getIrrigationSubtitle(devices, irrigationState),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 34),
                    _buildZonesTitle(),
                    const SizedBox(height: 20),
                    _buildZonesGrid(devices),
                    rainForecastAsync.when(
                      data: (rain) => rain.willRain
                          ? Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: _buildWeatherAlert(rain),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar dispositivos: $err')),
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

  String _getIrrigationSubtitle(List<DeviceModel> devices, AsyncValue<IrrigationCommandModel?> state) {
    if (state.isLoading) return 'Processando comando...';

    final device = _getSelectedDevice(devices);
    bool isAnyIrrigating = device?.isIrrigating ?? false;

    if (isAnyIrrigating) return 'Irrigação em curso. Clique para parar.';

    return state.maybeWhen(
      data: (cmd) => cmd?.status == IrrigationStatus.pending
          ? 'Aguardando confirmação do sensor...'
          : 'Pressione para iniciar ciclo de 15 min',
      orElse: () => 'Pressione para iniciar ciclo de 15 min',
    );
  }

  Widget _buildDynamicIrrigationButton(
    List<DeviceModel> devices,
    AsyncValue<IrrigationCommandModel?> state,
  ) {
    final device = _getSelectedDevice(devices);
    String? selectedUuid = device?.uuid;
    bool isIrrigating = device?.isIrrigating ?? false;

    // Se estiver carregando um comando manual (clique no botão)
    if (state.isLoading) {
      return _buttonContainer(
        label: 'Processando...',
        icon: Icons.sync,
        color: Colors.grey,
        onTap: null,
      );
    }

    // Se o WebSocket diz que está irrigando, o botão vira "Parar"
    if (isIrrigating) {
      return _buttonContainer(
        label: 'Parar Irrigação',
        icon: Icons.stop_circle_outlined,
        color: Colors.red.shade800,
        onTap: () {
          if (selectedUuid != null) {
            ref.read(irrigationControllerProvider.notifier).stopIrrigation(selectedUuid);
          }
        },
      );
    }

    // Estado PENDING do comando enviado
    final command = state.asData?.value;
    if (command?.status == IrrigationStatus.pending) {
       return _buttonContainer(
        label: 'Enviando...',
        icon: Icons.hourglass_empty,
        color: Colors.grey.shade600,
        onTap: null,
      );
    }

    // Estado padrão: Irrigar
    return _buttonContainer(
      label: 'Irrigar',
      icon: Icons.water_drop_outlined,
      color: const Color(0xFF0B4B16),
      onTap: () {
        if (selectedUuid != null) {
          ref.read(irrigationControllerProvider.notifier).startIrrigation(selectedUuid);
        }
      },
    );
  }

  Widget _buttonContainer({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelector(List<DeviceModel> devices) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_florist_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'MONITORANDO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: const Text('Visão Geral'),
                    selected: _selectedDeviceUuid == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDeviceUuid = null);
                        ref.read(irrigationControllerProvider.notifier).reset();
                      }
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedDeviceUuid == null ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _selectedDeviceUuid == null
                            ? AppColors.primary
                            : AppColors.outline.withOpacity(0.2),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                ),
                ...devices.map((device) {
                  final isSelected = _selectedDeviceUuid == device.uuid;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(device.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDeviceUuid = device.uuid);
                          ref.read(irrigationControllerProvider.notifier).reset();
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outline.withOpacity(0.2),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(List<DeviceModel> devices) {
    String cardTitle = 'Jardim\nSaudável';
    bool isOnline = true;

    final device = _getSelectedDevice(devices);
    if (device != null) {
      cardTitle = device.name;
      isOnline = device.isOnline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5EF),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF214225),
                            ),
                          ),
                        ),
                        if (_selectedDeviceUuid != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Próxima rega hoje às\n18:30',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDEBC2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Text(
                      '92%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF214225),
                      ),
                    ),
                    Text(
                      'Vitalidade',
                      style: TextStyle(fontSize: 14, color: Color(0xFF214225)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildHumidityCircle(devices),
          const SizedBox(height: 34),
          const Row(
            children: [
              Expanded(
                child: InfoCard(
                  icon: Icons.thermostat_outlined,
                  title: 'Temperatura',
                  value: '24°C',
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: InfoCard(
                  icon: Icons.wb_sunny_outlined,
                  title: 'UV Index',
                  value: 'Médio',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityCircle(List<DeviceModel> devices) {
    double humidityValue = 0.0;
    String humidityText = '--';

    final device = _getSelectedDevice(devices);

    if (device != null) {
      if (device.isOnline && device.soilMoisture != null) {
        humidityValue = device.soilMoisture! / 100.0;
        humidityText = '${device.soilMoisture}%';
      }
    } else if (devices.isNotEmpty) {
      final onlineDevices = devices.where((d) => d.isOnline && d.soilMoisture != null).toList();
      if (onlineDevices.isNotEmpty) {
        final avg = onlineDevices.map((d) => d.soilMoisture!).reduce((a, b) => a + b) / onlineDevices.length;
        humidityValue = avg / 100.0;
        humidityText = '${avg.toStringAsFixed(0)}%';
      }
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: humidityValue),
      builder: (context, value, child) {
        return Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CustomPaint(
                  painter: _HumidityPainter(
                    progress: value,
                    color: const Color(0xFFF5B041),
                    backgroundColor: const Color(0xFFE5E6DE),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop_outlined, size: 34, color: Color(0xFF8B5A00)),
                  const SizedBox(height: 6),
                  Text(
                    humidityText,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF214225),
                    ),
                  ),
                  const Text(
                    'Umidade',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZonesTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Zonas do Jardim',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF214225),
            ),
          ),
        ),
        Text(
          'Ver tudo',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildZonesGrid(List<DeviceModel> devices) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0, // Quadrado para evitar overflow vertical
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final String humidityValue = (device.isOnline && device.soilMoisture != null)
            ? '${device.soilMoisture}%'
            : '--';

        return GardenCard(
          icon: Icons.grass,
          title: device.name,
          humidity: '$humidityValue Umidade',
          humidityColor: device.isOnline ? const Color(0xFFE09B2D) : Colors.grey,
          enabled: device.status.toUpperCase() == 'ATIVO',
          iconBg: device.isOnline ? const Color(0xFFCDEBC2) : Colors.grey.shade200,
          isOnline: device.isOnline,
        );
      },
    );
  }

  Widget _buildWeatherAlert(RainForecastModel rain) {
    final bool isRainyToday = rain.rainToday > 2.0;
    final String when = isRainyToday ? 'hoje' : 'amanhã';
    final double volume = isRainyToday ? rain.rainToday : rain.rainTomorrow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFD9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.cloud_outlined, color: Color(0xFF214225)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Previsão de Chuva',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF214225),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pode chover $when.\nPrevisão de ${volume.toStringAsFixed(1)}mm de chuva.',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HumidityPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _HumidityPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Fundo do círculo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progresso
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Começa no topo (-90 graus)
      6.28319 * progress, // 2 * PI * progresso
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HumidityPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
