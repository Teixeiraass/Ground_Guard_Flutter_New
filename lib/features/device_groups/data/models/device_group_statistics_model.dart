import '../../../dashboard/data/models/statistics_model.dart';
import '../../../irrigation/data/models/irrigation_history_model.dart';

class DeviceGroupStatisticsModel {
  final String period;
  final int deviceCount;
  final int onlineCount;
  final int irrigatingCount;
  final double? avgSoilMoisture;
  final int? minSoilMoisture;
  final int? maxSoilMoisture;
  final WaterConsumption waterConsumption;
  final List<IrrigationHistoryModel> irrigationHistory;

  const DeviceGroupStatisticsModel({
    required this.period,
    required this.deviceCount,
    required this.onlineCount,
    required this.irrigatingCount,
    this.avgSoilMoisture,
    this.minSoilMoisture,
    this.maxSoilMoisture,
    required this.waterConsumption,
    required this.irrigationHistory,
  });

  factory DeviceGroupStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DeviceGroupStatisticsModel(
      period: json['period'] ?? 'week',
      deviceCount: json['device_count'] ?? 0,
      onlineCount: json['online_count'] ?? 0,
      irrigatingCount: json['irrigating_count'] ?? 0,
      avgSoilMoisture: json['avg_soil_moisture'] != null
          ? (json['avg_soil_moisture'] as num).toDouble()
          : null,
      minSoilMoisture: json['min_soil_moisture'],
      maxSoilMoisture: json['max_soil_moisture'],
      waterConsumption: WaterConsumption.fromJson(
        json['water_consumption'] ?? {},
      ),
      irrigationHistory: (json['irrigation_history'] as List? ?? [])
          .map((i) => IrrigationHistoryModel.fromJson(i))
          .toList(),
    );
  }
}
