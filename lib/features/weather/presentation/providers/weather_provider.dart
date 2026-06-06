import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';

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

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherModel>> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchWeather('São Paulo'); // Cidade padrão inicial
  }

  Future<void> fetchWeather(String city) async {
    state = const AsyncValue.loading();
    try {
      final weather = await _repository.getWeather(city);
      state = AsyncValue.data(weather);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
