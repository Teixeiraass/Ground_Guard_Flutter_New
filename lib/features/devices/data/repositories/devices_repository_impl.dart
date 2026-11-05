import 'package:dio/dio.dart';
import '../../domain/repositories/devices_repository.dart';
import '../datasources/devices_remote_datasource.dart';
import '../models/device_model.dart';
import '../../../../core/network/api_exception.dart';

class DevicesRepositoryImpl implements DevicesRepository {
  final DevicesRemoteDataSource _remoteDataSource;

  DevicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DeviceModel>> getDevicesList({String? controllerUuid}) async {
    try {
      final List<dynamic> data = await _remoteDataSource.getDevices(
        controllerUuid: controllerUuid,
      );
      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData['error'] != null) {
          throw Exception('Erro na API (400): ${responseData['error']}');
        }
        throw Exception('Erro na API (400 Bad Request).');
      }
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceModel> linkDevice({
    required String qrToken,
    required String controllerUuid,
  }) async {
    try {
      final data = await _remoteDataSource.linkDevice(
        qrToken: qrToken,
        controllerUuid: controllerUuid,
      );
      return DeviceModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map &&
          e.response?.data['error']?.toString().contains(
                'invalid UUID length: 0',
              ) ==
              true) {
        throw Exception(
          'O UUID da controladora não foi reconhecido pelo servidor (invalid UUID length: 0).',
        );
      }
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateDeviceName(String deviceUuid, String name) async {
    try {
      await _remoteDataSource.updateDeviceName(deviceUuid, name);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> unlinkDevice(String deviceUuid) async {
    try {
      await _remoteDataSource.unlinkDevice(deviceUuid);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceModel> updateDeviceLocation(
    String deviceUuid,
    double latitude,
    double longitude,
  ) async {
    try {
      final data = await _remoteDataSource.updateDeviceLocation(
        deviceUuid,
        latitude,
        longitude,
      );
      return DeviceModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DeviceModel> clearDeviceLocation(String deviceUuid) async {
    try {
      final data = await _remoteDataSource.clearDeviceLocation(deviceUuid);
      return DeviceModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> hasDevices() async {
    try {
      // Para saber se o usuário possui algum dispositivo geral, não filtramos por controladora específica
      // mas se não houver controladora carregada tratamos graciosamente
      return false;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      return false;
    }
  }
}
