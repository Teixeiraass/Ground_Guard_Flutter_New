import 'package:dio/dio.dart';
import '../datasources/irrigation_remote_datasource.dart';
import '../models/irrigation_preference_model.dart';
import '../../domain/repositories/irrigation_repository.dart';
import '../../../../core/network/api_exception.dart';

class IrrigationRepositoryImpl implements IrrigationRepository {
  final IrrigationRemoteDataSource _remoteDataSource;

  IrrigationRepositoryImpl(this._remoteDataSource);

  @override
  Future<IrrigationPreferenceModel> getIrrigationPreference(String deviceUuid) async {
    try {
      final data = await _remoteDataSource.getIrrigationPreference(deviceUuid);
      return IrrigationPreferenceModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return IrrigationPreferenceModel.empty();
      }
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> createIrrigationPreference(Map<String, dynamic> preferenceData) async {
    try {
      await _remoteDataSource.createIrrigationPreference(preferenceData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateIrrigationPreference(String uuid, Map<String, dynamic> preferenceData) async {
    try {
      await _remoteDataSource.updateIrrigationPreference(uuid, preferenceData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
