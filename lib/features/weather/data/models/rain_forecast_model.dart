class RainForecastModel {
  final double rainToday;
  final double rainTomorrow;
  final String? cityName;
  final double rainProbabilityToday;
  final double rainProbabilityTomorrow;
  final String? nextRainDay;
  final double? nextRainProbability;

  RainForecastModel({
    required this.rainToday,
    required this.rainTomorrow,
    this.cityName,
    this.rainProbabilityToday = 0.0,
    this.rainProbabilityTomorrow = 0.0,
    this.nextRainDay,
    this.nextRainProbability,
  });

  bool get willRain => rainToday > 2.0 || rainTomorrow > 2.0;
  double get totalRain => rainToday + rainTomorrow;
}
