import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ground_guard_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:ground_guard_app/features/weather/presentation/providers/weather_provider.dart';
import 'package:ground_guard_app/features/weather/data/models/rain_forecast_model.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
  });

  final now = DateTime.now();
  final tForecastList = [
    {
      'dt': now.millisecondsSinceEpoch ~/ 1000,
      'rain': {'3h': 1.0}
    },
    {
      'dt': now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
      'rain': {'3h': 3.0}
    }
  ];

  test('should calculate rain correctly for today and tomorrow', () async {
    when(() => mockRepository.getLocalCity()).thenAnswer((_) async => 'Varginha');
    when(() => mockRepository.getForecast(any())).thenAnswer((_) async => tForecastList);

    final container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    // Trigger fetch
    await container.read(rainForecastProvider.notifier).fetchRainForecast('Varginha');

    final state = container.read(rainForecastProvider);
    expect(state.value?.rainToday, 1.0);
    expect(state.value?.rainTomorrow, 3.0);
    expect(state.value?.willRain, isTrue); // because tomorrow > 2.0
  });

  test('willRain should be false if both are <= 2.0', () async {
    final tLightForecastList = [
      {
        'dt': now.millisecondsSinceEpoch ~/ 1000,
        'rain': {'3h': 0.5}
      },
      {
        'dt': now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
        'rain': {'3h': 1.5}
      }
    ];

    when(() => mockRepository.getLocalCity()).thenAnswer((_) async => 'Varginha');
    when(() => mockRepository.getForecast(any())).thenAnswer((_) async => tLightForecastList);

    final container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(rainForecastProvider.notifier).fetchRainForecast('Varginha');

    final state = container.read(rainForecastProvider);
    expect(state.value?.willRain, isFalse);
  });
}
