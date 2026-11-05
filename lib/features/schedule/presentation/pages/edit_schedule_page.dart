import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/components/adaptive_dropdown.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/features/device_groups/presentation/providers/device_groups_provider.dart';
import 'package:ground_guard_app/features/devices/presentation/providers/devices_provider.dart';
import 'package:ground_guard_app/features/schedule/data/models/schedule_model.dart';
import 'package:ground_guard_app/features/schedule/presentation/providers/schedule_provider.dart';

class EditSchedulePage extends ConsumerStatefulWidget {
  final ScheduleModel? schedule;
  /// Quando informado (e [schedule] for null, ou seja, criação), a tela
  /// abre já em modo "Grupo" com esse grupo pré-selecionado.
  final String? presetGroupUuid;
  const EditSchedulePage({super.key, this.schedule, this.presetGroupUuid});

  @override
  ConsumerState<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends ConsumerState<EditSchedulePage> {
  late TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late Set<int> _selectedDays;
  late int _durationMinutes;
  late String _irrigationMode; // 'DURATION' ou 'HUMIDITY'
  late int _moistureThreshold;
  String? _selectedDeviceUuid;
  late bool _isGroupMode;
  String? _selectedGroupUuid;

  // Editar um agendamento existente é sempre por dispositivo único (grupo é
  // só um atalho de criação em lote); o toggle só aparece ao criar.
  bool get _canToggleGroupMode => widget.schedule == null;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nameController = TextEditingController(text: s?.name ?? '');
    _isGroupMode = widget.presetGroupUuid != null && s == null;
    _selectedGroupUuid = widget.presetGroupUuid;

    if (s != null) {
      final parts = s.startTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      _selectedDays = s.daysOfWeek.toSet();
      _durationMinutes = (s.durationSeconds / 60).round();
      _selectedDeviceUuid = s.deviceUuid;
      _irrigationMode = s.irrigationMode;
      _moistureThreshold = s.moistureThreshold ?? 50;
    } else {
      _selectedTime = const TimeOfDay(hour: 6, minute: 30);
      _selectedDays = {1, 2, 3, 4, 5}; // Dias de semana por padrão
      _durationMinutes = 15;
      _irrigationMode = 'DURATION';
      _moistureThreshold = 50;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_isGroupMode) {
      await _saveGroupSchedule();
      return;
    }

    if (_selectedDeviceUuid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um dispositivo')));
      return;
    }

    final newSchedule = ScheduleModel(
      uuid: widget.schedule?.uuid ?? '',
      deviceUuid: _selectedDeviceUuid!,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      startTime: _formattedStartTime(),
      durationSeconds: _durationMinutes * 60,
      daysOfWeek: _selectedDays.toList()..sort(),
      enabled: widget.schedule?.enabled ?? true,
      irrigationMode: _irrigationMode,
      moistureThreshold: _moistureThreshold,
    );

    try {
      if (widget.schedule == null) {
        await ref.read(scheduleProvider.notifier).addSchedule(newSchedule);
      } else {
        await ref.read(scheduleProvider.notifier).updateSchedule(newSchedule);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Backend espera estritamente "HH:MM" (sem segundos) em start_time.
  String _formattedStartTime() =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  Future<void> _saveGroupSchedule() async {
    if (_selectedGroupUuid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um grupo')));
      return;
    }

    final body = {
      'name': _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      'start_time': _formattedStartTime(),
      'duration_seconds': _durationMinutes * 60,
      'days_of_week': (_selectedDays.toList()..sort()).join(','),
      'irrigation_mode': _irrigationMode,
      'moisture_threshold': _irrigationMode == 'HUMIDITY'
          ? _moistureThreshold
          : null,
    };

    try {
      final count = await ref
          .read(deviceGroupsRepositoryProvider)
          .createSchedule(_selectedGroupUuid!, body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count agendamento(s) criados para o grupo.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider).value ?? [];
    final groups = ref.watch(deviceGroupsProvider).value ?? [];
    final List<String> daysLabels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    // Garante que o valor selecionado existe na lista para não crashar o Dropdown
    String? dropdownValue = _selectedDeviceUuid;
    if (dropdownValue != null && !devices.any((d) => d.uuid == dropdownValue)) {
      dropdownValue = null;
    }
    String? groupDropdownValue = _selectedGroupUuid;
    if (groupDropdownValue != null &&
        !groups.any((g) => g.uuid == groupDropdownValue)) {
      groupDropdownValue = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: Text(
          widget.schedule == null ? 'Novo Agendamento' : 'Editar Agendamento',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Nome do Agendamento (Opcional)'),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Rega Manhã',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_canToggleGroupMode) ...[
                _buildSectionTitle('Aplicar a'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeOption(
                        label: 'Dispositivo único',
                        icon: Icons.sensors_rounded,
                        selected: !_isGroupMode,
                        onTap: () => setState(() => _isGroupMode = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeOption(
                        label: 'Grupo',
                        icon: Icons.workspaces_outline,
                        selected: _isGroupMode,
                        onTap: () => setState(() => _isGroupMode = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              _buildSectionTitle(_isGroupMode ? 'Grupo' : 'Dispositivo'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isGroupMode
                    ? AdaptiveDropdown(
                        value: groupDropdownValue,
                        title: 'Selecione o grupo',
                        hint: const Text(
                          'Selecione o grupo',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        itemTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1D3520),
                          fontWeight: FontWeight.w600,
                        ),
                        isExpanded: true,
                        items: groups
                            .map(
                              (g) => AdaptiveDropdownItem(
                                value: g.uuid,
                                label: '${g.name} (${g.deviceCount})',
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedGroupUuid = v),
                      )
                    : AdaptiveDropdown(
                        value: dropdownValue,
                        title: 'Selecione o Ground Guard',
                        hint: const Text(
                          'Selecione o Ground Guard',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        itemTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1D3520),
                          fontWeight: FontWeight.w600,
                        ),
                        isExpanded: true,
                        items: devices
                            .map(
                              (d) => AdaptiveDropdownItem(
                                value: d.uuid,
                                label: d.name,
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedDeviceUuid = v;
                          dropdownValue = v;
                        }),
                      ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Horário da Rega'),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3520),
                        ),
                      ),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Repetir nos dias'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDays.contains(index);
                  return GestureDetector(
                    onTap: () => setState(
                      () => isSelected
                          ? _selectedDays.remove(index)
                          : _selectedDays.add(index),
                    ),
                    child: Container(
                      width: 42,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        daysLabels[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Encerrar irrigação'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildModeOption(
                      label: 'Por duração',
                      icon: Icons.timer_outlined,
                      selected: _irrigationMode == 'DURATION',
                      onTap: () =>
                          setState(() => _irrigationMode = 'DURATION'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeOption(
                      label: 'Por umidade',
                      icon: Icons.water_drop_outlined,
                      selected: _irrigationMode == 'HUMIDITY',
                      onTap: () =>
                          setState(() => _irrigationMode = 'HUMIDITY'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_irrigationMode == 'HUMIDITY') ...[
                _buildSectionTitle('Umidade alvo: $_moistureThreshold%'),
                const SizedBox(height: 8),
                Slider(
                  value: _moistureThreshold.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: AppColors.primary,
                  onChanged: (v) =>
                      setState(() => _moistureThreshold = v.round()),
                ),
                const SizedBox(height: 8),
              ],
              _buildSectionTitle(
                _irrigationMode == 'HUMIDITY'
                    ? 'Duração máxima (segurança): $_durationMinutes min'
                    : 'Duração: $_durationMinutes min',
              ),
              const SizedBox(height: 8),
              Slider(
                value: _durationMinutes.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _durationMinutes = v.round()),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.schedule == null
                      ? (_isGroupMode
                            ? 'Criar Agendamento do Grupo'
                            : 'Criar Agendamento')
                      : 'Salvar Alterações',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    if (Platform.isIOS) {
      TimeOfDay tempTime = _selectedTime;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (sheetContext) => Container(
          height: 280,
          color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: const Text('Confirmar'),
                      onPressed: () {
                        setState(() => _selectedTime = tempTime);
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: DateTime(
                      2024,
                      1,
                      1,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    ),
                    onDateTimeChanged: (value) {
                      tempTime = TimeOfDay(
                        hour: value.hour,
                        minute: value.minute,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (time != null) setState(() => _selectedTime = time);
    }
  }

  Widget _buildModeOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}
