import '../../../irrigation/data/models/irrigation_history_model.dart';

class StatisticsModel {
  final String? date;
  final DeviceStatistics deviceStatistics;
  final String? deviceUuid;
  final String? generatedAt;
  final List<IrrigationHistoryModel> irrigationHistory;
  final String period;
  final WaterConsumption waterConsumption;

  StatisticsModel({
    this.date,
    required this.deviceStatistics,
    this.deviceUuid,
    this.generatedAt,
    required this.irrigationHistory,
    required this.period,
    required this.waterConsumption,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      date: json['date'],
      deviceStatistics: DeviceStatistics.fromJson(
        json['device_statistics'] ?? {},
      ),
      deviceUuid: json['device_uuid'],
      generatedAt: json['generated_at'],
      irrigationHistory: (json['irrigation_history'] as List? ?? [])
          .map((i) => IrrigationHistoryModel.fromJson(i))
          .toList(),
      period: json['period'] ?? 'day',
      waterConsumption: WaterConsumption.fromJson(
        json['water_consumption'] ?? {},
      ),
    );
  }
}

class DeviceStatistics {
  final int online;
  final int total;

  DeviceStatistics({required this.online, required this.total});

  factory DeviceStatistics.fromJson(Map<String, dynamic> json) {
    return DeviceStatistics(
      online: json['online'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class WaterConsumption {
  final double changePercent;
  final String? currentPeriodEnd;
  final String? currentPeriodStart;
  final double currentTotalMl;
  final double differenceMl;
  final String period;
  final List<ConsumptionPoint> points;
  final double previousTotalMl;

  WaterConsumption({
    required this.changePercent,
    this.currentPeriodEnd,
    this.currentPeriodStart,
    required this.currentTotalMl,
    required this.differenceMl,
    required this.period,
    required this.points,
    required this.previousTotalMl,
  });

  factory WaterConsumption.fromJson(Map<String, dynamic> json) {
    return WaterConsumption(
      changePercent: (json['change_percent'] as num? ?? 0).toDouble(),
      currentPeriodEnd: json['current_period_end'],
      currentPeriodStart: json['current_period_start'],
      currentTotalMl: (json['current_total_ml'] as num? ?? 0).toDouble(),
      differenceMl: (json['difference_ml'] as num? ?? 0).toDouble(),
      period: json['period'] ?? 'day',
      points: (json['points'] as List? ?? [])
          .map((p) => ConsumptionPoint.fromJson(p))
          .toList(),
      previousTotalMl: (json['previous_total_ml'] as num? ?? 0).toDouble(),
    );
  }
}

class ConsumptionPoint {
  final String label;
  final double waterVolumeMl;

  ConsumptionPoint({required this.label, required this.waterVolumeMl});

  factory ConsumptionPoint.fromJson(Map<String, dynamic> json) {
    return ConsumptionPoint(
      label: json['label'] ?? '',
      waterVolumeMl: (json['water_volume_ml'] as num? ?? 0).toDouble(),
    );
  }
}
