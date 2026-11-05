import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/data/models/statistics_model.dart';
import '../../../devices/data/models/device_model.dart';
import '../../../devices/presentation/providers/all_devices_provider.dart';
import '../../../irrigation/data/models/irrigation_history_model.dart';
import '../../../schedule/presentation/pages/edit_schedule_page.dart';
import '../../data/models/device_group_statistics_model.dart';
import '../providers/device_groups_provider.dart';

class DeviceGroupDetailPage extends ConsumerWidget {
  final String groupUuid;

  const DeviceGroupDetailPage({super.key, required this.groupUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(deviceGroupDetailProvider(groupUuid));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: Text(detailAsync.valueOrNull?.group.name ?? 'Grupo'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameDialog(context, ref, detailAsync.valueOrNull?.group.name ?? '');
              } else if (value == 'delete') {
                _showDeleteDialog(context, ref);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Renomear')),
              PopupMenuItem(value: 'delete', child: Text('Excluir grupo')),
            ],
          ),
        ],
      ),
      body: detailAsync.when(
        data: (detail) => RefreshIndicator(
          onRefresh: () =>
              ref.read(deviceGroupDetailProvider(groupUuid).notifier).fetchDetail(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: detail.devices.isEmpty
                          ? null
                          : () => _triggerIrrigation(context, ref, 'START'),
                      icon: const Icon(Icons.water_drop_rounded, color: Colors.white),
                      label: const Text(
                        'Irrigar Grupo',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: detail.devices.isEmpty
                          ? null
                          : () => _triggerIrrigation(context, ref, 'STOP'),
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
                      label: const Text(
                        'Parar Grupo',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditSchedulePage(presetGroupUuid: groupUuid),
                  ),
                ),
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Criar Agendamento do Grupo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
              _buildStatisticsSection(context, ref),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DISPOSITIVOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddDeviceModal(context, ref, detail.devices),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (detail.devices.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Nenhum dispositivo neste grupo ainda.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...detail.devices.map((d) => _buildDeviceTile(context, ref, d)),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(
      deviceGroupStatisticsProvider((groupUuid: groupUuid, period: 'week')),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESTATÍSTICAS (7 DIAS)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildMoistureCard(stats)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildConsumptionCard(stats.waterConsumption)),
                ],
              ),
              if (stats.irrigationHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...stats.irrigationHistory
                    .take(3)
                    .map((h) => _buildHistoryTile(h)),
              ],
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (err, _) => Text(
            'Não foi possível carregar as estatísticas.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildMoistureCard(DeviceGroupStatisticsModel stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.avgSoilMoisture != null
                ? '${stats.avgSoilMoisture!.round()}%'
                : '-',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Umidade média',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (stats.minSoilMoisture != null && stats.maxSoilMoisture != null) ...[
            const SizedBox(height: 4),
            Text(
              'mín ${stats.minSoilMoisture}% · máx ${stats.maxSoilMoisture}%',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsumptionCard(WaterConsumption consumption) {
    final liters = consumption.currentTotalMl / 1000;
    final isUp = consumption.changePercent >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${liters.toStringAsFixed(1)} L',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Água consumida',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (consumption.previousTotalMl > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 12,
                  color: isUp ? Colors.orange : Colors.green,
                ),
                Text(
                  ' ${consumption.changePercent.abs().toStringAsFixed(0)}% vs. semana anterior',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTile(IrrigationHistoryModel history) {
    final started = history.startedAt != null
        ? DateTime.tryParse(history.startedAt!)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            history.status.toUpperCase() == 'FINALIZADO'
                ? Icons.check_circle_outline
                : Icons.error_outline,
            size: 16,
            color: history.status.toUpperCase() == 'FINALIZADO'
                ? AppColors.primary
                : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              started != null
                  ? DateFormat('dd/MM HH:mm').format(started)
                  : '-',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          Text(
            '${(history.durationSeconds / 60).round()} min · ${(history.waterVolumeMl / 1000).toStringAsFixed(1)} L',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(BuildContext context, WidgetRef ref, DeviceModel device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sensors_rounded,
            color: device.isOnline ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${device.soilMoisture ?? "-"}% umidade · ${device.isOnline ? "Online" : "Offline"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            onPressed: () => ref
                .read(deviceGroupDetailProvider(groupUuid).notifier)
                .removeDevice(device.uuid),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerIrrigation(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    try {
      final results = await ref
          .read(deviceGroupDetailProvider(groupUuid).notifier)
          .triggerIrrigation(action);
      final failures = results.where((r) => r['success'] != true).length;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failures == 0
                ? '${results.length} dispositivo(s) atualizados com sucesso.'
                : '${results.length - failures} de ${results.length} dispositivo(s) atualizados ($failures falharam).',
          ),
          backgroundColor: failures == 0 ? AppColors.primary : Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear Grupo'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(deviceGroupDetailProvider(groupUuid).notifier).rename(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: const Text(
          'Os dispositivos não serão excluídos, só deixarão de fazer parte deste grupo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(deviceGroupsProvider.notifier).deleteGroup(groupUuid);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceModal(
    BuildContext context,
    WidgetRef ref,
    List<DeviceModel> currentMembers,
  ) {
    final memberUuids = currentMembers.map((d) => d.uuid).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Consumer(
        builder: (context, ref, _) {
          final devicesAsync = ref.watch(allDevicesProvider);
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar Dispositivo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: devicesAsync.when(
                    data: (devices) {
                      final available = devices
                          .where((d) => !memberUuids.contains(d.uuid))
                          .toList();
                      if (available.isEmpty) {
                        return const Center(
                          child: Text(
                            'Todos os dispositivos já estão em algum grupo.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final device = available[index];
                          return ListTile(
                            title: Text(device.name),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () async {
                              await ref
                                  .read(deviceGroupDetailProvider(groupUuid).notifier)
                                  .assignDevice(device.uuid);
                              if (modalContext.mounted) Navigator.pop(modalContext);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, _) => Center(child: Text('Erro: $err')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
