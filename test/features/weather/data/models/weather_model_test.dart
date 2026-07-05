import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/weather/data/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    final tWeatherJson = {
      'main': {'temp': 25.5},
      'weather': [
        {
          'description': 'céu limpo',
          'main': 'Clear',
          'icon': '01d',
        }
      ],
      'name': 'São Paulo',
    };

    test('should return a valid model from JSON', () {
      // Act
      final result = WeatherModel.fromJson(tWeatherJson);

      // Assert
      expect(result.temperature, 25.5);
      expect(result.description, 'céu limpo');
      expect(result.condition, 'Clear');
      expect(result.iconCode, '01d');
      expect(result.cityName, 'São Paulo');
    });

    test('should return default cityName when name is missing in JSON', () {
      // Arrange
      final jsonWithoutName = Map<String, dynamic>.from(tWeatherJson)..remove('name');

      // Act
      final result = WeatherModel.fromJson(jsonWithoutName);

      // Assert
      expect(result.cityName, 'Localização desconhecida');
    });
  });
}
