import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/rain_forecast_model.dart';

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return WeatherRemoteDataSourceImpl(dio);
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final remoteDataSource = ref.watch(weatherRemoteDataSourceProvider);
  return WeatherRepositoryImpl(remoteDataSource);
});

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherModel>>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repository);
});

final rainForecastProvider = StateNotifierProvider<RainForecastNotifier, AsyncValue<RainForecastModel>>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return RainForecastNotifier(repository);
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherModel>> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchWeather(); // Tenta buscar a cidade automaticamente
  }

  Future<void> fetchWeather([String? city]) async {
    state = const AsyncValue.loading();
    try {
      final cityToFetch = city ?? await _repository.getLocalCity();
      final weather = await _repository.getWeather(cityToFetch);
      state = AsyncValue.data(weather);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class RainForecastNotifier extends StateNotifier<AsyncValue<RainForecastModel>> {
  final WeatherRepository _repository;

  RainForecastNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchRainForecast();
  }

  Future<void> fetchRainForecast([String? city]) async {
    state = const AsyncValue.loading();
    try {
      final cityToFetch = city ?? await _repository.getLocalCity();
      final forecastList = await _repository.getForecast(cityToFetch);
      
      double rainToday = 0;
      double rainTomorrow = 0;
      
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      for (final item in forecastList) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        
        // Verifica se há chuva no objeto 'rain'
        double rainVolume = 0.0;
        if (item['rain'] != null) {
          rainVolume = (item['rain']['3h'] as num).toDouble();
        }
        
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          rainToday += rainVolume;
        } else if (dt.day == tomorrow.day && dt.month == tomorrow.month && dt.year == tomorrow.year) {
          rainTomorrow += rainVolume;
        }
      }
      
      state = AsyncValue.data(RainForecastModel(
        rainToday: rainToday,
        rainTomorrow: rainTomorrow,
        cityName: cityToFetch,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
