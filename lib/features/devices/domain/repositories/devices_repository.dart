import '../../data/models/device_model.dart';

abstract class DevicesRepository {
  Future<List<DeviceModel>> getDevicesList();
  Future<void> linkDevice(String deviceId);
  Future<void> updateDeviceName(String deviceId, String name);
  Future<void> unlinkDevice(String deviceId);
  Future<bool> hasDevices();
}
