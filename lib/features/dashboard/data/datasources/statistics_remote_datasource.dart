import 'package:dio/dio.dart';

abstract class StatisticsRemoteDataSource {
  Future<Map<String, dynamic>> getStatistics({
    String? date,
    String? period,
    String? deviceUuid,
  });
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final Dio _dio;

  StatisticsRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getStatistics({
    String? date,
    String? period,
    String? deviceUuid,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (date != null) queryParams['date'] = date;
    if (period != null) queryParams['period'] = period;
    if (deviceUuid != null) queryParams['device_uuid'] = deviceUuid;

    final response = await _dio.get(
      '/statistics',
      queryParameters: queryParams,
    );
    return response.data;
  }
}
