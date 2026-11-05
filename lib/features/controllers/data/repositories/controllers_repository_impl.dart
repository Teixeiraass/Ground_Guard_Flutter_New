import 'package:dio/dio.dart';
import '../../domain/repositories/controllers_repository.dart';
import '../datasources/controllers_remote_datasource.dart';
import '../models/controller_device_model.dart';
import '../../../../core/network/api_exception.dart';

class ControllersRepositoryImpl implements ControllersRepository {
  final ControllersRemoteDataSource _remoteDataSource;

  ControllersRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ControllerDeviceModel>> getControllers() async {
    try {
      final List<dynamic> data = await _remoteDataSource.getControllers();
      return data.map((json) => ControllerDeviceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ControllerDeviceModel> registerController({
    required String name,
    required String bluetoothMacAddress,
  }) async {
    try {
      final data = await _remoteDataSource.registerController(
        name: name,
        bluetoothMacAddress: bluetoothMacAddress,
      );
      return ControllerDeviceModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ControllerDeviceModel> registerBleController({
    required String deviceUid,
    required String name,
    required String firmwareVersion,
    required String firmwareBuild,
  }) async {
    try {
      final data = await _remoteDataSource.registerBleController(
        deviceUid: deviceUid,
        name: name,
        firmwareVersion: firmwareVersion,
        firmwareBuild: firmwareBuild,
      );
      return ControllerDeviceModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ControllerDeviceModel> claimController(String deviceUid) async {
    try {
      final data = await _remoteDataSource.claimController(deviceUid);
      return ControllerDeviceModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Controladora já vinculada a outro usuário.');
      }
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ControllerDeviceModel> triggerPairing(String deviceUid) async {
    try {
      final data = await _remoteDataSource.triggerPairing(deviceUid);
      return ControllerDeviceModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Controladora já vinculada a outro usuário.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Controladora não encontrada. Ela já conectou ao Wi-Fi?');
      }
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateControllerName(String uuid, String name) async {
    try {
      await _remoteDataSource.updateControllerName(uuid, name);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteController(String uuid) async {
    try {
      await _remoteDataSource.deleteController(uuid);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> sendControllerCommand(String uuid, String action) async {
    try {
      await _remoteDataSource.sendControllerCommand(uuid, action);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
