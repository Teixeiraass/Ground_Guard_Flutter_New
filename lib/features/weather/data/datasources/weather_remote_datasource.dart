import 'package:dio/dio.dart';

abstract class WeatherRemoteDataSource {
  Future<Map<String, dynamic>> getWeatherData(String city);
  Future<Map<String, dynamic>> getForecastData(String city);
  Future<String> getCityByIp();
}

/// Weather goes through the Ground Guard API, which keeps the OpenWeather
/// key server-side; the response bodies are OpenWeather's, passed through.
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio _dio;

  WeatherRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getWeatherData(String city) async {
    final response = await _dio.get(
      '/weather/current',
      queryParameters: {'city': city},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<Map<String, dynamic>> getForecastData(String city) async {
    final response = await _dio.get(
      '/weather/forecast',
      queryParameters: {'city': city},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<String> getCityByIp() async {
    // Usando uma instância limpa de Dio para evitar interceptores que adicionam Auth headers
    final cleanDio = Dio();

    // ipapi.co às vezes falha (DNS/rate-limit) sem relação com o device do
    // usuário. Em vez de depender de um único provedor — o que faz essa
    // feature inteira cair por culpa de UM serviço externo — tenta um
    // segundo provedor HTTPS antes de desistir de verdade.
    final city = await _tryGetCity(
          cleanDio,
          'https://ipapi.co/json/',
          (data) => data['city'],
        ) ??
        await _tryGetCity(
          cleanDio,
          'https://ipwho.is/',
          (data) => data['success'] == true ? data['city'] : null,
        );

    if (city == null || city.isEmpty) {
      throw Exception('Não foi possível identificar sua localização.');
    }
    return city;
  }

  Future<String?> _tryGetCity(
    Dio dio,
    String url,
    Object? Function(Map<String, dynamic>) extractCity,
  ) async {
    try {
      final response = await dio.get(url);
      if (response.statusCode != 200) return null;
      final city = extractCity(response.data as Map<String, dynamic>);
      if (city is String && city.isNotEmpty) return city;
      return null;
    } catch (_) {
      return null;
    }
  }
}
