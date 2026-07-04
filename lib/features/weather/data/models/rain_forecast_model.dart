class RainForecastModel {
  final double rainToday;
  final double rainTomorrow;
  final String? cityName;

  RainForecastModel({
    required this.rainToday,
    required this.rainTomorrow,
    this.cityName,
  });

  bool get willRain => rainToday > 2.0 || rainTomorrow > 2.0;
  double get totalRain => rainToday + rainTomorrow;
}
