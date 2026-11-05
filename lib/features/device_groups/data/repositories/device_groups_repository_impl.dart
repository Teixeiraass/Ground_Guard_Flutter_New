import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/device_groups_repository.dart';
import '../datasources/device_groups_remote_datasource.dart';
import '../models/device_group_detail_model.dart';
import '../models/device_group_model.dart';
import '../models/device_group_statistics_model.dart';

class DeviceGroupsRepositoryImpl implements DeviceGroupsRepository {
  final DeviceGroupsRemoteDataSource _remoteDataSource;

  DeviceGroupsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DeviceGroupModel>> getGroups() async {
    try {
      final data = await _remoteDataSource.getGroups();
      return data.map((json) => DeviceGroupModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceGroupDetailModel> getGroup(String uuid) async {
    try {
      final data = await _remoteDataSource.getGroup(uuid);
      return DeviceGroupDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceGroupModel> createGroup(String name) async {
    try {
      final data = await _remoteDataSource.createGroup(name);
      return DeviceGroupModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceGroupModel> renameGroup(String uuid, String name) async {
    try {
      final data = await _remoteDataSource.renameGroup(uuid, name);
      return DeviceGroupModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteGroup(String uuid) async {
    try {
      await _remoteDataSource.deleteGroup(uuid);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> triggerIrrigation(
    String uuid,
    String action,
  ) async {
    try {
      final data = await _remoteDataSource.triggerIrrigation(uuid, action);
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<int> createSchedule(String uuid, Map<String, dynamic> data) async {
    try {
      final result = await _remoteDataSource.createSchedule(uuid, data);
      return result.length;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> assignDeviceToGroup(String deviceUuid, String? groupUuid) async {
    try {
      await _remoteDataSource.assignDeviceToGroup(deviceUuid, groupUuid);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceGroupStatisticsModel> getStatistics(
    String uuid, {
    String? period,
  }) async {
    try {
      final data = await _remoteDataSource.getStatistics(uuid, period: period);
      return DeviceGroupStatisticsModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
