import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/schedule_model.dart';
import '../providers/schedule_provider.dart';

class FullCalendarPage extends ConsumerStatefulWidget {
  const FullCalendarPage({super.key});

  @override
  ConsumerState<FullCalendarPage> createState() => _FullCalendarPageState();
}

class _FullCalendarPageState extends ConsumerState<FullCalendarPage> {
  DateTime _selectedDate = DateTime.now();

  // DateTime.weekday é 1=segunda..7=domingo; o backend usa 0=domingo..6=sábado.
  int get _selectedWeekday => _selectedDate.weekday % 7;

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          'Calendário de Regas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.event_available, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    'Eventos para o dia selecionado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: schedulesAsync.when(
                data: (schedules) {
                  final dayEvents =
                      schedules
                          .where(
                            (s) =>
                                s.enabled &&
                                s.daysOfWeek.contains(_selectedWeekday),
                          )
                          .toList()
                        ..sort((a, b) => a.startTime.compareTo(b.startTime));

                  if (dayEvents.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum evento neste dia',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) =>
                        _buildEventTile(dayEvents[index]),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) =>
                    Center(child: Text('Erro ao carregar agendamentos: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(ScheduleModel schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.startTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                schedule.name ?? 'Agendamento de irrigação',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
