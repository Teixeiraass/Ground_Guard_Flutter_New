import '../../data/models/statistics_model.dart';

abstract class StatisticsRepository {
  Future<StatisticsModel> getStatistics({
    String? date,
    String? period,
    String? deviceUuid,
  });
}
