import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../devices/presentation/providers/devices_provider.dart';
import '../providers/irrigation_provider.dart';
import '../../data/models/irrigation_history_model.dart';

class IrrigationHistoryPage extends ConsumerStatefulWidget {
  const IrrigationHistoryPage({super.key});

  @override
  ConsumerState<IrrigationHistoryPage> createState() =>
      _IrrigationHistoryPageState();
}

class _IrrigationHistoryPageState extends ConsumerState<IrrigationHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(irrigationHistoryProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final filters = ref.watch(irrigationHistoryFiltersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          'Histórico de Irrigação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3520),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D3520)),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(irrigationHistoryProvider.notifier).fetchHistory(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // BARRA DE FILTROS (ZONA E DATA)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 20, top: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Zonas de Irrigação',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  devicesAsync.when(
                    data: (devices) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildDeviceFilterChip(
                            'Todas',
                            isSelected: filters.deviceUuid == null,
                            onTap: () =>
                                ref
                                    .read(
                                      irrigationHistoryFiltersProvider.notifier,
                                    )
                                    .state = filters.copyWith(
                                  clearDeviceUuid: true,
                                ),
                          ),
                          ...devices.map(
                            (d) => _buildDeviceFilterChip(
                              d.name,
                              isSelected: filters.deviceUuid == d.uuid,
                              onTap: () =>
                                  ref
                                      .read(
                                        irrigationHistoryFiltersProvider
                                            .notifier,
                                      )
                                      .state = filters.copyWith(
                                    deviceUuid: d.uuid,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        height: 40,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () => _selectDateRange(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: Color(0xFF2D4029),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getDateRangeText(filters),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D3520),
                                ),
                              ),
                            ),
                            if (filters.startDate != null)
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(
                                        irrigationHistoryFiltersProvider
                                            .notifier,
                                      )
                                      .state = filters.copyWith(
                                    clearDates: true,
                                  );
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: historyAsync.when(
                data: (history) {
                  if (history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum registro encontrado.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(irrigationHistoryProvider.notifier)
                        .fetchHistory(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return _HistoryItem(item: item);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1D3520)),
                ),
                error: (error, _) => Center(child: Text('Erro: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final filters = ref.read(irrigationHistoryFiltersProvider);
    final initialRange = filters.startDate != null && filters.endDate != null
        ? DateTimeRange(start: filters.startDate!, end: filters.endDate!)
        : null;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D4029),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1D3520),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(irrigationHistoryFiltersProvider.notifier).state = filters
          .copyWith(startDate: picked.start, endDate: picked.end);
    }
  }

  String _getDateRangeText(HistoryFilters filters) {
    if (filters.startDate == null || filters.endDate == null) {
      return 'Filtrar por data (De/Até)';
    }
    final df = DateFormat('dd/MM/yyyy');
    return '${df.format(filters.startDate!)} - ${df.format(filters.endDate!)}';
  }

  Widget _buildDeviceFilterChip(
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
          color: isSelected ? const Color(0xFF2D4029) : const Color(0xFFF0F1EB),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IrrigationHistoryModel item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final DateTime? startTime = item.startedAt != null
        ? DateTime.tryParse(item.startedAt!)
        : null;
    final timeStr = startTime != null
        ? DateFormat('HH:mm').format(startTime)
        : '--:--';
    final dateStr = startTime != null
        ? DateFormat('dd MMM').format(startTime)
        : '';

    final minutes = item.durationSeconds ~/ 60;
    final seconds = item.durationSeconds % 60;
    final durationStr = '${minutes}m ${seconds.toString().padLeft(2, '0')}s';

    final waterStr = '${(item.waterVolumeMl / 1000).toStringAsFixed(1)} L';

    IconData icon;
    Color iconBg;
    String typeLabel;

    switch (item.triggerType.toLowerCase()) {
      case 'manual':
        icon = Icons.touch_app_rounded;
        iconBg = const Color(0xFFFDE9C2);
        typeLabel = 'Início Manual';
        break;
      case 'automatic':
      case 'schedule':
        icon = Icons.water_drop_rounded;
        iconBg = const Color(0xFFD4E9D5);
        typeLabel = 'Ciclo Automático';
        break;
      default:
        icon = Icons.info_outline;
        iconBg = Colors.grey.shade100;
        typeLabel = item.triggerType.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                  ),
                ),
                Text(
                  typeLabel,
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
}
