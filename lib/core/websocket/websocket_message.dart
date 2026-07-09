class WebSocketMessage {
  final String type;
  final String deviceUid;
  final bool isIrrigating;
  final bool isOnline;

  WebSocketMessage({
    required this.type,
    required this.deviceUid,
    required this.isIrrigating,
    required this.isOnline,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? '',
      deviceUid: json['device_uid'] ?? '',
      isIrrigating: json['is_irrigating'] ?? false,
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'device_uid': deviceUid,
      'is_irrigating': isIrrigating,
      'is_online': isOnline,
    };
  }
}
