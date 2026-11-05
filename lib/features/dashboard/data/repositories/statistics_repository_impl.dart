import 'package:dio/dio.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';
import '../models/statistics_model.dart';
import '../../../../core/network/api_exception.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource _remoteDataSource;

  StatisticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<StatisticsModel> getStatistics({
    String? date,
    String? period,
    String? deviceUuid,
  }) async {
    try {
      final data = await _remoteDataSource.getStatistics(
        date: date,
        period: period,
        deviceUuid: deviceUuid,
      );
      return StatisticsModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
