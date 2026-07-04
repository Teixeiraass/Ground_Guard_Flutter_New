class WeatherModel {
  final double temperature;
  final String description;
  final String condition; // e.g., "Clear", "Clouds", "Rain"
  final String iconCode;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.condition,
    required this.iconCode,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      cityName: json['name'] ?? 'Localização desconhecida',
    );
  }
}
