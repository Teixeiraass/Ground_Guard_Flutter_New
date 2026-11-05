import '../../data/models/device_model.dart';

abstract class DevicesRepository {
  Future<List<DeviceModel>> getDevicesList({String? controllerUuid});
  Future<DeviceModel> linkDevice({
    required String qrToken,
    required String controllerUuid,
  });
  Future<void> updateDeviceName(String deviceUuid, String name);
  Future<void> unlinkDevice(String deviceUuid);
  Future<bool> hasDevices();
  Future<DeviceModel> updateDeviceLocation(
    String deviceUuid,
    double latitude,
    double longitude,
  );
  Future<DeviceModel> clearDeviceLocation(String deviceUuid);
}
