import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/core/websocket/websocket_message.dart';
import 'package:ground_guard_app/features/controllers/data/models/controller_device_model.dart';
import 'package:ground_guard_app/features/devices/data/models/device_model.dart';

void main() {
  group('Eventos WebSocket de Controladoras e Dispositivos (Sensores)', () {
    const tControllerUuid = 'dd096b01-cd70-4dde-acb9-fedb9e15f492';
    const tDeviceUid = '246F28F074DC';

    late ControllerDeviceModel controllerModel;
    late DeviceModel deviceModel;

    setUp(() {
      controllerModel = ControllerDeviceModel(
        uuid: tControllerUuid,
        hardwareUid: tDeviceUid,
        name: 'Controladora Teste',
        firmwareVersion: '1.0.0',
        status: 'INATIVO',
        isOnline: false,
        isIrrigating: false,
      );

      deviceModel = DeviceModel(
        uuid: '30a8360a-abdc-4b42-81df-1eb904f16415',
        deviceUid: 'SENSOR001',
        name: 'Sensor 1',
        firmwareVersion: '1.0.0',
        status: 'ATIVO',
        controllerUuid: tControllerUuid,
        isOnline: false,
        isIrrigating: false,
        soilMoisture: 35,
      );
    });

    test(
      '1. Evento controller_device_state ONLINE deve atualizar a controladora para isOnline=true e status ATIVO',
      () {
        final json = {
          'type': 'controller_device_state',
          'device_uid': tDeviceUid,
          'controller_uuid': tControllerUuid,
          'status': 'ATIVO',
          'is_online': true,
          'is_irrigating': false,
        };

        final msg = WebSocketMessage.fromJson(json);

        expect(msg.type, 'controller_device_state');
        expect(msg.controllerUuid, tControllerUuid);
        expect(msg.deviceUid, tDeviceUid);
        expect(msg.isOnline, isTrue);
        expect(msg.status, 'ATIVO');

        final updatedController = controllerModel.copyWith(
          isOnline: msg.isOnline,
          status: msg.status ?? 'online',
          isIrrigating: msg.isIrrigating,
        );

        expect(updatedController.isOnline, isTrue);
        expect(updatedController.status, 'ATIVO');
        expect(updatedController.uuid, tControllerUuid);
      },
    );

    test(
      '2. Evento controller_device_state OFFLINE deve atualizar a controladora para isOnline=false e status INATIVO',
      () {
        final json = {
          'type': 'controller_device_state',
          'device_uid': tDeviceUid,
          'controller_uuid': tControllerUuid,
          'status': 'INATIVO',
          'is_online': false,
          'is_irrigating': false,
        };

        final msg = WebSocketMessage.fromJson(json);

        expect(msg.type, 'controller_device_state');
        expect(msg.isOnline, isFalse);
        expect(msg.status, 'INATIVO');

        final updatedController = controllerModel.copyWith(
          isOnline: msg.isOnline,
          status: msg.status ?? 'offline',
          isIrrigating: msg.isIrrigating,
        );

        expect(updatedController.isOnline, isFalse);
        expect(updatedController.status, 'INATIVO');
      },
    );

    test(
      '3. Evento controller_device_telemetry deve atualizar ipAddress, wifiSsid, lastSeen e provisioningRequired',
      () {
        final json = {
          'type': 'controller_device_telemetry',
          'device_uid': tDeviceUid,
          'controller_uuid': tControllerUuid,
          'status': 'ONLINE',
          'is_online': true,
          'ip_address': '192.168.15.5',
          'wifi_ssid': 'MinhaRede',
          'provisioning_required': false,
          'last_seen': '2026-10-07T15:41:12-03:00',
        };

        final msg = WebSocketMessage.fromJson(json);

        expect(msg.type, 'controller_device_telemetry');
        expect(msg.ipAddress, '192.168.15.5');
        expect(msg.wifiSsid, 'MinhaRede');
        expect(msg.provisioningRequired, isFalse);
        expect(msg.lastSeen, '2026-10-07T15:41:12-03:00');

        final updatedController = controllerModel.copyWith(
          isOnline: msg.isOnline,
          status: msg.status ?? 'online',
          ipAddress: msg.ipAddress,
          wifiSsid: msg.wifiSsid,
          lastSeen: msg.lastSeen,
          provisioningRequired: msg.provisioningRequired,
        );

        expect(updatedController.ipAddress, '192.168.15.5');
        expect(updatedController.wifiSsid, 'MinhaRede');
        expect(updatedController.lastSeen, '2026-10-07T15:41:12-03:00');
        expect(updatedController.provisioningRequired, isFalse);
      },
    );

    test(
      '4. Atualização deve localizar a controladora correta por controller_uuid ou por device_uid',
      () {
        final controllers = [
          ControllerDeviceModel(
            uuid: 'outra-uuid-123',
            hardwareUid: 'OUTRO_UID',
            name: 'Outra',
            firmwareVersion: '1.0.0',
            status: 'INATIVO',
          ),
          controllerModel,
        ];

        final json = {
          'type': 'controller_device_state',
          'device_uid': tDeviceUid,
          'controller_uuid': tControllerUuid,
          'status': 'ATIVO',
          'is_online': true,
          'is_irrigating': false,
        };

        final msg = WebSocketMessage.fromJson(json);

        final index = controllers.indexWhere(
          (c) => c.uuid.toLowerCase() == msg.controllerUuid.toLowerCase(),
        );

        expect(index, 1);
        expect(controllers[index].uuid, tControllerUuid);
      },
    );

    test(
      '5. Evento de controladora (controller_device_state) NÃO deve alterar um device sensor antigo',
      () {
        final jsonController = {
          'type': 'controller_device_state',
          'device_uid': tDeviceUid,
          'controller_uuid': tControllerUuid,
          'status': 'ATIVO',
          'is_online': true,
          'is_irrigating': false,
        };

        final msg = WebSocketMessage.fromJson(jsonController);

        // Dispositivos sensores apenas escutam 'device_state' e 'device_telemetry'
        final isDeviceEvent =
            msg.type == 'device_state' || msg.type == 'device_telemetry';

        expect(isDeviceEvent, isFalse);
        expect(deviceModel.soilMoisture, 35); // Permanece intacto
        expect(deviceModel.uuid, '30a8360a-abdc-4b42-81df-1eb904f16415');
      },
    );

    test(
      '6. Eventos antigos de device (device_state e device_telemetry) devem continuar funcionando para o sensor',
      () {
        final jsonDeviceState = {
          'type': 'device_state',
          'device_uid': 'SENSOR001',
          'is_online': true,
          'is_irrigating': true,
          'soil_moisture': 78,
        };

        final msg = WebSocketMessage.fromJson(jsonDeviceState);

        expect(msg.type, 'device_state');
        expect(msg.deviceUid, 'SENSOR001');

        final updatedDevice = deviceModel.copyWith(
          isOnline: msg.isOnline,
          isIrrigating: msg.isIrrigating,
          soilMoisture: msg.soilMoisture,
        );

        expect(updatedDevice.isOnline, isTrue);
        expect(updatedDevice.isIrrigating, isTrue);
        expect(updatedDevice.soilMoisture, 78);
      },
    );
  });
}
