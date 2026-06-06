import 'package:dio/dio.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/weather_model.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;

  WeatherRepositoryImpl(this._remoteDataSource);

  @override
  Future<WeatherModel> getWeather(String city) async {
    try {
      final data = await _remoteDataSource.getWeatherData(city);
      return WeatherModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
