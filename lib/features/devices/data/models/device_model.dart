class DeviceModel {
  final String uuid;
  final String? qrToken;
  final String deviceUid;
  final String name;
  final String firmwareVersion;
  final String status;
  final String? controllerUuid;
  final String? controllerDeviceId;
  final bool isOnline;
  final bool isIrrigating;
  final int? soilMoisture;
  final String? ipAddress;
  final String? wifiSsid;

  /// null = firmware doesn't report it (older versions).
  final bool? sensorOk;
  final int? wifiRssi;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  DeviceModel({
    required this.uuid,
    this.qrToken,
    required this.deviceUid,
    required this.name,
    required this.firmwareVersion,
    required this.status,
    this.controllerUuid,
    this.controllerDeviceId,
    this.isOnline = false,
    this.isIrrigating = false,
    this.soilMoisture,
    this.ipAddress,
    this.wifiSsid,
    this.sensorOk,
    this.wifiRssi,
    this.latitude,
    this.longitude,
  });

  DeviceModel copyWith({
    String? uuid,
    String? qrToken,
    String? deviceUid,
    String? name,
    String? firmwareVersion,
    String? status,
    String? controllerUuid,
    String? controllerDeviceId,
    bool? isOnline,
    bool? isIrrigating,
    int? soilMoisture,
    String? ipAddress,
    String? wifiSsid,
    bool? sensorOk,
    int? wifiRssi,
    double? latitude,
    double? longitude,
    bool clearLocation = false,
  }) {
    return DeviceModel(
      uuid: uuid ?? this.uuid,
      qrToken: qrToken ?? this.qrToken,
      deviceUid: deviceUid ?? this.deviceUid,
      name: name ?? this.name,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      status: status ?? this.status,
      controllerUuid: controllerUuid ?? this.controllerUuid,
      controllerDeviceId: controllerDeviceId ?? this.controllerDeviceId,
      isOnline: isOnline ?? this.isOnline,
      isIrrigating: isIrrigating ?? this.isIrrigating,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      ipAddress: ipAddress ?? this.ipAddress,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      sensorOk: sensorOk ?? this.sensorOk,
      wifiRssi: wifiRssi ?? this.wifiRssi,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
    );
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      uuid: (json['id'] ?? json['uuid'] ?? '').toString(),
      qrToken:
          (json['qrToken'] ??
                  json['qr_token'] ??
                  json['qrCode'] ??
                  json['qr_code'])
              ?.toString(),
      deviceUid:
          (json['device_uid'] ??
                  json['deviceUid'] ??
                  json['hardware_uid'] ??
                  json['qrCode'] ??
                  json['qr_code'] ??
                  json['id'] ??
                  '')
              .toString(),
      name: json['name'] ?? 'Sensor',
      firmwareVersion: json['firmware_version'] ?? '1.0.0',
      status: json['status'] ?? 'ativo',
      controllerUuid:
          (json['controller_uuid'] ??
                  json['controllerUuid'] ??
                  json['controller_device_uuid'])
              ?.toString(),
      controllerDeviceId:
          (json['controllerDeviceId'] ??
                  json['controller_device_id'] ??
                  json['controller_id'])
              ?.toString(),
      isOnline:
          json['is_online'] == true ||
          json['online'] == true ||
          json['is_online'] == 1 ||
          json['status'] == 'ativo',
      isIrrigating:
          json['is_irrigating'] == true ||
          json['is_irrigating'] == 1 ||
          json['irrigating'] == true,
      soilMoisture: json['soil_moisture'] != null
          ? (json['soil_moisture'] as num).toInt()
          : null,
      ipAddress: json['ip_address'] as String?,
      wifiSsid: json['wifi_ssid'] as String?,
      sensorOk: json['sensor_ok'] as bool?,
      wifiRssi: (json['wifi_rssi'] as num?)?.toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'uuid': uuid,
      'qrToken': qrToken,
      'qr_token': qrToken,
      'qrCode': deviceUid,
      'device_uid': deviceUid,
      'name': name,
      'controller_uuid': controllerUuid,
      'controllerDeviceId': controllerDeviceId,
      'controller_device_id': controllerDeviceId,
      'firmware_version': firmwareVersion,
      'status': status,
      'is_online': isOnline,
      'is_irrigating': isIrrigating,
      'soil_moisture': soilMoisture,
      'ip_address': ipAddress,
      'wifi_ssid': wifiSsid,
      'sensor_ok': sensorOk,
      'wifi_rssi': wifiRssi,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
