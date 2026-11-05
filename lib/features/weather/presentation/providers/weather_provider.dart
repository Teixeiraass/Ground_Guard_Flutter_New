import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/rain_forecast_model.dart';

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return WeatherRemoteDataSourceImpl(dio);
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final remoteDataSource = ref.watch(weatherRemoteDataSourceProvider);
  return WeatherRepositoryImpl(remoteDataSource);
});

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherModel>>((ref) {
      final repository = ref.watch(weatherRepositoryProvider);
      return WeatherNotifier(repository);
    });

final rainForecastProvider =
    StateNotifierProvider<RainForecastNotifier, AsyncValue<RainForecastModel>>((
      ref,
    ) {
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

class RainForecastNotifier
    extends StateNotifier<AsyncValue<RainForecastModel>> {
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
      double probToday = 0;
      double probTomorrow = 0;
      String? nextRainDay;
      double nextRainProb = 0;

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      for (final item in forecastList) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

        // Verifica se há chuva no objeto 'rain'
        double rainVolume = 0.0;
        if (item['rain'] != null) {
          rainVolume = (item['rain']['3h'] as num?)?.toDouble() ?? 0.0;
        }

        // Probabilidade de chuva (pop - probability of precipitation)
        double pop = (item['pop'] as num?)?.toDouble() ?? 0.0;

        // Se houver qualquer volume de chuva, consideramos o dia
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          rainToday += rainVolume;
          if (pop > probToday) probToday = pop;
        } else if (dt.day == tomorrow.day &&
            dt.month == tomorrow.month &&
            dt.year == tomorrow.year) {
          rainTomorrow += rainVolume;
          if (pop > probTomorrow) probTomorrow = pop;
        }

        // Busca a primeira chuva futura nos próximos 5 dias para o card do Dashboard
        if (nextRainDay == null && rainVolume > 0 && dt.isAfter(now)) {
          nextRainDay = _getWeekdayName(dt.weekday);
          nextRainProb = pop * 100;
        }
      }

      // Se não encontrou chuva nos próximos 5 dias nos dados do OpenWeather
      if (nextRainDay == null) {
        nextRainDay = "Sem chuva prevista";
        nextRainProb = 0;
      }

      state = AsyncValue.data(
        RainForecastModel(
          rainToday: rainToday,
          rainTomorrow: rainTomorrow,
          cityName: cityToFetch,
          rainProbabilityToday: probToday * 100,
          rainProbabilityTomorrow: probTomorrow * 100,
          nextRainDay: nextRainDay,
          nextRainProbability: nextRainProb,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Segunda';
      case 2:
        return 'Terça';
      case 3:
        return 'Quarta';
      case 4:
        return 'Quinta';
      case 5:
        return 'Sexta';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }
}
