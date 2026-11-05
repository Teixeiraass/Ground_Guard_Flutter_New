import 'package:dio/dio.dart';

abstract class DeviceGroupsRemoteDataSource {
  Future<List<dynamic>> getGroups();
  Future<Map<String, dynamic>> getGroup(String uuid);
  Future<Map<String, dynamic>> createGroup(String name);
  Future<Map<String, dynamic>> renameGroup(String uuid, String name);
  Future<void> deleteGroup(String uuid);
  Future<List<dynamic>> triggerIrrigation(String uuid, String action);
  Future<List<dynamic>> createSchedule(String uuid, Map<String, dynamic> data);
  Future<void> assignDeviceToGroup(String deviceUuid, String? groupUuid);
  Future<Map<String, dynamic>> getStatistics(String uuid, {String? period});
}

class DeviceGroupsRemoteDataSourceImpl implements DeviceGroupsRemoteDataSource {
  final Dio _dio;

  DeviceGroupsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getGroups() async {
    final response = await _dio.get('/device-groups');
    return response.data is List ? response.data as List<dynamic> : [];
  }

  @override
  Future<Map<String, dynamic>> getGroup(String uuid) async {
    final response = await _dio.get('/device-groups/$uuid');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createGroup(String name) async {
    final response = await _dio.post('/device-groups', data: {'name': name});
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> renameGroup(String uuid, String name) async {
    final response = await _dio.put('/device-groups/$uuid', data: {'name': name});
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteGroup(String uuid) async {
    await _dio.delete('/device-groups/$uuid');
  }

  @override
  Future<List<dynamic>> triggerIrrigation(String uuid, String action) async {
    final response = await _dio.post(
      '/device-groups/$uuid/irrigation-commands',
      data: {'action': action},
    );
    return response.data is List ? response.data as List<dynamic> : [];
  }

  @override
  Future<List<dynamic>> createSchedule(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post('/device-groups/$uuid/schedules', data: data);
    return response.data is List ? response.data as List<dynamic> : [];
  }

  @override
  Future<void> assignDeviceToGroup(String deviceUuid, String? groupUuid) async {
    await _dio.put(
      '/devices/$deviceUuid/group',
      data: {'group_uuid': groupUuid},
    );
  }

  @override
  Future<Map<String, dynamic>> getStatistics(String uuid, {String? period}) async {
    final response = await _dio.get(
      '/device-groups/$uuid/statistics',
      queryParameters: period != null ? {'period': period} : null,
    );
    return response.data as Map<String, dynamic>;
  }
}
