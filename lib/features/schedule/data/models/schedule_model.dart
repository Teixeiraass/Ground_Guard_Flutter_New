class ScheduleModel {
  final int? id;
  final String uuid;
  final String deviceUuid;
  final String? deviceId; // Caso a API retorne device_id em vez de device_uuid
  final String? name;
  final bool enabled;
  final String startTime; // Formato esperado da API: HH:mm
  final int durationSeconds;
  final List<int> daysOfWeek; // Ex: [1,3,5] para Seg, Qua, Sex
  final String irrigationMode; // 'DURATION' ou 'HUMIDITY'
  final int? moistureThreshold; // 1-100, obrigatório quando irrigationMode == 'HUMIDITY'

  ScheduleModel({
    this.id,
    required this.uuid,
    required this.deviceUuid,
    this.deviceId,
    this.name,
    this.enabled = true,
    required this.startTime,
    required this.durationSeconds,
    required this.daysOfWeek,
    this.irrigationMode = 'DURATION',
    this.moistureThreshold,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    List<int> days = [];
    if (json['days_of_week'] != null && json['days_of_week'] is String) {
      days = (json['days_of_week'] as String)
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => int.tryParse(s.trim()) ?? 0)
          .toList();
    } else if (json['days_of_week'] is List) {
      days = List<int>.from(json['days_of_week']);
    }

    String start = json['start_time'] ?? '00:00';
    if (start.length > 5) {
      // Se vier HH:mm:ss, cortamos para HH:mm para padronizar o frontend e backend.
      start = start.substring(0, 5);
    }

    return ScheduleModel(
      id: json['id'],
      uuid: json['uuid'] ?? '',
      deviceUuid: json['device_uuid'] ?? '',
      deviceId: json['device_id']?.toString(),
      name: json['name'],
      enabled: json['enabled'] ?? true,
      startTime: start,
      durationSeconds: json['duration_seconds'] ?? 0,
      daysOfWeek: days,
      irrigationMode: json['irrigation_mode'] ?? 'DURATION',
      moistureThreshold: json['moisture_threshold'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_uuid': deviceUuid,
      'name': name,
      'enabled': enabled,
      'start_time': startTime, // HH:mm
      'duration_seconds': durationSeconds,
      'days_of_week': daysOfWeek.join(','),
      'irrigation_mode': irrigationMode,
      'moisture_threshold': irrigationMode == 'HUMIDITY'
          ? moistureThreshold
          : null,
    };
  }

  ScheduleModel copyWith({
    int? id,
    String? uuid,
    String? deviceUuid,
    String? deviceId,
    String? name,
    bool? enabled,
    String? startTime,
    int? durationSeconds,
    List<int>? daysOfWeek,
    String? irrigationMode,
    int? moistureThreshold,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      deviceUuid: deviceUuid ?? this.deviceUuid,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      irrigationMode: irrigationMode ?? this.irrigationMode,
      moistureThreshold: moistureThreshold ?? this.moistureThreshold,
    );
  }
}
