import 'package:dio/dio.dart';

abstract class IrrigationRemoteDataSource {
  Future<Map<String, dynamic>> getIrrigationPreference(String deviceUuid);
  Future<void> createIrrigationPreference(Map<String, dynamic> preferenceData);
  Future<void> updateIrrigationPreference(String uuid, Map<String, dynamic> preferenceData);
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  final Dio _dio;

  IrrigationRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getIrrigationPreference(String deviceUuid) async {
    try {
      final response = await _dio.get('/irrigation_preference/device/$deviceUuid');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createIrrigationPreference(Map<String, dynamic> preferenceData) async {
    try {
      await _dio.post('/irrigation_preference', data: preferenceData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateIrrigationPreference(String uuid, Map<String, dynamic> preferenceData) async {
    try {
      await _dio.put('/irrigation_preference/$uuid', data: preferenceData);
    } catch (e) {
      rethrow;
    }
  }
}
