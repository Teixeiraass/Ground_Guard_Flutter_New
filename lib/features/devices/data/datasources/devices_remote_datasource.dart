import 'package:dio/dio.dart';

abstract class DevicesRemoteDataSource {
  Future<List<dynamic>> getDevices();
  Future<void> linkDevice(String deviceId);
  Future<void> updateDeviceName(String deviceId, String name);
  Future<void> unlinkDevice(String deviceId);
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  final Dio _dio;

  DevicesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getDevices() async {
    try {
      final response = await _dio.get(
        '/devices',
        queryParameters: {
          'page_id': 1,
          'page_size': 10,
        },
      );
      
      // Suporte para retorno direto ou dentro de um objeto 'items'/'data'
      if (response.data is List) {
        return response.data as List<dynamic>;
      } else if (response.data is Map && response.data['items'] != null) {
        return response.data['items'] as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> linkDevice(String deviceId) async {
    try {
      await _dio.put('/devices/link/$deviceId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDeviceName(String deviceId, String name) async {
    try {
      await _dio.put('/devices/name/$deviceId', data: {'name': name});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlinkDevice(String deviceId) async {
    try {
      await _dio.put('/devices/unlink/$deviceId');
    } catch (e) {
      rethrow;
    }
  }
}
