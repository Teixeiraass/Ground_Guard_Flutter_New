class DeviceModel {
  final String uuid;
  final String deviceUid;
  final String name;
  final String firmwareVersion;
  final String status;
  final bool isOnline;
  final bool isIrrigating;
  final int? soilMoisture;
  final String? ipAddress;
  final String? wifiSsid;

  DeviceModel({
    required this.uuid,
    required this.deviceUid,
    required this.name,
    required this.firmwareVersion,
    required this.status,
    this.isOnline = false,
    this.isIrrigating = false,
    this.soilMoisture,
    this.ipAddress,
    this.wifiSsid,
  });

  DeviceModel copyWith({
    String? uuid,
    String? deviceUid,
    String? name,
    String? firmwareVersion,
    String? status,
    bool? isOnline,
    bool? isIrrigating,
    int? soilMoisture,
    String? ipAddress,
    String? wifiSsid,
  }) {
    return DeviceModel(
      uuid: uuid ?? this.uuid,
      deviceUid: deviceUid ?? this.deviceUid,
      name: name ?? this.name,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isIrrigating: isIrrigating ?? this.isIrrigating,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      ipAddress: ipAddress ?? this.ipAddress,
      wifiSsid: wifiSsid ?? this.wifiSsid,
    );
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      uuid: json['uuid'] ?? '',
      deviceUid: json['device_uid'] ?? '',
      name: json['name'] ?? '',
      firmwareVersion: json['firmware_version'] ?? '',
      status: json['status'] ?? '',
      isOnline: json['is_online'] == true || json['is_online'] == 1 || json['online'] == true,
      isIrrigating: json['is_irrigating'] == true || json['is_irrigating'] == 1 || json['irrigating'] == true,
      soilMoisture: json['soil_moisture'] != null ? (json['soil_moisture'] as num).toInt() : null,
      ipAddress: json['ip_address'] as String?,
      wifiSsid: json['wifi_ssid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'device_uid': deviceUid,
      'name': name,
      'firmware_version': firmwareVersion,
      'status': status,
      'is_online': isOnline,
      'is_irrigating': isIrrigating,
      'soil_moisture': soilMoisture,
      'ip_address': ipAddress,
      'wifi_ssid': wifiSsid,
    };
  }
}
