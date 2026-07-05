import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/weather/data/models/rain_forecast_model.dart';

void main() {
  group('RainForecastModel', () {
    test('willRain should return true when rainToday > 2.0', () {
      final model = RainForecastModel(rainToday: 2.1, rainTomorrow: 0.0);
      expect(model.willRain, isTrue);
    });

    test('willRain should return true when rainTomorrow > 2.0', () {
      final model = RainForecastModel(rainToday: 0.0, rainTomorrow: 2.5);
      expect(model.willRain, isTrue);
    });

    test('willRain should return false when both are <= 2.0', () {
      final model = RainForecastModel(rainToday: 1.9, rainTomorrow: 2.0);
      expect(model.willRain, isFalse);
    });

    test('totalRain should return the sum of rainToday and rainTomorrow', () {
      final model = RainForecastModel(rainToday: 1.5, rainTomorrow: 2.5);
      expect(model.totalRain, 4.0);
    });
  });
}
