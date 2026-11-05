class SoilHealthSummary {
  final int total;
  final int ok;
  final int dry;
  final int wet;
  final int offline;
  final int fault;
  final int noData;

  const SoilHealthSummary({
    this.total = 0,
    this.ok = 0,
    this.dry = 0,
    this.wet = 0,
    this.offline = 0,
    this.fault = 0,
    this.noData = 0,
  });

  factory SoilHealthSummary.fromJson(Map<String, dynamic> json) {
    int read(String key) => (json[key] as num?)?.toInt() ?? 0;
    return SoilHealthSummary(
      total: read('total'),
      ok: read('ok'),
      dry: read('dry'),
      wet: read('wet'),
      offline: read('offline'),
      fault: read('fault'),
      noData: read('no_data'),
    );
  }
}

class SensorHealthModel {
  final String uuid;
  final String name;
  final String state;
  final int? soilMoisture;
  final int idealMin;
  final int idealMax;
  final int? timeInRange24h;
  final int readings24h;
  final int? score;
  final DateTime? lastSeen;

  const SensorHealthModel({
    required this.uuid,
    required this.name,
    required this.state,
    required this.idealMin,
    required this.idealMax,
    this.soilMoisture,
    this.timeInRange24h,
    this.readings24h = 0,
    this.score,
    this.lastSeen,
  });

  factory SensorHealthModel.fromJson(Map<String, dynamic> json) {
    return SensorHealthModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sensor',
      state: json['state']?.toString() ?? 'NO_DATA',
      soilMoisture: (json['soil_moisture'] as num?)?.toInt(),
      idealMin: (json['ideal_min'] as num?)?.toInt() ?? 35,
      idealMax: (json['ideal_max'] as num?)?.toInt() ?? 80,
      timeInRange24h: (json['time_in_range_24h'] as num?)?.toInt(),
      readings24h: (json['readings_24h'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt(),
      lastSeen: DateTime.tryParse(
        json['last_seen']?.toString() ?? '',
      )?.toLocal(),
    );
  }
}

class SoilHealthModel {
  final String status;
  final int? score;
  final int? avgMoisture;
  final SoilHealthSummary summary;
  final List<SensorHealthModel> sensors;

  const SoilHealthModel({
    required this.status,
    required this.summary,
    required this.sensors,
    this.score,
    this.avgMoisture,
  });

  SensorHealthModel? sensor(String uuid) {
    for (final s in sensors) {
      if (s.uuid == uuid) return s;
    }
    return null;
  }

  factory SoilHealthModel.fromJson(Map<String, dynamic> json) {
    return SoilHealthModel(
      status: json['status']?.toString() ?? 'NO_DATA',
      score: (json['score'] as num?)?.toInt(),
      avgMoisture: (json['avg_moisture'] as num?)?.toInt(),
      summary: SoilHealthSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] ?? const {}),
      ),
      sensors: [
        for (final s in (json['sensors'] as List? ?? const []))
          SensorHealthModel.fromJson(Map<String, dynamic>.from(s)),
      ],
    );
  }
}
