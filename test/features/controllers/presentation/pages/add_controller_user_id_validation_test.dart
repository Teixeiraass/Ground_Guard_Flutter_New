import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/controllers/data/models/ble_controller_payloads.dart';

void main() {
  group('Garantia de Payload BLE Limpo (Sem user_id / user_uuid)', () {
    test(
      'O payload enviado para o ESP32 deve conter estritamente wifi_ssid e wifi_password',
      () {
        final payload = BleWifiSetupPayload(
          wifiSsid: 'MinhaRede',
          wifiPassword: 'minhasenhadewifi',
        );

        final json = payload.toJson();

        expect(json, {
          'wifi_ssid': 'MinhaRede',
          'wifi_password': 'minhasenhadewifi',
        });
        expect(json.containsKey('user_id'), isFalse);
        expect(json.containsKey('user_uuid'), isFalse);
        expect(json.keys.length, 2);
      },
    );
  });
}
