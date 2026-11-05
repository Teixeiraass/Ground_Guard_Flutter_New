import 'package:dio/dio.dart';

abstract class IrrigationRemoteDataSource {
  Future<Map<String, dynamic>> getIrrigationPreference(String deviceUuid);
  Future<void> createIrrigationPreference(Map<String, dynamic> preferenceData);
  Future<void> updateIrrigationPreference(
    String uuid,
    Map<String, dynamic> preferenceData,
  );
  Future<Map<String, dynamic>> sendIrrigationCommand(
    String deviceUuid,
    String action,
  );
  Future<Map<String, dynamic>> getCommandStatus(String commandUuid);
  Future<List<dynamic>> getIrrigationHistory({
    String? date,
    String? deviceUuid,
    String? startDate,
    String? endDate,
  });
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  final Dio _dio;

  IrrigationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> getIrrigationHistory({
    String? date,
    String? deviceUuid,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (deviceUuid != null) queryParams['device_uuid'] = deviceUuid;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/irrigation/history',
        queryParameters: queryParams,
      );
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getIrrigationPreference(
    String deviceUuid,
  ) async {
    try {
      final response = await _dio.get(
        '/irrigation_preference/device/$deviceUuid',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createIrrigationPreference(
    Map<String, dynamic> preferenceData,
  ) async {
    try {
      await _dio.post('/irrigation_preference', data: preferenceData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateIrrigationPreference(
    String uuid,
    Map<String, dynamic> preferenceData,
  ) async {
    try {
      await _dio.put('/irrigation_preference/$uuid', data: preferenceData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> sendIrrigationCommand(
    String deviceUuid,
    String action,
  ) async {
    try {
      final response = await _dio.post(
        '/irrigation/commands',
        data: {'device_id': deviceUuid, 'action': action},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCommandStatus(String commandUuid) async {
    try {
      final response = await _dio.get('/irrigation/command/$commandUuid');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
