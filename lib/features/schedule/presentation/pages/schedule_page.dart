import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/core/theme/app_spacing.dart';
import 'package:ground_guard_app/features/schedule/data/models/schedule_model.dart';
import 'package:ground_guard_app/features/schedule/presentation/providers/schedule_provider.dart';
import 'package:ground_guard_app/features/schedule/presentation/pages/edit_schedule_page.dart';

const _monthNames = [
  'JANEIRO',
  'FEVEREIRO',
  'MARÇO',
  'ABRIL',
  'MAIO',
  'JUNHO',
  'JULHO',
  'AGOSTO',
  'SETEMBRO',
  'OUTUBRO',
  'NOVEMBRO',
  'DEZEMBRO',
];
const _weekDayLabels = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleProvider);
    final schedules = schedulesAsync.valueOrNull ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // DateTime.weekday é 1=segunda..7=domingo; 0=domingo é o índice usado
    // aqui (igual ao days_of_week do backend) e também o índice do label.
    final sunday = today.subtract(Duration(days: today.weekday % 7));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => ref.read(scheduleProvider.notifier).fetchSchedules(),
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
              // Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_monthNames[now.month - 1]} ${now.year}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.2,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.fullCalendar),
                    child: Text(
                      'Mês inteiro',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vertical(15),
              // Date horizontal list: semana real corrente, com uma bolinha
              // nos dias em que existe algum agendamento ativo.
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: List.generate(7, (weekday) {
                    final date = sunday.add(Duration(days: weekday));
                    final hasSchedule = schedules.any(
                      (s) => s.enabled && s.daysOfWeek.contains(weekday),
                    );
                    return _buildDateItem(
                      context,
                      _weekDayLabels[weekday],
                      date.day.toString().padLeft(2, '0'),
                      date == today,
                      hasDot: hasSchedule,
                    );
                  }),
                ),
              ),
              AppSpacing.vertical(30),

              schedulesAsync.when(
                data: (schedules) =>
                    _buildScheduleContent(context, ref, schedules),
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, stack) => _buildErrorState(ref, err),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Falha ao carregar agendamentos.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(scheduleProvider.notifier).fetchSchedules(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(
    BuildContext context,
    WidgetRef ref,
    List<ScheduleModel> schedules,
  ) {
    if (schedules.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum agendamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você ainda não possui horários de irrigação configurados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditSchedulePage()),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Criar Agendamento',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRÓXIMAS REGAS',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 1.2,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
        AppSpacing.vertical(15),
        ...schedules.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: ScheduleCard(
              schedule: s,
              onToggle: (v) =>
                  ref.read(scheduleProvider.notifier).toggleSchedule(s),
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditSchedulePage(schedule: s),
                ),
              ),
              onDelete: () => _showDeleteDialog(context, ref, s),
            ),
          ),
        ),

        AppSpacing.vertical(20),
        // Novo Agendamento Button
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditSchedulePage()),
          ),
          child: CustomPaint(
            painter: DottedBorderPainter(
              color: AppColors.outline.withOpacity(0.5),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Column(
                children: [
                  const Icon(Icons.add, color: AppColors.outline),
                  AppSpacing.vertical(5),
                  Text(
                    'Novo Agendamento',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.vertical(100),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ScheduleModel schedule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Agendamento'),
        content: Text(
          'Deseja excluir o agendamento "${schedule.name ?? 'Rega'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scheduleProvider.notifier).deleteSchedule(schedule.uuid);
              Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Agendamento excluído')),
                );
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
    BuildContext context,
    String day,
    String date,
    bool isSelected, {
    bool hasDot = false,
  }) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vertical(5),
          Text(
            date,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasDot) ...[
            AppSpacing.vertical(2),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ] else if (isSelected) ...[
            AppSpacing.vertical(2),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'Não repetir';
    if (days.length == 7) return 'Diário';

    final labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return days.map((d) => labels[d]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isActive = schedule.enabled;
    final iconColor = isActive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFDB64B);
    final iconBgColor = isActive
        ? AppColors.mintAccent
        : const Color(0xFFFFF4E5);
    final iconData = isActive
        ? Icons.water_drop_outlined
        : Icons.local_florist_outlined;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              AppSpacing.horizontal(15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.startTime,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      schedule.name ?? 'Rega Programada',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onToggle,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          AppSpacing.vertical(15),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.outline),
              AppSpacing.horizontal(5),
              Text(
                '${(schedule.durationSeconds / 60).round()} min',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.outline),
              ),
              AppSpacing.horizontal(15),
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.outline,
              ),
              AppSpacing.horizontal(5),
              Expanded(
                child: Text(
                  _formatDays(schedule.daysOfWeek),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.outline),
                ),
              ),
            ],
          ),
          AppSpacing.vertical(20),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontal(12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
