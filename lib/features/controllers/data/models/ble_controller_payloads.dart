class BleControllerReadyPayload {
  final String status;
  final String deviceUid;
  final String deviceName;
  final String firmwareVersion;
  final String firmwareBuild;

  BleControllerReadyPayload({
    required this.status,
    required this.deviceUid,
    required this.deviceName,
    required this.firmwareVersion,
    required this.firmwareBuild,
  });

  factory BleControllerReadyPayload.fromJson(Map<String, dynamic> json) {
    final deviceUid = (json['device_uid'] ?? json['deviceUid'] ?? '')
        .toString()
        .trim();
    if (deviceUid.isEmpty) {
      throw const FormatException(
        'O campo device_uid está ausente ou vazio na resposta BLE.',
      );
    }

    final defaultName = 'ground_guard_$deviceUid';
    final name = (json['device_name'] ?? json['deviceName'] ?? defaultName)
        .toString()
        .trim();

    return BleControllerReadyPayload(
      status: (json['status'] ?? '').toString(),
      deviceUid: deviceUid,
      deviceName: name.isEmpty ? defaultName : name,
      firmwareVersion:
          (json['firmware_version'] ?? json['firmwareVersion'] ?? '1.0.0')
              .toString(),
      firmwareBuild: (json['firmware_build'] ?? json['firmwareBuild'] ?? '1')
          .toString(),
    );
  }
}

class BleWifiSetupPayload {
  final String wifiSsid;
  final String wifiPassword;

  BleWifiSetupPayload({required this.wifiSsid, required this.wifiPassword});

  Map<String, dynamic> toJson() {
    return {'wifi_ssid': wifiSsid, 'wifi_password': wifiPassword};
  }
}

class BleControllerSavedPayload {
  final String status;
  final String deviceUid;
  final String? reason;

  BleControllerSavedPayload({
    required this.status,
    required this.deviceUid,
    this.reason,
  });

  factory BleControllerSavedPayload.fromJson(Map<String, dynamic> json) {
    return BleControllerSavedPayload(
      status: (json['status'] ?? '').toString(),
      deviceUid: (json['device_uid'] ?? json['deviceUid'] ?? '').toString(),
      reason: json['reason'] as String?,
    );
  }

  bool get isSaved => status.toLowerCase() == 'saved';
  bool get isMissingUserIdError => reason == 'missing_user_id';
}
