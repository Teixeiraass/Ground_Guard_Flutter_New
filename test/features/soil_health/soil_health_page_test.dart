import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/soil_health/data/soil_health_model.dart';
import 'package:ground_guard_app/features/soil_health/presentation/soil_health_page.dart';
import 'package:ground_guard_app/features/soil_health/presentation/soil_health_provider.dart';

Future<void> pumpPage(WidgetTester tester, SoilHealthModel health) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [soilHealthProvider.overrideWith((ref) async => health)],
      child: const MaterialApp(home: SoilHealthPage()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows score, label, average moisture and each sensor', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const SoilHealthModel(
        status: 'GOOD',
        score: 75,
        avgMoisture: 55,
        summary: SoilHealthSummary(total: 2, ok: 1, dry: 1),
        sensors: [
          SensorHealthModel(
            uuid: 's1',
            name: 'Horta',
            state: 'OK',
            soilMoisture: 60,
            idealMin: 35,
            idealMax: 80,
            timeInRange24h: 90,
            readings24h: 12,
            score: 90,
          ),
          SensorHealthModel(
            uuid: 's2',
            name: 'Canteiro',
            state: 'DRY',
            soilMoisture: 20,
            idealMin: 35,
            idealMax: 80,
          ),
        ],
      ),
    );

    expect(find.text('Saúde do Solo'), findsOneWidget);
    expect(find.text('75'), findsOneWidget);
    expect(find.text('Boa'), findsOneWidget);
    expect(find.text('Umidade média: 55%'), findsOneWidget);
    expect(find.text('Recomendações'), findsOneWidget);
    expect(find.textContaining('1 zona está'), findsOneWidget);
    expect(find.text('Horta'), findsOneWidget);
    expect(find.text('Umidade 60%'), findsOneWidget);
    expect(
      find.text('90% do tempo na faixa ideal (24h, 12 leituras)'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Canteiro'), 200);
    expect(find.text('Canteiro'), findsOneWidget);
    expect(find.text('Seco'), findsWidgets);
  });

  testWidgets('a faulty sensor hides its stale reading', (tester) async {
    await pumpPage(
      tester,
      const SoilHealthModel(
        status: 'NO_DATA',
        summary: SoilHealthSummary(total: 1, fault: 1),
        sensors: [
          SensorHealthModel(
            uuid: 's1',
            name: 'Horta',
            state: 'FAULT',
            soilMoisture: 55,
            idealMin: 35,
            idealMax: 80,
          ),
        ],
      ),
    );

    expect(find.text('Sem dados'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);
    expect(find.text('Sensor com falha'), findsWidgets);
    expect(
      find.text('Leitura ignorada até o sensor voltar ao normal'),
      findsOneWidget,
    );
    expect(find.text('Umidade 55%'), findsNothing);
  });

  testWidgets('no sensors offers to add one', (tester) async {
    await pumpPage(
      tester,
      const SoilHealthModel(
        status: 'NO_DEVICES',
        summary: SoilHealthSummary(),
        sensors: [],
      ),
    );

    expect(find.text('Sem sensores'), findsOneWidget);
    expect(find.text('Adicionar sensor'), findsOneWidget);
  });
}
