class DeviceModel {
  final String uuid;
  final String deviceUid;
  final String name;
  final String firmwareVersion;
  final String status;
  final bool isOnline;
  final bool isIrrigating;

  DeviceModel({
    required this.uuid,
    required this.deviceUid,
    required this.name,
    required this.firmwareVersion,
    required this.status,
    this.isOnline = false,
    this.isIrrigating = false,
  });

  DeviceModel copyWith({
    String? uuid,
    String? deviceUid,
    String? name,
    String? firmwareVersion,
    String? status,
    bool? isOnline,
    bool? isIrrigating,
  }) {
    return DeviceModel(
      uuid: uuid ?? this.uuid,
      deviceUid: deviceUid ?? this.deviceUid,
      name: name ?? this.name,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isIrrigating: isIrrigating ?? this.isIrrigating,
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
    };
  }
}
