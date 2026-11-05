import 'package:dio/dio.dart';

abstract class ControllersRemoteDataSource {
  Future<List<dynamic>> getControllers();
  Future<Map<String, dynamic>> registerController({
    required String name,
    required String bluetoothMacAddress,
  });
  Future<Map<String, dynamic>> registerBleController({
    required String deviceUid,
    required String name,
    required String firmwareVersion,
    required String firmwareBuild,
  });
  Future<Map<String, dynamic>> claimController(String deviceUid);
  Future<Map<String, dynamic>> triggerPairing(String deviceUid);
  Future<void> updateControllerName(String uuid, String name);
  Future<void> deleteController(String uuid);
  Future<Map<String, dynamic>> sendControllerCommand(
    String uuid,
    String action,
  );
}

class ControllersRemoteDataSourceImpl implements ControllersRemoteDataSource {
  final Dio _dio;

  ControllersRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getControllers() async {
    final response = await _dio.get(
      '/controller-devices',
      queryParameters: {'page_id': 1, 'page_size': 10},
    );

    if (response.data is List) {
      return response.data as List<dynamic>;
    } else if (response.data is Map) {
      final map = response.data as Map<String, dynamic>;
      if (map['data'] is List) return map['data'] as List<dynamic>;
      if (map['items'] is List) return map['items'] as List<dynamic>;
      if (map['controller_devices'] is List)
        return map['controller_devices'] as List<dynamic>;
      if (map['controllerDevices'] is List)
        return map['controllerDevices'] as List<dynamic>;
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>> registerController({
    required String name,
    required String bluetoothMacAddress,
  }) async {
    final response = await _dio.post(
      '/controller-devices',
      data: {'name': name, 'bluetoothMacAddress': bluetoothMacAddress},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> registerBleController({
    required String deviceUid,
    required String name,
    required String firmwareVersion,
    required String firmwareBuild,
  }) async {
    final response = await _dio.post(
      '/controller-devices/register',
      data: {
        'device_uid': deviceUid,
        'name': name,
        'firmware_version': firmwareVersion,
        'firmware_build': firmwareBuild,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> claimController(String deviceUid) async {
    final response = await _dio.put('/controller-devices/claim/$deviceUid');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> triggerPairing(String deviceUid) async {
    final response = await _dio.put('/controller-devices/pairing/$deviceUid');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> updateControllerName(String uuid, String name) async {
    await _dio.put('/controller-devices/$uuid', data: {'name': name});
  }

  @override
  Future<void> deleteController(String uuid) async {
    await _dio.delete('/controller-devices/$uuid');
  }

  @override
  Future<Map<String, dynamic>> sendControllerCommand(
    String uuid,
    String action,
  ) async {
    final response = await _dio.post(
      '/controller-devices/$uuid/command',
      data: {'action': action},
    );
    return response.data as Map<String, dynamic>;
  }
}
