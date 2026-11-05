import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/websocket/websocket_provider.dart';
import '../../../irrigation/presentation/providers/irrigation_provider.dart';
import '../../data/datasources/devices_remote_datasource.dart';
import '../../data/repositories/devices_repository_impl.dart';
import '../../domain/repositories/devices_repository.dart';
import '../../data/models/device_model.dart';
import '../../../controllers/presentation/providers/controllers_provider.dart';

final devicesRemoteDataSourceProvider = Provider<DevicesRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return DevicesRemoteDataSourceImpl(dio);
});

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final remoteDataSource = ref.watch(devicesRemoteDataSourceProvider);
  return DevicesRepositoryImpl(remoteDataSource);
});

final devicesProvider =
    StateNotifierProvider<DevicesNotifier, AsyncValue<List<DeviceModel>>>((
      ref,
    ) {
      final repository = ref.watch(devicesRepositoryProvider);
      return DevicesNotifier(repository, ref);
    });

class DevicesNotifier extends StateNotifier<AsyncValue<List<DeviceModel>>> {
  final DevicesRepository _repository;
  final Ref _ref;

  DevicesNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    fetchDevices();
    _listenToWebSocket();
    _listenToSelectedController();
  }

  void _listenToSelectedController() {
    _ref.listen(selectedControllerProvider, (previous, next) {
      if (previous?.uuid != next?.uuid) {
        fetchDevices();
      }
    });
  }

  void _listenToWebSocket() {
    _ref.listen(webSocketMessagesProvider, (previous, next) {
      next.whenData((message) {
        if (message.type == 'device_state') {
          _updateDeviceState(
            message.deviceUid,
            message.isOnline,
            message.isIrrigating,
            message.soilMoisture,
          );
        } else if (message.type == 'device_telemetry') {
          _updateDeviceTelemetry(
            message.deviceUid,
            message.soilMoisture,
            message.sensorOk,
          );
        }
      });
    });
  }

  void _updateDeviceState(
    String deviceUid,
    bool isOnline,
    bool isIrrigating,
    int? soilMoisture,
  ) {
    if (!mounted) return;
    state.whenData((devices) {
      final updatedDevices = devices.map((device) {
        if (_compareIds(device.deviceUid, deviceUid)) {
          if (device.isIrrigating && !isIrrigating) {
            _ref.read(irrigationControllerProvider.notifier).reset();
          }

          return device.copyWith(
            isOnline: isOnline,
            isIrrigating: isIrrigating,
            soilMoisture: soilMoisture,
          );
        }
        return device;
      }).toList();
      state = AsyncValue.data(updatedDevices);
    });
  }

  void _updateDeviceTelemetry(
    String deviceUid,
    int? soilMoisture,
    bool? sensorOk,
  ) {
    if (!mounted) return;
    state.whenData((devices) {
      final updatedDevices = devices.map((device) {
        if (_compareIds(device.deviceUid, deviceUid)) {
          return device.copyWith(
            soilMoisture: soilMoisture,
            sensorOk: sensorOk,
            isOnline: true,
          );
        }
        return device;
      }).toList();
      state = AsyncValue.data(updatedDevices);
    });
  }

  bool _compareIds(String id1, String id2) {
    final clean1 = id1.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final clean2 = id2.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    return clean1 == clean2 && clean1.isNotEmpty;
  }

  Future<void> fetchDevices() async {
    final selectedController = _ref.read(selectedControllerProvider);

    if (selectedController == null || selectedController.uuid.trim().isEmpty) {
      if (mounted) {
        state = const AsyncValue.data([]);
      }
      return;
    }

    final controllerUuid = selectedController.uuid.trim();
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!uuidRegex.hasMatch(controllerUuid)) {
      if (mounted) {
        state = AsyncValue.error(
          Exception(
            'A controladora selecionada possui um UUID inválido ($controllerUuid).',
          ),
          StackTrace.current,
        );
      }
      return;
    }

    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      final devicesData = await _repository.getDevicesList(
        controllerUuid: controllerUuid,
      );
      if (!mounted) return;

      state = AsyncValue.data(devicesData);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<DeviceModel> linkDevice(
    String qrToken, {
    String? controllerUuid,
  }) async {
    try {
      final activeController =
          controllerUuid ?? _ref.read(selectedControllerProvider)?.uuid ?? '';
      final linkedDevice = await _repository.linkDevice(
        qrToken: qrToken,
        controllerUuid: activeController,
      );
      await fetchDevices();
      return linkedDevice;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateName(String deviceUuid, String newName) async {
    try {
      await _repository.updateDeviceName(deviceUuid, newName);
      if (mounted) {
        state.whenData((devices) {
          final updated = devices.map((d) {
            if (d.uuid == deviceUuid) {
              return d.copyWith(name: newName);
            }
            return d;
          }).toList();
          state = AsyncValue.data(updated);
        });
      }
      await fetchDevices();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkDevice(String deviceUuid) async {
    try {
      await _repository.unlinkDevice(deviceUuid);
      await fetchDevices();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setLocation(
    String deviceUuid,
    double latitude,
    double longitude,
  ) async {
    await _repository.updateDeviceLocation(deviceUuid, latitude, longitude);
    _patchDevice(
      deviceUuid,
      (d) => d.copyWith(latitude: latitude, longitude: longitude),
    );
  }

  Future<void> clearLocation(String deviceUuid) async {
    await _repository.clearDeviceLocation(deviceUuid);
    _patchDevice(deviceUuid, (d) => d.copyWith(clearLocation: true));
  }

  void _patchDevice(String deviceUuid, DeviceModel Function(DeviceModel) fn) {
    if (!mounted) return;
    state.whenData((devices) {
      state = AsyncValue.data([
        for (final d in devices) d.uuid == deviceUuid ? fn(d) : d,
      ]);
    });
  }
}
