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
  int _selectedDeviceIndex = 0;

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);
    final irrigationState = ref.watch(irrigationControllerProvider);
    final rainForecastAsync = ref.watch(rainForecastProvider);

    // Escuta mudanças de estado para mostrar Snackbars
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
                    const SizedBox(height: 28),
                    _buildDynamicIrrigationButton(devices, irrigationState),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        irrigationState.maybeWhen(
                          data: (cmd) => cmd?.status == IrrigationStatus.pending
                              ? 'Aguardando confirmação do sensor...'
                              : 'Pressione para iniciar ciclo de 15 min',
                          orElse: () =>
                              'Pressione para iniciar ciclo de 15 min',
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
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
                      error: (_, __) => const SizedBox.shrink(),
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

  Widget _buildDynamicIrrigationButton(
    List<DeviceModel> devices,
    AsyncValue<IrrigationCommandModel?> state,
  ) {
    String deviceName = 'Jardim';
    String? selectedUuid;

    if (_selectedDeviceIndex > 0) {
      deviceName = devices[_selectedDeviceIndex - 1].name;
      selectedUuid = devices[_selectedDeviceIndex - 1].uuid;
    }

    return state.when(
      data: (command) {
        final status = command?.status ?? IrrigationStatus.idle;

        if (status == IrrigationStatus.pending) {
          return _buttonContainer(
            label: 'Enviando...',
            icon: Icons.hourglass_empty,
            color: Colors.grey.shade600,
            onTap: null,
          );
        }

        if (status == IrrigationStatus.success && command?.action == 'START') {
          return _buttonContainer(
            label: 'Parar Irrigação',
            icon: Icons.stop_circle_outlined,
            color: Colors.red.shade800,
            onTap: () {
              if (selectedUuid != null) {
                ref
                    .read(irrigationControllerProvider.notifier)
                    .stopIrrigation(selectedUuid);
              }
            },
          );
        }

        // Estado inicial / ocioso
        return _buttonContainer(
          label: _selectedDeviceIndex == 0
              ? 'Irrigar Jardim'
              : 'Irrigar ${deviceName.split(' ')[0]}',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF0B4B16),
          onTap: () {
            if (selectedUuid != null) {
              ref
                  .read(irrigationControllerProvider.notifier)
                  .startIrrigation(selectedUuid);
            } else {
              // Lógica de "Irrigar Todos" pode ser disparada aqui também se desejar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Selecione uma zona para irrigar especificamente.',
                  ),
                ),
              );
            }
          },
        );
      },
      loading: () => _buttonContainer(
        label: 'Processando...',
        icon: Icons.sync,
        color: Colors.grey,
        onTap: null,
      ),
      error: (err, stack) => _buttonContainer(
        label: 'Erro de Conexão',
        icon: Icons.error_outline,
        color: Colors.red,
        onTap: () => ref.read(irrigationControllerProvider.notifier).reset(),
      ),
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
    final allOptions = ['Visão Geral', ...devices.map((d) => d.name)];

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
              children: List.generate(allOptions.length, (index) {
                final isSelected = _selectedDeviceIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(allOptions[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDeviceIndex = index);
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
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(List<DeviceModel> devices) {
    String cardTitle = 'Jardim\nSaudável';
    if (_selectedDeviceIndex > 0) {
      cardTitle = devices[_selectedDeviceIndex - 1].name;
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
                    Text(
                      cardTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF214225),
                      ),
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
          _buildHumidityCircle(),
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

  Widget _buildHumidityCircle() {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF5B041), width: 12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, size: 34, color: Color(0xFF8B5A00)),
          SizedBox(height: 6),
          Text(
            '70%',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF214225),
            ),
          ),
          Text(
            'Umidade',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
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
    return Row(
      children: [
        Expanded(
          child: GardenCard(
            icon: Icons.grass,
            title: devices.isNotEmpty ? devices[0].name : 'Zona 1',
            humidity: '65% Umidade',
            humidityColor: const Color(0xFFE09B2D),
            enabled: false,
            iconBg: const Color(0xFFCDEBC2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GardenCard(
            icon: Icons.yard,
            title: devices.length > 1 ? devices[1].name : 'Zona 2',
            humidity: '42% (Seco)',
            humidityColor: Colors.red,
            enabled: true,
            iconBg: const Color(0xFFF8D4D1),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAlert(RainForecastModel rain) {
    // Prioriza mostrar o dia que tem chuva significativa (> 2mm)
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
