class IrrigationPreferenceModel {
  final String uuid;
  final int deviceId;
  final bool enabled;
  final String irrigationMode;
  final int moistureThreshold;
  final int dryTimeMinutes;
  final int irrigationDurationSeconds;
  final int maxIrrigationsPerDay;

  IrrigationPreferenceModel({
    required this.uuid,
    required this.deviceId,
    required this.enabled,
    required this.irrigationMode,
    required this.moistureThreshold,
    required this.dryTimeMinutes,
    required this.irrigationDurationSeconds,
    required this.maxIrrigationsPerDay,
  });

  factory IrrigationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return IrrigationPreferenceModel(
      uuid: json['uuid'] ?? '',
      deviceId: json['device_id'] ?? 0,
      enabled: json['enabled'] ?? false,
      irrigationMode: json['irrigation_mode'] ?? '',
      moistureThreshold: json['moisture_threshold'] ?? 0,
      dryTimeMinutes: json['dry_time_minutes'] ?? 0,
      irrigationDurationSeconds: json['irrigation_duration_seconds'] ?? 0,
      maxIrrigationsPerDay: json['max_irrigations_per_day'] ?? 0,
    );
  }

  factory IrrigationPreferenceModel.empty() {
    return IrrigationPreferenceModel(
      uuid: '',
      deviceId: 0,
      enabled: false,
      irrigationMode: 'INTELIGENTE',
      moistureThreshold: 0,
      dryTimeMinutes: 0,
      irrigationDurationSeconds: 0,
      maxIrrigationsPerDay: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'device_id': deviceId,
      'enabled': enabled,
      'irrigation_mode': irrigationMode,
      'moisture_threshold': moistureThreshold,
      'dry_time_minutes': dryTimeMinutes,
      'irrigation_duration_seconds': irrigationDurationSeconds,
      'max_irrigations_per_day': maxIrrigationsPerDay,
    };
  }
}
