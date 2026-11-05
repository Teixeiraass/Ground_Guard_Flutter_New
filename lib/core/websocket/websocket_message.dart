class WebSocketMessage {
  final String type;
  final String deviceUid;
  final String controllerUuid;
  final String? status;
  final bool isIrrigating;
  final bool isOnline;
  final int? soilMoisture;
  final bool? sensorOk;
  final String? ipAddress;
  final String? wifiSsid;
  final bool? provisioningRequired;
  final String? lastSeen;
  final String? notificationUuid;
  final String? notificationType;
  final String? title;
  final String? body;

  WebSocketMessage({
    required this.type,
    required this.deviceUid,
    this.controllerUuid = '',
    this.status,
    required this.isIrrigating,
    required this.isOnline,
    this.soilMoisture,
    this.sensorOk,
    this.ipAddress,
    this.wifiSsid,
    this.provisioningRequired,
    this.lastSeen,
    this.notificationUuid,
    this.notificationType,
    this.title,
    this.body,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString();
    final bool isOnlineCalculated =
        json['is_online'] == true ||
        json['is_online'] == 1 ||
        statusStr?.toUpperCase() == 'ONLINE' ||
        statusStr?.toUpperCase() == 'ATIVO';

    return WebSocketMessage(
      type: (json['type'] ?? '').toString(),
      deviceUid: (json['device_uid'] ?? json['deviceUid'] ?? '').toString(),
      controllerUuid: (json['controller_uuid'] ?? json['controllerUuid'] ?? '')
          .toString(),
      status: statusStr,
      isIrrigating: json['is_irrigating'] == true || json['is_irrigating'] == 1,
      isOnline: isOnlineCalculated,
      soilMoisture: json['soil_moisture'] != null
          ? (json['soil_moisture'] as num).toInt()
          : null,
      sensorOk: json['sensor_ok'] as bool?,
      ipAddress: json['ip_address']?.toString(),
      wifiSsid: json['wifi_ssid']?.toString(),
      provisioningRequired: json['provisioning_required'] == true,
      lastSeen: json['last_seen']?.toString(),
      notificationUuid: json['notification_uuid']?.toString(),
      notificationType: json['notification_type']?.toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'device_uid': deviceUid,
      'controller_uuid': controllerUuid,
      'status': status,
      'is_irrigating': isIrrigating,
      'is_online': isOnline,
      'soil_moisture': soilMoisture,
      'ip_address': ipAddress,
      'wifi_ssid': wifiSsid,
      'provisioning_required': provisioningRequired,
      'last_seen': lastSeen,
    };
  }
}
