import 'package:dio/dio.dart';

abstract class WeatherRemoteDataSource {
  Future<Map<String, dynamic>> getWeatherData(String city);
  Future<Map<String, dynamic>> getForecastData(String city);
  Future<String> getCityByIp();
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio _dio;
  final String _apiKey = 'ff23529207a7923b8ea20b6aaa8ee091';

  WeatherRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getWeatherData(String city) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'pt_br',
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getForecastData(String city) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'pt_br',
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getCityByIp() async {
    try {
      // Usando uma instância limpa de Dio para evitar interceptores que adicionam Auth headers
      final cleanDio = Dio();
      final response = await cleanDio.get('https://ipapi.co/json/');
      if (response.statusCode == 200) {
        return response.data['city'] ?? 'São Paulo';
      }
      return 'São Paulo';
    } catch (e) {
      return 'São Paulo';
    }
  }
}
