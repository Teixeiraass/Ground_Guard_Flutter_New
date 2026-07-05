import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/devices/data/models/device_model.dart';

void main() {
  group('DeviceModel', () {
    final tDeviceJson = {
      'uuid': '123',
      'device_uid': 'abc',
      'name': 'Sensor 1',
      'firmware_version': '1.0.0',
      'status': 'ATIVO',
    };

    test('should return a valid model from JSON', () {
      final result = DeviceModel.fromJson(tDeviceJson);

      expect(result.uuid, '123');
      expect(result.name, 'Sensor 1');
      expect(result.status, 'ATIVO');
    });

    test('should return a JSON map containing proper data', () {
      final model = DeviceModel(
        uuid: '123',
        deviceUid: 'abc',
        name: 'Sensor 1',
        firmwareVersion: '1.0.0',
        status: 'ATIVO',
      );

      final result = model.toJson();

      expect(result['uuid'], '123');
      expect(result['name'], 'Sensor 1');
    });
  });
}
