import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../support/presentation/help_categories.dart';
import '../data/soil_health_model.dart';
import 'soil_health_provider.dart';
import 'soil_health_ui.dart';

class SoilHealthPage extends ConsumerWidget {
  const SoilHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(soilHealthProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Saúde do Solo'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Como calculamos',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.helpCategory,
              arguments: HelpCategory.tips,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(soilHealthProvider.future),
        child: healthAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar a saúde do solo.\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => ref.invalidate(soilHealthProvider),
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
          data: (health) => _Content(health: health),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final SoilHealthModel health;

  const _Content({required this.health});

  @override
  Widget build(BuildContext context) {
    final advice = soilHealthAdvice(health);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _ScoreCard(health: health),
        const SizedBox(height: 16),
        if (health.summary.total > 0) ...[
          _SummaryRow(summary: health.summary),
          const SizedBox(height: 16),
        ],
        if (advice.isNotEmpty) ...[
          _AdviceCard(advice: advice),
          const SizedBox(height: 24),
        ],
        if (health.sensors.isNotEmpty) ...[
          const Text(
            'Sensores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 12),
          for (final sensor in health.sensors) ...[
            _SensorCard(sensor: sensor),
            const SizedBox(height: 12),
          ],
        ] else
          Center(
            child: FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addDeviceQrCode),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar sensor'),
            ),
          ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final SoilHealthModel health;

  const _ScoreCard({required this.health});

  @override
  Widget build(BuildContext context) {
    final color = soilHealthColor(health.status);
    final score = health.score;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: (score ?? 0) / 100,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Center(
                  child: Text(
                    score == null ? '–' : '$score',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  soilHealthLabel(health.status),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  score == null
                      ? 'Assim que os sensores enviarem leituras, mostramos aqui.'
                      : 'Tempo com a umidade na faixa ideal nas últimas 24h.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424840),
                    height: 1.4,
                  ),
                ),
                if (health.avgMoisture != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop_rounded,
                        size: 18,
                        color: soilWetColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Umidade média: ${health.avgMoisture}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D3520),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final SoilHealthSummary summary;

  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('OK', summary.ok),
      ('DRY', summary.dry),
      ('WET', summary.wet),
      ('OFFLINE', summary.offline),
      ('FAULT', summary.fault),
    ].where((e) => e.$2 > 0);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (state, count) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: sensorStateColor(state).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sensorStateIcon(state),
                  size: 16,
                  color: sensorStateColor(state),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count ${sensorStateLabel(state).toLowerCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sensorStateColor(state),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final List<String> advice;

  const _AdviceCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mintAccent.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Recomendações',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3520),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tip in advice)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.primary)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Color(0xFF1D3520),
                        height: 1.4,
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
}

class _SensorCard extends StatelessWidget {
  final SensorHealthModel sensor;

  const _SensorCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final color = sensorStateColor(sensor.state);
    final moisture = sensor.soilMoisture;
    final live =
        sensor.state == 'OK' || sensor.state == 'DRY' || sensor.state == 'WET';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sensor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sensorStateIcon(sensor.state), size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      sensorStateLabel(sensor.state),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MoistureBar(
            moisture: live ? moisture : null,
            idealMin: sensor.idealMin,
            idealMax: sensor.idealMax,
            color: color,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  live && moisture != null
                      ? 'Umidade $moisture%'
                      : sensor.state == 'FAULT'
                      ? 'Leitura ignorada até o sensor voltar ao normal'
                      : 'Sem leitura recente',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424840),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ideal ${sensor.idealMin}–${sensor.idealMax}%',
                style: const TextStyle(fontSize: 12, color: AppColors.outline),
              ),
            ],
          ),
          if (sensor.timeInRange24h != null) ...[
            const SizedBox(height: 6),
            Text(
              '${sensor.timeInRange24h}% do tempo na faixa ideal (24h, ${sensor.readings24h} leituras)',
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoistureBar extends StatelessWidget {
  final int? moisture;
  final int idealMin;
  final int idealMax;
  final Color color;

  const _MoistureBar({
    required this.moisture,
    required this.idealMin,
    required this.idealMax,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double x(int pct) => width * pct.clamp(0, 100) / 100;

        return SizedBox(
          height: 14,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              Positioned(
                left: x(idealMin),
                width: x(idealMax) - x(idealMin),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: soilOkColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              if (moisture != null)
                Positioned(
                  left: (x(moisture!) - 7).clamp(0, width - 14),
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
