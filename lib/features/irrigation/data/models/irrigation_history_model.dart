class IrrigationHistoryModel {
  final String? createdAt;
  final int durationSeconds;
  final String? errorMessage;
  final String? finishedAt;
  final String? startedAt;
  final String status;
  final String triggerType;
  final String uuid;
  final double waterVolumeMl;

  IrrigationHistoryModel({
    this.createdAt,
    required this.durationSeconds,
    this.errorMessage,
    this.finishedAt,
    this.startedAt,
    required this.status,
    required this.triggerType,
    required this.uuid,
    required this.waterVolumeMl,
  });

  factory IrrigationHistoryModel.fromJson(Map<String, dynamic> json) {
    return IrrigationHistoryModel(
      createdAt: json['created_at'],
      durationSeconds: json['duration_seconds'] ?? 0,
      errorMessage: json['error_message'],
      finishedAt: json['finished_at'],
      startedAt: json['started_at'],
      status: json['status'] ?? '',
      triggerType: json['trigger_type'] ?? '',
      uuid: json['uuid'] ?? '',
      waterVolumeMl: (json['water_volume_ml'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'duration_seconds': durationSeconds,
      'error_message': errorMessage,
      'finished_at': finishedAt,
      'started_at': startedAt,
      'status': status,
      'trigger_type': triggerType,
      'uuid': uuid,
      'water_volume_ml': waterVolumeMl,
    };
  }
}
