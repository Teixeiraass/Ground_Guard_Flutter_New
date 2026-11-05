import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/devices/data/models/device_model.dart';

void main() {
  final json = <String, dynamic>{
    'uuid': '30a8360a-abdc-4b42-81df-1eb904f16415',
    'device_uid': 'ABCDEF123456',
    'name': 'Horta',
    'status': 'ATIVO',
    'is_online': true,
    'soil_moisture': 55,
    'sensor_ok': false,
    'wifi_rssi': -61,
    'latitude': -23.55,
    'longitude': -46.63,
  };

  test('parses the new health and location fields', () {
    final d = DeviceModel.fromJson(json);
    expect(d.soilMoisture, 55);
    expect(d.sensorOk, isFalse);
    expect(d.wifiRssi, -61);
    expect(d.latitude, -23.55);
    expect(d.longitude, -46.63);
    expect(d.hasLocation, isTrue);
  });

  test('accepts integer coordinates from JSON', () {
    final d = DeviceModel.fromJson({
      ...json,
      'latitude': -23,
      'longitude': -46,
    });
    expect(d.latitude, -23.0);
    expect(d.longitude, -46.0);
  });

  test('older payloads without the fields stay null', () {
    final d = DeviceModel.fromJson({
      'uuid': 'x',
      'device_uid': 'y',
      'name': 'z',
    });
    expect(d.sensorOk, isNull);
    expect(d.wifiRssi, isNull);
    expect(d.hasLocation, isFalse);
  });

  test('hasLocation needs both coordinates', () {
    final d = DeviceModel.fromJson({...json, 'longitude': null});
    expect(d.hasLocation, isFalse);
  });

  test('copyWith keeps or sets fields, and clearLocation removes the pin', () {
    final d = DeviceModel.fromJson(json);

    final same = d.copyWith(name: 'Novo');
    expect(same.latitude, d.latitude);
    expect(same.sensorOk, d.sensorOk);

    final moved = d.copyWith(latitude: 1.5, longitude: 2.5, sensorOk: true);
    expect(moved.latitude, 1.5);
    expect(moved.longitude, 2.5);
    expect(moved.sensorOk, isTrue);

    final cleared = d.copyWith(clearLocation: true);
    expect(cleared.latitude, isNull);
    expect(cleared.longitude, isNull);
    expect(cleared.hasLocation, isFalse);
    expect(cleared.name, 'Horta');
  });

  test('toJson round-trips the new fields', () {
    final d = DeviceModel.fromJson(json);
    final again = DeviceModel.fromJson(d.toJson());
    expect(again.sensorOk, d.sensorOk);
    expect(again.wifiRssi, d.wifiRssi);
    expect(again.latitude, d.latitude);
    expect(again.longitude, d.longitude);
  });
}
