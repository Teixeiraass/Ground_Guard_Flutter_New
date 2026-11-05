import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/features/soil_health/data/soil_health_model.dart';
import 'package:ground_guard_app/features/soil_health/presentation/soil_health_ui.dart';

Map<String, dynamic> healthJson() => {
  'status': 'GOOD',
  'score': 75,
  'avg_moisture': 55,
  'summary': {'total': 1, 'ok': 1},
  'sensors': [
    {
      'uuid': 's1',
      'name': 'Horta',
      'state': 'OK',
      'soil_moisture': 55,
      'ideal_min': 40,
      'ideal_max': 80,
      'time_in_range_24h': 75,
      'readings_24h': 4,
      'score': 75,
      'last_seen': '2026-11-04T20:00:00Z',
    },
  ],
};

SoilHealthModel model({
  SoilHealthSummary summary = const SoilHealthSummary(),
  int? score,
}) => SoilHealthModel(
  status: 'GOOD',
  summary: summary,
  sensors: const [],
  score: score,
);

void main() {
  group('SoilHealthModel.fromJson', () {
    test('parses status, score, summary and sensors', () {
      final m = SoilHealthModel.fromJson(healthJson());
      expect(m.status, 'GOOD');
      expect(m.score, 75);
      expect(m.avgMoisture, 55);
      expect(m.summary.total, 1);
      expect(m.summary.ok, 1);
      expect(m.summary.dry, 0);
      expect(m.sensors, hasLength(1));

      final s = m.sensors.single;
      expect(s.uuid, 's1');
      expect(s.name, 'Horta');
      expect(s.state, 'OK');
      expect(s.soilMoisture, 55);
      expect(s.idealMin, 40);
      expect(s.idealMax, 80);
      expect(s.timeInRange24h, 75);
      expect(s.readings24h, 4);
      expect(s.score, 75);
      expect(s.lastSeen, isNotNull);
      expect(m.sensor('s1'), same(s));
      expect(m.sensor('nope'), isNull);
    });

    test('falls back to defaults on missing fields', () {
      final m = SoilHealthModel.fromJson({
        'sensors': [
          {'uuid': 'x'},
        ],
      });
      expect(m.status, 'NO_DATA');
      expect(m.score, isNull);
      expect(m.avgMoisture, isNull);
      expect(m.summary.total, 0);
      final s = m.sensors.single;
      expect(s.name, 'Sensor');
      expect(s.state, 'NO_DATA');
      expect(s.idealMin, 35);
      expect(s.idealMax, 80);
      expect(s.readings24h, 0);
      expect(s.lastSeen, isNull);
    });
  });

  group('labels and colors', () {
    test('soilHealthLabel maps every status', () {
      expect(soilHealthLabel('EXCELLENT'), 'Ótima');
      expect(soilHealthLabel('GOOD'), 'Boa');
      expect(soilHealthLabel('ATTENTION'), 'Atenção');
      expect(soilHealthLabel('CRITICAL'), 'Crítica');
      expect(soilHealthLabel('NO_DEVICES'), 'Sem sensores');
      expect(soilHealthLabel('NO_DATA'), 'Sem dados');
    });

    test('sensor states have label, color and icon', () {
      expect(sensorStateLabel('DRY'), 'Seco');
      expect(sensorStateLabel('WET'), 'Encharcado');
      expect(sensorStateLabel('FAULT'), 'Sensor com falha');
      expect(sensorStateColor('FAULT'), AppColors.error);
      expect(sensorStateColor('OFFLINE'), AppColors.outline);
      expect(sensorStateIcon('OFFLINE'), Icons.wifi_off_rounded);
      expect(soilHealthColor('CRITICAL'), AppColors.error);
    });
  });

  group('soilHealthAdvice', () {
    test('asks to add a sensor when there are none', () {
      final tips = soilHealthAdvice(model());
      expect(tips.single, contains('Adicione um sensor'));
    });

    test('reports each problem with correct pluralization', () {
      final tips = soilHealthAdvice(
        model(
          summary: const SoilHealthSummary(
            total: 5,
            fault: 1,
            offline: 2,
            dry: 1,
            wet: 2,
          ),
        ),
      );
      expect(tips, hasLength(4));
      expect(tips[0], startsWith('1 sensor está'));
      expect(tips[1], startsWith('2 sensores estão'));
      expect(tips[2], startsWith('1 zona está'));
      expect(tips[3], contains('encharcadas'));
    });

    test('celebrates when everything is fine', () {
      final tips = soilHealthAdvice(
        model(summary: const SoilHealthSummary(total: 2, ok: 2), score: 95),
      );
      expect(tips.single, startsWith('Tudo certo'));
    });
  });
}
