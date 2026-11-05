import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

abstract class DevicesRemoteDataSource {
  Future<List<dynamic>> getDevices({String? controllerUuid});
  Future<Map<String, dynamic>> linkDevice({
    required String qrToken,
    required String controllerUuid,
  });
  Future<void> updateDeviceName(String deviceUuid, String name);
  Future<void> unlinkDevice(String deviceUuid);
  Future<Map<String, dynamic>> updateDeviceLocation(
    String deviceUuid,
    double latitude,
    double longitude,
  );
  Future<Map<String, dynamic>> clearDeviceLocation(String deviceUuid);
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  final Dio _dio;

  DevicesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getDevices({String? controllerUuid}) async {
    final cleanControllerUuid = controllerUuid?.trim() ?? '';

    final queryParams = <String, dynamic>{'page_id': 1, 'page_size': 10};

    if (cleanControllerUuid.isEmpty) {
      // Quando for nulo ou vazio, deixamos de enviar controller_uuid
      // mas não disparamos exceção aqui para permitir a busca de todos os devices
      // (ex: na tela de perfil que chama com nulo).
    } else {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );
      if (!uuidRegex.hasMatch(cleanControllerUuid)) {
        throw Exception('A controladora possui um UUID com formato inválido.');
      }
      queryParams['controller_uuid'] = cleanControllerUuid;
    }

    debugPrint('GET /api/v1/devices');
    debugPrint('queryParameters: $queryParams');

    try {
      final response = await _dio.get('/devices', queryParameters: queryParams);

      if (response.data is List) {
        return response.data as List<dynamic>;
      } else if (response.data is Map && response.data['items'] != null) {
        return response.data['items'] as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData['error'] != null) {
          throw Exception('Erro na API (400): ${responseData['error']}');
        }
        throw Exception('Erro na API (400 Bad Request).');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> linkDevice({
    required String qrToken,
    required String controllerUuid,
  }) async {
    final cleanQrToken = qrToken.trim();
    final cleanControllerUuid = controllerUuid.trim();

    if (cleanQrToken.isEmpty) {
      throw Exception('O token QR do sensor não pode ser vazio.');
    }
    if (cleanControllerUuid.isEmpty) {
      throw Exception('O UUID da controladora não pode ser vazio.');
    }

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!uuidRegex.hasMatch(cleanControllerUuid)) {
      throw Exception('O UUID da controladora possui um formato inválido.');
    }

    try {
      final response = await _dio.put(
        '/devices/link/$cleanQrToken',
        queryParameters: {'controller_uuid': cleanControllerUuid},
        data: {},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData['error'] != null) {
        final errorMsg = responseData['error'].toString();
        if (errorMsg.contains('invalid UUID length: 0')) {
          throw Exception(
            'O UUID da controladora não foi reconhecido pelo servidor (invalid UUID length: 0).',
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> updateDeviceName(String deviceUuid, String name) async {
    final cleanUuid = deviceUuid.trim();
    final cleanName = name.trim();

    if (cleanUuid.isEmpty) {
      throw Exception('UUID do device não informado');
    }

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!uuidRegex.hasMatch(cleanUuid)) {
      throw Exception('UUID do device possui formato inválido');
    }

    if (cleanName.isEmpty) {
      throw Exception('Nome do device não pode ser vazio');
    }

    try {
      await _dio.put('/devices/name/$cleanUuid', data: {'name': cleanName});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlinkDevice(String deviceUuid) async {
    final cleanUuid = deviceUuid.trim();

    if (cleanUuid.isEmpty) {
      throw Exception('UUID do device não informado');
    }

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!uuidRegex.hasMatch(cleanUuid)) {
      throw Exception('UUID do device possui formato inválido');
    }

    try {
      await _dio.put('/devices/unlink/$cleanUuid');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateDeviceLocation(
    String deviceUuid,
    double latitude,
    double longitude,
  ) async {
    final response = await _dio.put(
      '/devices/${deviceUuid.trim()}/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> clearDeviceLocation(String deviceUuid) async {
    final response = await _dio.delete(
      '/devices/${deviceUuid.trim()}/location',
    );
    return Map<String, dynamic>.from(response.data);
  }
}
