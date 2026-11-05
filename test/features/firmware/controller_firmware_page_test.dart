import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/controllers/data/models/controller_device_model.dart';
import 'package:ground_guard_app/features/firmware/data/controller_firmware_model.dart';
import 'package:ground_guard_app/features/firmware/presentation/controller_firmware_page.dart';
import 'package:ground_guard_app/features/firmware/presentation/firmware_provider.dart';

final controller = ControllerDeviceModel(
  uuid: 'c1',
  hardwareUid: 'AABBCCDDEEFF',
  name: 'Jardim',
  firmwareVersion: '1.0.0',
  status: 'ATIVO',
);

Future<void> pumpPage(WidgetTester tester, ControllerFirmwareModel fw) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        controllerFirmwareProvider.overrideWith((ref, uuid) async => fw),
      ],
      child: MaterialApp(home: ControllerFirmwarePage(controller: controller)),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('update available: shows notes and asks before updating', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const ControllerFirmwareModel(
        controllerUuid: 'c1',
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
        releaseNotes: 'Rega mais precisa',
        updateAvailable: true,
        autoUpdate: false,
      ),
    );

    expect(find.text('Jardim'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('Nova versão v1.1.0 disponível'), findsOneWidget);
    expect(find.text('Rega mais precisa'), findsOneWidget);
    expect(find.text('Atualizar automaticamente'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.text('Atualizar agora'));
    await tester.pumpAndSettle();
    expect(find.text('Atualizar para 1.1.0?'), findsOneWidget);

    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();
    expect(find.text('Atualizar para 1.1.0?'), findsNothing);
  });

  testWidgets('offline controller can not be updated', (tester) async {
    await pumpPage(
      tester,
      const ControllerFirmwareModel(
        controllerUuid: 'c1',
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
        updateAvailable: true,
        autoUpdate: true,
        blockedReason: 'OFFLINE',
      ),
    );

    expect(
      find.text('A controladora precisa estar online para atualizar.'),
      findsOneWidget,
    );
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Atualizar agora'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(button.onPressed, isNull);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('a failed update explains what happened', (tester) async {
    await pumpPage(
      tester,
      const ControllerFirmwareModel(
        controllerUuid: 'c1',
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
        updateAvailable: true,
        autoUpdate: false,
        otaStatus: 'FAILED',
        otaError: 'rolled_back',
      ),
    );

    expect(find.textContaining('voltou sozinha'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('in progress: shows the download instead of the button', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const ControllerFirmwareModel(
        controllerUuid: 'c1',
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
        updateAvailable: true,
        autoUpdate: false,
        otaStatus: 'DOWNLOADING',
        otaTargetVersion: '1.1.0',
        blockedReason: 'IN_PROGRESS',
      ),
    );

    expect(find.text('Baixando e instalando v1.1.0...'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Atualizar agora'), findsNothing);
  });

  testWidgets('up to date', (tester) async {
    await pumpPage(
      tester,
      const ControllerFirmwareModel(
        controllerUuid: 'c1',
        currentVersion: '1.1.0',
        latestVersion: '1.1.0',
        updateAvailable: false,
        autoUpdate: false,
      ),
    );

    expect(
      find.text('Sua controladora está na versão mais recente.'),
      findsOneWidget,
    );
    expect(find.text('Atualizada'), findsOneWidget);
  });
}
