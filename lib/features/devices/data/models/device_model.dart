class DeviceModel {
  final String uuid;
  final String deviceUid;
  final String name;
  final String firmwareVersion;
  final String status;

  DeviceModel({
    required this.uuid,
    required this.deviceUid,
    required this.name,
    required this.firmwareVersion,
    required this.status,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      uuid: json['uuid'] ?? '',
      deviceUid: json['device_uid'] ?? '',
      name: json['name'] ?? '',
      firmwareVersion: json['firmware_version'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'device_uid': deviceUid,
      'name': name,
      'firmware_version': firmwareVersion,
      'status': status,
    };
  }
}
