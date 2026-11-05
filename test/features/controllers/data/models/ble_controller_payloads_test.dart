import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/controllers/data/models/ble_controller_payloads.dart';

void main() {
  group('BleControllerReadyPayload Testes', () {
    test('Deve realizar o parsing correto do JSON ready', () {
      final json = {
        'status': 'ready',
        'device_uid': 'AABBCCDDEEFF',
        'device_name': 'ground_guard_AABBCCDDEEFF',
        'firmware_version': '1.0.0',
        'firmware_build': '1',
      };

      final payload = BleControllerReadyPayload.fromJson(json);

      expect(payload.status, 'ready');
      expect(payload.deviceUid, 'AABBCCDDEEFF');
      expect(payload.deviceName, 'ground_guard_AABBCCDDEEFF');
      expect(payload.firmwareVersion, '1.0.0');
      expect(payload.firmwareBuild, '1');
    });

    test(
      'Deve usar o nome padrão ground_guard_{device_uid} se device_name for vazio',
      () {
        final json = {
          'status': 'ready',
          'device_uid': 'AABBCCDDEEFF',
          'device_name': '',
          'firmware_version': '1.0.0',
          'firmware_build': '1',
        };

        final payload = BleControllerReadyPayload.fromJson(json);

        expect(payload.deviceName, 'ground_guard_AABBCCDDEEFF');
      },
    );

    test(
      'Deve lançar FormatException quando device_uid estiver ausente ou vazio',
      () {
        final json = {
          'status': 'ready',
          'device_uid': '',
          'device_name': 'ground_guard_AABBCCDDEEFF',
        };

        expect(
          () => BleControllerReadyPayload.fromJson(json),
          throwsFormatException,
        );
      },
    );
  });

  group(
    'BleWifiSetupPayload Testes (Garantia de remoção de user_id/user_uuid via BLE)',
    () {
      test(
        'NÃO deve incluir user_id ou user_uuid no payload enviado ao ESP32',
        () {
          final payload = BleWifiSetupPayload(
            wifiSsid: 'Guilherme',
            wifiPassword: 'senha_segura',
          );

          final json = payload.toJson();

          expect(json.containsKey('user_id'), isFalse);
          expect(json.containsKey('user_uuid'), isFalse);
          expect(json['wifi_ssid'], 'Guilherme');
          expect(json['wifi_password'], 'senha_segura');
          expect(json.keys.length, 2);
        },
      );
    },
  );

  group('BleControllerSavedPayload Testes', () {
    test('Deve realizar o parsing correto do JSON saved', () {
      final json = {'status': 'saved', 'device_uid': 'AABBCCDDEEFF'};

      final payload = BleControllerSavedPayload.fromJson(json);

      expect(payload.status, 'saved');
      expect(payload.deviceUid, 'AABBCCDDEEFF');
      expect(payload.isSaved, true);
    });

    test('Deve identificar o erro missing_user_id do ESP32', () {
      final json = {'status': 'error', 'reason': 'missing_user_id'};

      final payload = BleControllerSavedPayload.fromJson(json);

      expect(payload.isSaved, false);
      expect(payload.isMissingUserIdError, true);
    });
  });
}
