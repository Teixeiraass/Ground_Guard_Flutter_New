import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../devices/presentation/providers/devices_provider.dart';
import '../../../devices/data/models/device_model.dart';
import '../../../irrigation/presentation/providers/irrigation_provider.dart';
import '../../../irrigation/data/models/irrigation_preference_model.dart';

class IrrigationPreferencesPage extends ConsumerStatefulWidget {
  const IrrigationPreferencesPage({super.key});

  @override
  ConsumerState<IrrigationPreferencesPage> createState() => _IrrigationPreferencesPageState();
}

class _IrrigationPreferencesPageState extends ConsumerState<IrrigationPreferencesPage> {
  int _selectedDeviceIndex = 0;
  final TextEditingController _waitTimeController = TextEditingController();
  final FocusNode _waitTimeFocusNode = FocusNode();

  @override
  void dispose() {
    _waitTimeController.dispose();
    _waitTimeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);
    
    String selectedDeviceUuid = '';
    if (_selectedDeviceIndex > 0) {
      devicesAsync.whenData((devices) {
        if (_selectedDeviceIndex - 1 < devices.length) {
          selectedDeviceUuid = devices[_selectedDeviceIndex - 1].uuid;
        }
      });
    }

    final preferenceAsync = ref.watch(irrigationPreferenceProvider(selectedDeviceUuid));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Preferências por Dispositivo'),
          centerTitle: true,
        ),
        body: devicesAsync.when(
          data: (devices) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeviceSelector(devices),
                const SizedBox(height: 32),
                _buildTopCard(),
                const SizedBox(height: 32),
                preferenceAsync.when(
                  data: (pref) {
                    // Sync wait time controller with backend value only if not focused
                    if (_waitTimeController.text != pref.dryTimeMinutes.toString() && !_waitTimeFocusNode.hasFocus) {
                      _waitTimeController.text = pref.dryTimeMinutes.toString();
                    }

                    return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.timer_outlined, 'Tempo de Irrigação'),
                      const SizedBox(height: 16),
                      _buildDurationCard(pref, selectedDeviceUuid),
                      const SizedBox(height: 32),
                      _buildSectionTitle(Icons.water_drop_outlined, 'Limite Diário de Água'),
                      const SizedBox(height: 16),
                      _buildLimitCard(pref, selectedDeviceUuid),
                      const SizedBox(height: 32),
                      _buildSectionTitle(Icons.auto_fix_high_outlined, 'Automação Inteligente'),
                      const SizedBox(height: 16),
                      _buildAutomationCard(pref, selectedDeviceUuid),
                      const SizedBox(height: 16),
                      _buildWaitTimeCard(pref, selectedDeviceUuid),
                      const SizedBox(height: 42),
                      _buildSaveButton(pref, selectedDeviceUuid),
                    ],
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                )),
                error: (err, stack) => Center(child: Text('Erro ao carregar preferências: $err')),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar preferências: $err')),
      ),
    ),
    );
  }

  Widget _buildDeviceSelector(List<DeviceModel> devices) {
    final allOptions = ['Visão Geral', ...devices.map((d) => d.name)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_florist_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'SELECIONAR DISPOSITIVO',
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
                      setState(() {
                        _selectedDeviceIndex = index;
                        _waitTimeController.clear();
                      });
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
                      color: isSelected ? AppColors.primary : AppColors.outline.withOpacity(0.2),
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: 20,
            child: Icon(
              Icons.water_drop_rounded,
              size: 140,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: Text(
                    'Ajuste os parâmetros de Irrigação específicos para este dispositivo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard(IrrigationPreferenceModel pref, String deviceUuid) {
    int durationMin = (pref.irrigationDurationSeconds / 60).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duração de cada ciclo de rega nesta zona.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                       final updated = pref.toJson();
                       int newSec = pref.irrigationDurationSeconds - 60;
                       updated['irrigation_duration_seconds'] = newSec < 0 ? 0 : newSec;
                       ref.read(irrigationPreferenceProvider(deviceUuid).notifier).updateLocalPreference(IrrigationPreferenceModel.fromJson(updated));
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$durationMin min',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: () {
                       final updated = pref.toJson();
                       updated['irrigation_duration_seconds'] = pref.irrigationDurationSeconds + 60;
                       ref.read(irrigationPreferenceProvider(deviceUuid).notifier).updateLocalPreference(IrrigationPreferenceModel.fromJson(updated));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitCard(IrrigationPreferenceModel pref, String deviceUuid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Máximo de irrigações/dia',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${pref.maxIrrigationsPerDay}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: const Color(0xFFEEEEE9),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: pref.maxIrrigationsPerDay.toDouble().clamp(0, 10),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) {
                final updated = pref.toJson();
                updated['max_irrigations_per_day'] = value.toInt();
                ref.read(irrigationPreferenceProvider(deviceUuid).notifier).updateLocalPreference(IrrigationPreferenceModel.fromJson(updated));
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('10', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationCard(IrrigationPreferenceModel pref, String deviceUuid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF4EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.touch_app, color: Color(0xFF274029)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Irrigação Automática',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  pref.irrigationMode == 'INTELIGENTE' ? 'Baseado na umidade do dispositivo' : 'Modo Manual',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: pref.enabled,
            onChanged: (value) {
              final updated = pref.toJson();
              updated['enabled'] = value;
              // Set mode to MANUAL if disabled, INTELIGENTE if enabled as per your rule
              updated['irrigation_mode'] = value ? 'INTELIGENTE' : 'MANUAL';
              ref.read(irrigationPreferenceProvider(deviceUuid).notifier).updateLocalPreference(IrrigationPreferenceModel.fromJson(updated));
            },
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitTimeCard(IrrigationPreferenceModel pref, String deviceUuid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_bottom, size: 20, color: Colors.brown),
              const SizedBox(width: 12),
              const Text(
                'Tempo de Espera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tempo que o solo deve permanecer seco nesta zona antes de disparar o ciclo.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEE9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waitTimeController,
                    focusNode: _waitTimeFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    onChanged: (value) {
                       final minutes = int.tryParse(value) ?? 0;
                       final updated = pref.toJson();
                       updated['dry_time_minutes'] = minutes;
                       ref.read(irrigationPreferenceProvider(deviceUuid).notifier).updateLocalPreference(IrrigationPreferenceModel.fromJson(updated));
                    },
                    decoration: const InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Text('min', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(IrrigationPreferenceModel pref, String deviceUuid) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (deviceUuid.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecione um dispositivo para salvar.')),
            );
            return;
          }

          try {
            await ref.read(irrigationPreferenceProvider(deviceUuid).notifier).savePreference(pref);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferências salvas com sucesso!')),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar preferências: $e')),
              );
            }
          }
        },
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar Preferências'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}
