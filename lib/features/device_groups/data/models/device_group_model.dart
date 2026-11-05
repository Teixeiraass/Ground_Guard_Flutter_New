class DeviceGroupModel {
  final String uuid;
  final String name;
  final int deviceCount;
  final int onlineCount;
  final int irrigatingCount;
  final double? avgSoilMoisture;

  const DeviceGroupModel({
    required this.uuid,
    required this.name,
    required this.deviceCount,
    required this.onlineCount,
    required this.irrigatingCount,
    this.avgSoilMoisture,
  });

  factory DeviceGroupModel.fromJson(Map<String, dynamic> json) {
    return DeviceGroupModel(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      deviceCount: json['device_count'] ?? 0,
      onlineCount: json['online_count'] ?? 0,
      irrigatingCount: json['irrigating_count'] ?? 0,
      avgSoilMoisture: json['avg_soil_moisture'] != null
          ? (json['avg_soil_moisture'] as num).toDouble()
          : null,
    );
  }
}
