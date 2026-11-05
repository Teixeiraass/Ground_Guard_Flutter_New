import '../../../devices/data/models/device_model.dart';
import 'device_group_model.dart';

class DeviceGroupDetailModel {
  final DeviceGroupModel group;
  final List<DeviceModel> devices;

  const DeviceGroupDetailModel({required this.group, required this.devices});

  factory DeviceGroupDetailModel.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as List<dynamic>? ?? [];
    return DeviceGroupDetailModel(
      group: DeviceGroupModel.fromJson(json),
      devices: devicesJson
          .map((d) => DeviceModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
