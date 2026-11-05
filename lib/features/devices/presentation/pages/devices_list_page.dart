import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import '../../../controllers/data/models/controller_device_model.dart';
import '../../../controllers/presentation/providers/controllers_provider.dart';
import '../providers/devices_provider.dart';
import '../../data/models/device_model.dart';

class DevicesListPage extends ConsumerWidget {
  const DevicesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllersAsync = ref.watch(controllersProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final selectedController = ref.watch(selectedControllerProvider);

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
          'Gerenciar Dispositivos',
          style: TextStyle(
            color: Color(0xFF173518),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(controllersProvider.notifier).fetchControllers();
            await ref.read(devicesProvider.notifier).fetchDevices();
          },
          child: controllersAsync.when(
            data: (controllers) {
              if (controllers.isEmpty) {
                return _buildNoControllersState(context, ref);
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'CONTROLADORAS (LORA)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Controladora já ligada, sem Bluetooth',
                            onPressed: () =>
                                _showTriggerPairingDialog(context, ref),
                            icon: const Icon(
                              Icons.settings_backup_restore_rounded,
                              size: 20,
                              color: Color(0xFF173518),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.addControllerBluetooth,
                            ),
                            icon: const Icon(
                              Icons.bluetooth_searching_rounded,
                              size: 18,
                              color: Color(0xFF173518),
                            ),
                            label: const Text(
                              'Nova Controladora',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173518),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...controllers.map(
                    (controller) => _ControllerCard(
                      controller: controller,
                      isSelected: controller.uuid == selectedController?.uuid,
                      onSelect: () {
                        ref.read(selectedControllerProvider.notifier).state =
                            controller;
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'SENSORES EM SOLO (${selectedController?.name ?? ""})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (selectedController == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selecione uma Controladora antes de adicionar sensores.',
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            AppRoutes.addDeviceQrCode,
                          );
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 18,
                          color: Color(0xFF173518),
                        ),
                        label: const Text(
                          'Novo Sensor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173518),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  devicesAsync.when(
                    data: (devices) {
                      if (devices.isEmpty) {
                        return _buildNoSensorsState(context);
                      }
                      return Column(
                        children: devices
                            .map((device) => _DeviceCard(device: device))
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) =>
                        Center(child: Text('Erro ao carregar sensores: $err')),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erro: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildNoControllersState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF173518).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.developer_board_off_rounded,
                size: 64,
                color: Color(0xFF173518),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma Controladora Cadastrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173518),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Para monitorar e irrigar seu solo, conecte sua caixa de comando Ground Guard via Bluetooth.',
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
                  backgroundColor: const Color(0xFF173518),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _showTriggerPairingDialog(context, ref),
              child: const Text(
                'Já tenho uma controladora ligada sem Bluetooth',
                style: TextStyle(color: Color(0xFF173518)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTriggerPairingDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar pareamento Bluetooth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use quando a controladora já está ligada e conectada ao '
              'Wi-Fi, mas não aparece mais na busca Bluetooth (ex.: após '
              'reinstalar o app ou resetar o banco). Informe o device_uid '
              '(MAC sem ":"), impresso na controladora ou visível no log '
              'Serial dela.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Ex.: AABBCCDDEEFF',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final deviceUid = controller.text.trim();
              if (deviceUid.isEmpty) return;
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(controllersProvider.notifier)
                    .triggerPairing(deviceUid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bluetooth reativado. Procure a controladora na tela a seguir.',
                      ),
                    ),
                  );
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addControllerBluetooth,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF173518),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reativar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSensorsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhum sensor de solo associado',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escaneie o QR Code do seu sensor para vinculá-lo a esta controladora.',
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
              backgroundColor: const Color(0xFF2D4029),
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
}

class _ControllerCard extends ConsumerWidget {
  final ControllerDeviceModel controller;
  final bool isSelected;
  final VoidCallback onSelect;

  const _ControllerCard({
    required this.controller,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: const Color(0xFF173518), width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF4EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.developer_board_rounded,
                        color: Color(0xFF173518),
                        size: 28,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: controller.isOnline
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D3520),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF173518),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Ativa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LoRa ID: ${controller.hardwareUid}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.isIrrigating,
                  activeColor: const Color(0xFF173518),
                  onChanged: (val) {
                    ref
                        .read(controllersProvider.notifier)
                        .toggleIrrigation(controller.uuid, val);
                  },
                ),
              ],
            ),
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Color(0xFF173518),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
                Text(
                  device.soilMoisture != null
                      ? 'Umidade: ${device.soilMoisture}%'
                      : 'Aguardando telemetria...',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditNameModal(context, ref),
            icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Nome do Sensor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173518),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nome do sensor',
                filled: true,
                fillColor: const Color(0xFFF4F4EF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF173518),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await ref
                        .read(devicesProvider.notifier)
                        .updateName(device.uuid, newName);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173518),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Salvar Alteração',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
