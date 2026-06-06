import 'package:dio/dio.dart';
import '../../domain/repositories/devices_repository.dart';
import '../datasources/devices_remote_datasource.dart';
import '../models/device_model.dart';
import '../../../../core/network/api_exception.dart';

class DevicesRepositoryImpl implements DevicesRepository {
  final DevicesRemoteDataSource _remoteDataSource;

  DevicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DeviceModel>> getDevicesList() async {
    try {
      final List<dynamic> data = await _remoteDataSource.getDevices();
      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> linkDevice(String deviceId) async {
    try {
      await _remoteDataSource.linkDevice(deviceId);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateDeviceName(String deviceId, String name) async {
    try {
      await _remoteDataSource.updateDeviceName(deviceId, name);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> unlinkDevice(String deviceId) async {
    try {
      await _remoteDataSource.unlinkDevice(deviceId);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> hasDevices() async {
    try {
      final devices = await _remoteDataSource.getDevices();
      return devices.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
