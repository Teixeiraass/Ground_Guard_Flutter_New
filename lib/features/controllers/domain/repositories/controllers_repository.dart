import '../../data/models/controller_device_model.dart';

abstract class ControllersRepository {
  Future<List<ControllerDeviceModel>> getControllers();
  Future<ControllerDeviceModel> registerController({
    required String name,
    required String bluetoothMacAddress,
  });
  Future<ControllerDeviceModel> registerBleController({
    required String deviceUid,
    required String name,
    required String firmwareVersion,
    required String firmwareBuild,
  });
  Future<ControllerDeviceModel> claimController(String deviceUid);
  Future<ControllerDeviceModel> triggerPairing(String deviceUid);
  Future<void> updateControllerName(String uuid, String name);
  Future<void> deleteController(String uuid);
  Future<void> sendControllerCommand(String uuid, String action);
}
