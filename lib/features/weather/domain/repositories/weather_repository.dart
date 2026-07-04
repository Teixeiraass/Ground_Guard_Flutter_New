import '../../data/models/weather_model.dart';

abstract class WeatherRepository {
  Future<WeatherModel> getWeather(String city);
  Future<List<Map<String, dynamic>>> getForecast(String city);
  Future<String> getLocalCity();
}
