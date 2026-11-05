import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../controllers/data/models/controller_device_model.dart';
import '../../../controllers/presentation/providers/controllers_provider.dart';
import '../../../devices/presentation/providers/devices_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../weather/data/models/rain_forecast_model.dart';
import '../providers/statistics_provider.dart';
import '../../data/models/statistics_model.dart';
import '../../../irrigation/data/models/irrigation_history_model.dart';
import '../../../irrigation/presentation/providers/irrigation_provider.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final controllersAsync = ref.watch(controllersProvider);
    final selectedController = ref.watch(selectedControllerProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final rainForecastAsync = ref.watch(rainForecastProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final filters = ref.watch(statisticsFiltersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(controllersProvider.notifier).fetchControllers();
          await ref.read(statisticsProvider.notifier).fetchStatistics();
        },
        color: const Color(0xFF1D3520),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: AppSpacing.bottomNavClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Estatísticas por Zona',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D3520),
                ),
              ),
              const Text(
                'Visão detalhada do seu ecossistema.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              controllersAsync.when(
                data: (controllers) {
                  if (controllers.isEmpty) {
                    return _buildNoControllersCard(context);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SELETOR DE CONTROLADORA MEHORADO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.developer_board_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CONTROLADORA ATIVA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    selectedController?.name ?? 'Selecione',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1D3520),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _showControllerPickerModal(
                                context,
                                ref,
                                controllers,
                                selectedController,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F7F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Trocar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // SENSORES FILTROS
                      devicesAsync.when(
                        data: (devices) {
                          if (devices.isEmpty) {
                            return _buildNoSensorsCard(context);
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  'Visão Geral',
                                  isSelected: filters.deviceUuid == null,
                                  onTap: () =>
                                      ref
                                          .read(
                                            statisticsFiltersProvider.notifier,
                                          )
                                          .state = filters.copyWith(
                                        clearDeviceUuid: true,
                                      ),
                                ),
                                ...devices.map(
                                  (d) => _buildFilterChip(
                                    d.name,
                                    isSelected: filters.deviceUuid == d.uuid,
                                    onTap: () =>
                                        ref
                                            .read(
                                              statisticsFiltersProvider
                                                  .notifier,
                                            )
                                            .state = filters.copyWith(
                                          deviceUuid: d.uuid,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          height: 40,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 24),
                      // CARD UMIDADE DO SOLO
                      _buildMainCard(
                        title: 'Umidade do Solo',
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildCircularIndicator(
                              _getCurrentHumidity(
                                devicesAsync.value ?? [],
                                filters.deviceUuid,
                              ),
                              'Ideal',
                            ),
                            const SizedBox(height: 32),
                            Builder(
                              builder: (context) {
                                final readings = _soilMoistureReadings(
                                  devicesAsync.value ?? [],
                                  filters.deviceUuid,
                                );
                                final minLabel = readings.isEmpty
                                    ? '-'
                                    : '${readings.reduce((a, b) => a < b ? a : b).toInt()}%';
                                final maxLabel = readings.isEmpty
                                    ? '-'
                                    : '${readings.reduce((a, b) => a > b ? a : b).toInt()}%';
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildMiniStatCard(
                                        'Mínimo',
                                        minLabel,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildMiniStatCard(
                                        'Máxima',
                                        maxLabel,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CONTEÚDO DE ESTATÍSTICAS (CONSUMO E HISTÓRICO)
                      statsAsync.when(
                        data: (stats) => Column(
                          children: [
                            // CARD CONSUMO DE ÁGUA
                            _buildMainCard(
                              title: 'Consumo de Água',
                              trailing: _buildSmallChip(
                                stats.period == 'week'
                                    ? 'Últimos 7 dias'
                                    : stats.period,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  _buildBarChart(stats.waterConsumption.points),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stats.period == 'week'
                                                ? 'Total da Semana'
                                                : 'Total do Período',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            '${(stats.waterConsumption.currentTotalMl / 1000).toStringAsFixed(1)} Litros',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1D3520),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            stats
                                                        .waterConsumption
                                                        .changePercent >=
                                                    0
                                                ? Icons.trending_up_rounded
                                                : Icons.trending_down_rounded,
                                            color:
                                                stats
                                                        .waterConsumption
                                                        .changePercent >=
                                                    0
                                                ? Colors.orange
                                                : Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${stats.waterConsumption.changePercent.abs().toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const Text(
                                            ' vs. anterior',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            // HISTÓRICO
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'HISTÓRICO DE IRRIGAÇÃO',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                          irrigationHistoryFiltersProvider
                                              .notifier,
                                        )
                                        .state = HistoryFilters(
                                      deviceUuid: filters.deviceUuid,
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.irrigationHistory,
                                    );
                                  },
                                  child: const Text(
                                    'Ver todos',
                                    style: TextStyle(
                                      color: Color(0xFF1D3520),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (stats.irrigationHistory.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'Nenhuma irrigação recente',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...stats.irrigationHistory
                                  .take(5)
                                  .map((item) => _buildHistoryItem(item)),
                          ],
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1D3520),
                            ),
                          ),
                        ),
                        error: (error, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Erro ao carregar estatísticas: $error',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Erro ao carregar controladoras: $err')),
              ),

              const SizedBox(height: 24),
              // FOOTER CARDS
              Row(
                children: [
                  Expanded(
                    child: rainForecastAsync.when(
                      data: (rain) => _buildFooterInfoCard(
                        'Próxima Chuva',
                        rain.nextRainDay ?? 'Sem previsão',
                        rain.nextRainProbability != null &&
                                rain.nextRainProbability! > 0
                            ? '${rain.nextRainProbability!.toStringAsFixed(0)}% Probabilidade'
                            : 'Céu limpo',
                        Icons.cloud_outlined,
                        const Color(0xFFE3F2FD),
                      ),
                      loading: () => _buildFooterInfoCard(
                        'Próxima Chuva',
                        '...',
                        'Calculando...',
                        Icons.wb_sunny_outlined,
                        const Color(0xFFFDE9C2),
                      ),
                      error: (_, __) => _buildFooterInfoCard(
                        'Próxima Chuva',
                        '--',
                        'Erro ao buscar',
                        Icons.error_outline,
                        Colors.red.shade50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFooterInfoCard(
                      'Temp. Solo',
                      '-',
                      'Sem dado',
                      Icons.thermostat_rounded,
                      const Color(0xFFFFE7E2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showControllerPickerModal(
    BuildContext context,
    WidgetRef ref,
    List<ControllerDeviceModel> controllers,
    ControllerDeviceModel? selectedController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecionar Controladora',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3520),
              ),
            ),
            const SizedBox(height: 16),
            ...controllers.map((c) {
              final isSelected = c.uuid == selectedController?.uuid;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1D3520)
                      : const Color(0xFFF6F7F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.developer_board_rounded,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1D3520),
                    ),
                  ),
                  subtitle: Text(
                    'LoRa ID: ${c.hardwareUid}',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        )
                      : null,
                  onTap: () {
                    ref.read(selectedControllerProvider.notifier).state = c;
                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoControllersCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.developer_board_off_rounded,
            size: 56,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma Controladora',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cadastre uma caixa de comando via Bluetooth para ver os dados estatísticos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addControllerBluetooth),
            icon: const Icon(
              Icons.bluetooth_searching_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'Cadastrar Controladora',
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
        ],
      ),
    );
  }

  Widget _buildNoSensorsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors_off_rounded, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nenhum sensor nesta controladora',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addDeviceQrCode),
            child: const Text(
              'Adicionar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _soilMoistureReadings(
    List<dynamic> devices,
    String? selectedUuid,
  ) {
    final relevant = selectedUuid != null
        ? devices.where((d) => d.uuid == selectedUuid)
        : devices.where((d) => d.isOnline);
    return relevant
        .map((d) => d.soilMoisture)
        .whereType<int>()
        .map((m) => m.toDouble())
        .toList();
  }

  double? _getCurrentHumidity(List<dynamic> devices, String? selectedUuid) {
    final readings = _soilMoistureReadings(devices, selectedUuid);
    if (readings.isEmpty) return null;
    return readings.reduce((a, b) => a + b) / readings.length;
  }

  Widget _buildFilterChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D4029) : Colors.white,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3520),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(double? value, String label) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: CircularProgressIndicator(
            value: value != null ? value / 100 : 0,
            strokeWidth: 15,
            backgroundColor: const Color(0xFFF4F4F4),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5B544)),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? '${value.toInt()}%' : '-',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D3520),
              ),
            ),
            Text(
              value != null ? label : 'Sem dado',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3520),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D4029),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<ConsumptionPoint> points) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Sem dados',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    final maxVolume = points
        .map((p) => p.waterVolumeMl)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((p) {
        final percentage = maxVolume > 0 ? p.waterVolumeMl / maxVolume : 0.0;
        final isToday =
            p.label.toUpperCase() ==
            DateFormat('EEE').format(DateTime.now()).toUpperCase();

        return Column(
          children: [
            Container(
              height: 100 * percentage.clamp(0.1, 1.0),
              width: 12,
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF2D4029)
                    : const Color(0xFFE9F4EB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.label,
              style: TextStyle(
                fontSize: 9,
                color: isToday ? const Color(0xFF1D3520) : Colors.grey,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItem(IrrigationHistoryModel item) {
    final DateTime? startTime = item.startedAt != null
        ? DateTime.tryParse(item.startedAt!)
        : null;
    final timeStr = startTime != null
        ? DateFormat('HH:mm').format(startTime)
        : '--:--';
    final dateStr = startTime != null
        ? DateFormat('dd/MM').format(startTime)
        : '';

    final minutes = item.durationSeconds ~/ 60;
    final seconds = item.durationSeconds % 60;
    final durationStr = '${minutes}m ${seconds.toString().padLeft(2, '0')}s';

    final waterStr = '${(item.waterVolumeMl / 1000).toStringAsFixed(1)} L';

    IconData icon;
    Color iconBg;

    switch (item.triggerType.toLowerCase()) {
      case 'manual':
        icon = Icons.touch_app_rounded;
        iconBg = const Color(0xFFFDE9C2);
        break;
      case 'automatic':
      case 'schedule':
        icon = Icons.water_drop_rounded;
        iconBg = const Color(0xFFD4E9D5);
        break;
      default:
        icon = Icons.info_outline;
        iconBg = Colors.grey.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: const Color(0xFF2D4029)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dateStr, $timeStr',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
                Text(
                  item.triggerType.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                durationStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3520),
                ),
              ),
              Text(
                waterStr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfoCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color iconBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: const Color(0xFF1D3520)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3520),
            ),
          ),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
