import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../devices/data/models/device_model.dart';
import '../../../devices/presentation/providers/all_devices_provider.dart';
import '../../data/models/device_group_model.dart';
import '../providers/device_groups_provider.dart';
import 'device_group_detail_page.dart';

class DeviceGroupsPage extends ConsumerWidget {
  const DeviceGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(deviceGroupsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          'Grupos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateGroupModal(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(deviceGroupsProvider.notifier).fetchGroups(),
        child: groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) =>
                  _buildGroupCard(context, groups[index]),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(child: Text('Erro: $err')),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspaces_outline,
              size: 52,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum grupo criado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrupe dispositivos por canteiro ou cultura\n(ex: Tomate, Alface) para agir em todos de uma vez.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, DeviceGroupModel group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeviceGroupDetailPage(groupUuid: group.uuid),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF4EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspaces_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3520),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.deviceCount} dispositivo(s) · ${group.onlineCount} online'
                        '${group.irrigatingCount > 0 ? ' · ${group.irrigatingCount} irrigando' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateGroupModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final selectedUuids = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Consumer(
        builder: (context, ref, _) {
          final devicesAsync = ref.watch(allDevicesProvider);

          return StatefulBuilder(
            builder: (context, setState) => Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Novo Grupo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF173518),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ex: Tomate',
                      filled: true,
                      fillColor: const Color(0xFFF4F4EF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dispositivos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: devicesAsync.when(
                      data: (devices) => _buildDeviceCheckboxList(
                        devices,
                        selectedUuids,
                        setState,
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (err, _) => Center(child: Text('Erro: $err')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      try {
                        final group = await ref
                            .read(deviceGroupsProvider.notifier)
                            .createGroup(name);
                        for (final deviceUuid in selectedUuids) {
                          await ref
                              .read(deviceGroupsRepositoryProvider)
                              .assignDeviceToGroup(deviceUuid, group.uuid);
                        }
                        ref.read(deviceGroupsProvider.notifier).fetchGroups();
                        if (modalContext.mounted) Navigator.pop(modalContext);
                      } catch (e) {
                        if (modalContext.mounted) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro ao criar grupo: ${e.toString().replaceAll("Exception: ", "")}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Criar Grupo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCheckboxList(
    List<DeviceModel> devices,
    Set<String> selectedUuids,
    void Function(void Function()) setState,
  ) {
    if (devices.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum dispositivo cadastrado ainda.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final isSelected = selectedUuids.contains(device.uuid);
        return CheckboxListTile(
          value: isSelected,
          title: Text(device.name),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) => setState(() {
            if (checked == true) {
              selectedUuids.add(device.uuid);
            } else {
              selectedUuids.remove(device.uuid);
            }
          }),
        );
      },
    );
  }
}
