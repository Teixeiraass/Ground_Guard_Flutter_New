import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import '../providers/devices_provider.dart';
import '../../data/models/device_model.dart';

class DevicesListPage extends ConsumerWidget {
  const DevicesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF173518)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meus Dispositivos',
          style: TextStyle(color: Color(0xFF173518), fontWeight: FontWeight.bold),
        ),
      ),
      body: devicesAsync.when(
        data: (devices) => RefreshIndicator(
          onRefresh: () => ref.read(devicesProvider.notifier).fetchDevices(),
          child: devices.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Dismissible(
                      key: Key(device.uuid),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Desvincular',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete_outline, color: Colors.white),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmation(context);
                      },
                      onDismissed: (direction) async {
                        try {
                          await ref.read(devicesProvider.notifier).unlinkDevice(device.uuid);
                          
                          final currentDevices = ref.read(devicesProvider).value ?? [];
                          
                          if (context.mounted) {
                            if (currentDevices.isEmpty) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.qrCodeDevice,
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${device.name} desvinculado com sucesso'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao desvincular: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            ref.refresh(devicesProvider);
                          }
                        }
                      },
                      child: _DeviceCard(device: device),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(devicesProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF173518)),
                  child: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addDeviceQrCode),
        backgroundColor: const Color(0xFF173518),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Dispositivo', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Desvincular Dispositivo',
          style: TextStyle(color: Color(0xFF173518), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja desvincular este dispositivo? Você perderá o acesso aos dados dele até vinculá-lo novamente.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Desvincular', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text('Nenhum dispositivo encontrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const Text('Adicione seu primeiro sensor Ground Guard.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  final DeviceModel device;
  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEFF4EA), shape: BoxShape.circle),
            child: const Icon(Icons.wifi_tethering_rounded, color: Color(0xFF173518), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D3520))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('v${device.firmwareVersion.isEmpty ? "1.0.0" : device.firmwareVersion}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: device.status.toUpperCase() == 'ATIVO' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(device.status, style: TextStyle(color: device.status.toUpperCase() == 'ATIVO' ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditNameModal(context, ref),
            icon: const Icon(Icons.edit_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showEditNameModal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: device.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, top: 32, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Nome', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF173518))),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nome do dispositivo',
                filled: true,
                fillColor: const Color(0xFFF4F4EF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF173518)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await ref.read(devicesProvider.notifier).updateName(device.uuid, newName);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173518),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Salvar Alteração', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
