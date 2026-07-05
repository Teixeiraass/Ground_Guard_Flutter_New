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

  @override
  Future<List<Map<String, dynamic>>> getForecast(String city) async {
    try {
      final data = await _remoteDataSource.getForecastData(city);
      return (data['list'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getLocalCity() async {
    return _remoteDataSource.getCityByIp();
  }
}
