import '../../data/models/device_group_detail_model.dart';
import '../../data/models/device_group_model.dart';
import '../../data/models/device_group_statistics_model.dart';

abstract class DeviceGroupsRepository {
  Future<List<DeviceGroupModel>> getGroups();
  Future<DeviceGroupDetailModel> getGroup(String uuid);
  Future<DeviceGroupModel> createGroup(String name);
  Future<DeviceGroupModel> renameGroup(String uuid, String name);
  Future<void> deleteGroup(String uuid);
  Future<List<Map<String, dynamic>>> triggerIrrigation(String uuid, String action);
  Future<int> createSchedule(String uuid, Map<String, dynamic> data);
  Future<void> assignDeviceToGroup(String deviceUuid, String? groupUuid);
  Future<DeviceGroupStatisticsModel> getStatistics(String uuid, {String? period});
}
