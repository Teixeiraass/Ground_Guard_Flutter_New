import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Calendar Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OUTUBRO 2023',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                ),
                Text(
                  'Mês inteiro',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            AppSpacing.vertical(15),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _buildDateItem(context, 'DOM', '15', false),
                  _buildDateItem(context, 'SEG', '16', true),
                  _buildDateItem(context, 'TER', '17', false),
                  _buildDateItem(context, 'QUA', '18', false, hasDot: true),
                  _buildDateItem(context, 'QUI', '19', false),
                  _buildDateItem(context, 'SEX', '20', false),
                ],
              ),
            ),
            AppSpacing.vertical(30),

            // Próximas Regas Section
            Text(
              'PRÓXIMAS REGAS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
            ),
            AppSpacing.vertical(15),
            const ScheduleCard(
              time: '06:30 AM',
              title: 'Jardim Frontal',
              duration: '15 min',
              days: 'Seg, Qua, Sex',
              isActive: true,
              iconData: Icons.water_drop_outlined,
              iconColor: Color(0xFF4CAF50),
              iconBgColor: AppColors.mintAccent,
            ),
            AppSpacing.vertical(15),
            const ScheduleCard(
              time: '07:45 AM',
              title: 'Horta Comunitária',
              duration: '10 min',
              days: 'Diário',
              isActive: false,
              iconData: Icons.local_florist_outlined,
              iconColor: Color(0xFFFDB64B),
              iconBgColor: Color(0xFFFFF4E5),
            ),
            AppSpacing.vertical(20),

            // New Schedule Button (Dotted Border)
            CustomPaint(
              painter: DottedBorderPainter(color: AppColors.outline.withOpacity(0.5)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    const Icon(Icons.add, color: AppColors.outline),
                    AppSpacing.vertical(5),
                    Text(
                      'Novo Agendamento',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vertical(30),

            // Repetition Config Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                      AppSpacing.horizontal(10),
                      Text(
                        'Configuração de Repetição',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  AppSpacing.vertical(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDaySelector('D', true),
                      _buildDaySelector('S', false),
                      _buildDaySelector('T', true),
                      _buildDaySelector('Q', false),
                      _buildDaySelector('Q', true),
                      _buildDaySelector('S', false),
                      _buildDaySelector('S', false),
                    ],
                  ),
                  AppSpacing.vertical(15),
                  Text(
                    'Irrigação programada para dias de sol intenso e solo seco.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                        ),
                  ),
                ],
              ),
            ),
            AppSpacing.vertical(100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.alarm_add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDateItem(BuildContext context, String day, String date, bool isSelected, {bool hasDot = false}) {
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
                  color: isSelected ? Colors.white.withOpacity(0.7) : AppColors.outline,
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
            const Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.white),
          ]
        ],
      ),
    );
  }

  Widget _buildDaySelector(String label, bool isSelected) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.outline,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String time;
  final String title;
  final String duration;
  final String days;
  final bool isActive;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;

  const ScheduleCard({
    super.key,
    required this.time,
    required this.title,
    required this.duration,
    required this.days,
    required this.isActive,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
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
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      title,
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
                onChanged: (value) {},
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
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
              ),
              AppSpacing.horizontal(15),
              const Icon(Icons.calendar_today, size: 16, color: AppColors.outline),
              AppSpacing.horizontal(5),
              Text(
                days,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
              ),
            ],
          ),
          AppSpacing.vertical(20),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
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
                  onPressed: () {},
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
