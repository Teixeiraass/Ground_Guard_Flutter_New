import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/ble_controller_payloads.dart';

class BleControllerService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  static final Uuid serviceUuid = Uuid.parse(
    '7b5e0001-4b37-4f0d-9c2e-8f6f7c0d1001',
  );
  static final Uuid characteristicUuid = Uuid.parse(
    '7b5e0002-4b37-4f0d-9c2e-8f6f7c0d1001',
  );

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  String? _connectedDeviceId;

  String? get connectedDeviceId => _connectedDeviceId;

  /// Solicita permissões necessárias no Android e iOS
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? true;
      final connectGranted =
          statuses[Permission.bluetoothConnect]?.isGranted ?? true;
      final locationGranted = statuses[Permission.location]?.isGranted ?? true;

      return scanGranted && connectGranted && locationGranted;
    } else if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.request();
      return bluetoothStatus.isGranted;
    }
    return true;
  }

  /// Inicia o scan BLE filtrando pelo Service UUID
  Stream<DiscoveredDevice> scanForControllers() {
    _scanSubscription?.cancel();

    final controller = StreamController<DiscoveredDevice>.broadcast();

    _scanSubscription = _ble
        .scanForDevices(
          withServices: [serviceUuid],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            if (!controller.isClosed) {
              controller.add(device);
            }
          },
          onError: (error) {
            if (!controller.isClosed) {
              controller.addError(Exception('Erro no scan BLE: $error'));
            }
          },
        );

    return controller.stream;
  }

  /// Para o scan BLE
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  /// Conecta ao dispositivo BLE selecionado
  Future<void> connectToDevice(
    String deviceId, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    await stopScan();
    await disconnectAndCleanup();

    final completer = Completer<void>();

    _connectionSubscription = _ble
        .connectToDevice(id: deviceId, connectionTimeout: timeout)
        .listen(
          (stateUpdate) {
            debugPrint('BLE Connection state: ${stateUpdate.connectionState}');
            if (stateUpdate.connectionState ==
                DeviceConnectionState.connected) {
              _connectedDeviceId = deviceId;
              if (!completer.isCompleted) completer.complete();
            } else if (stateUpdate.connectionState ==
                DeviceConnectionState.disconnected) {
              if (!completer.isCompleted) {
                completer.completeError(
                  Exception('Falha ao conectar à controladora via BLE.'),
                );
              }
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(Exception('Erro de conexão BLE: $error'));
            }
          },
        );

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        disconnectAndCleanup();
        throw Exception('Timeout ao conectar à controladora via BLE.');
      },
    );
  }

  /// Lê a característica BLE e interpreta o JSON inicial ("status": "ready")
  Future<BleControllerReadyPayload> readReadyPayload(String deviceId) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    try {
      final bytes = await _ble
          .readCharacteristic(characteristic)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Timeout ao ler dados da controladora.'),
          );

      final jsonString = utf8.decode(bytes);
      debugPrint('BLE Ready JSON lido: $jsonString');

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final payload = BleControllerReadyPayload.fromJson(jsonMap);

      if (payload.deviceUid.isEmpty) {
        throw Exception('device_uid ausente na resposta da controladora.');
      }

      return payload;
    } on FormatException catch (e) {
      throw Exception(
        'JSON inválido retornado pela controladora: ${e.message}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Falha ao ler característica da controladora: $e');
    }
  }

  /// Envia a senha e SSID do Wi-Fi e aguarda a resposta ("status": "saved")
  Future<BleControllerSavedPayload> sendWifiSetupAndConfirm({
    required String deviceId,
    required String wifiSsid,
    required String wifiPassword,
  }) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    final payload = BleWifiSetupPayload(
      wifiSsid: wifiSsid,
      wifiPassword: wifiPassword,
    );

    final jsonBytes = utf8.encode(json.encode(payload.toJson()));

    try {
      final completer = Completer<BleControllerSavedPayload>();

      StreamSubscription<List<int>>? notificationSub;
      notificationSub = _ble.subscribeToCharacteristic(characteristic).listen((
        bytes,
      ) {
        try {
          final responseStr = utf8.decode(bytes);
          debugPrint('BLE Notification recebida: $responseStr');
          final Map<String, dynamic> jsonMap = json.decode(responseStr);
          final savedPayload = BleControllerSavedPayload.fromJson(jsonMap);
          if (!completer.isCompleted) {
            completer.complete(savedPayload);
          }
        } catch (_) {}
      });

      await _ble
          .writeCharacteristicWithResponse(characteristic, value: jsonBytes)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Timeout ao enviar dados de Wi-Fi para a controladora.',
            ),
          );

      if (!completer.isCompleted) {
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            if (completer.isCompleted) return;
            final readBytes = await _ble.readCharacteristic(characteristic);
            final readStr = utf8.decode(readBytes);
            debugPrint('BLE Read pós-envio: $readStr');
            final Map<String, dynamic> jsonMap = json.decode(readStr);
            final savedPayload = BleControllerSavedPayload.fromJson(jsonMap);
            if (!completer.isCompleted) completer.complete(savedPayload);
          } catch (_) {}
        });
      }

      final result = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          notificationSub?.cancel();
          throw Exception(
            'Timeout aguardando confirmação Wi-Fi da controladora.',
          );
        },
      );

      await notificationSub.cancel();

      if (!result.isSaved) {
        if (result.isMissingUserIdError) {
          throw Exception(
            'Não foi possível identificar o usuário autenticado.',
          );
        }
        throw Exception(
          'Wi-Fi rejeitado pela controladora. Verifique o SSID e a senha.',
        );
      }

      return result;
    } on FormatException catch (e) {
      throw Exception('Resposta JSON inválida da controladora: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro na comunicação Wi-Fi com a controladora: $e');
    }
  }

  /// Cancela o scan, desconecta e limpa todos os recursos em qualquer fluxo
  Future<void> disconnectAndCleanup() async {
    await stopScan();
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _connectedDeviceId = null;
  }
}
