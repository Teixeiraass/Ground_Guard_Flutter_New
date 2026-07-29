class WebSocketMessage {
  final String type;
  final String deviceUid;
  final bool isIrrigating;
  final bool isOnline;
  final int? soilMoisture;

  WebSocketMessage({
    required this.type,
    required this.deviceUid,
    required this.isIrrigating,
    required this.isOnline,
    this.soilMoisture,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? '',
      deviceUid: json['device_uid'] ?? '',
      isIrrigating: json['is_irrigating'] ?? false,
      isOnline: json['is_online'] ?? false,
      soilMoisture: json['soil_moisture'] != null ? (json['soil_moisture'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'device_uid': deviceUid,
      'is_irrigating': isIrrigating,
      'is_online': isOnline,
      'soil_moisture': soilMoisture,
    };
  }
}
