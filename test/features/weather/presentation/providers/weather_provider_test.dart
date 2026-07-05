import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ground_guard_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:ground_guard_app/features/weather/presentation/providers/weather_provider.dart';
import 'package:ground_guard_app/features/weather/data/models/weather_model.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;
  late WeatherNotifier weatherNotifier;

  final tWeather = WeatherModel(
    temperature: 20.0,
    description: 'Cloudy',
    condition: 'Clouds',
    iconCode: '03d',
    cityName: 'London',
  );

  setUp(() {
    mockRepository = MockWeatherRepository();
    // Pre-setting the responses as WeatherNotifier calls fetchWeather in constructor
    when(() => mockRepository.getLocalCity()).thenAnswer((_) async => 'London');
    when(() => mockRepository.getWeather(any())).thenAnswer((_) async => tWeather);
  });

  test('initial state should be loading and then data on success', () async {
    final container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    // The notifier calls fetchWeather in constructor
    // Initially it might be loading
    expect(container.read(weatherProvider), const AsyncValue<WeatherModel>.loading());

    // Wait for the constructor's fetchWeather to complete
    await container.read(weatherProvider.notifier).fetchWeather('London');

    expect(container.read(weatherProvider).value, tWeather);
    // Verify that it was called twice: once in constructor (with London from getLocalCity) 
    // and once manually (with London)
    verify(() => mockRepository.getWeather('London')).called(2);
  });

  test('should set state to error when fetch fails', () async {
    when(() => mockRepository.getWeather(any())).thenThrow(Exception('Failed to fetch'));

    final container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(weatherProvider.notifier).fetchWeather('London');

    expect(container.read(weatherProvider), isA<AsyncError>());
  });
}
