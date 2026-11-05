import '../../../devices/data/models/device_model.dart';

class ControllerDeviceModel {
  final String uuid;
  final String? dbId;
  final String hardwareUid;
  final String name;
  final String firmwareVersion;
  final String status;
  final bool isOnline;
  final bool isIrrigating;
  final String? macAddress;
  final String? ipAddress;
  final String? wifiSsid;
  final String? lastSeen;
  final bool? provisioningRequired;
  final List<DeviceModel> devices;

  ControllerDeviceModel({
    required this.uuid,
    this.dbId,
    required this.hardwareUid,
    required this.name,
    required this.firmwareVersion,
    required this.status,
    this.isOnline = false,
    this.isIrrigating = false,
    this.macAddress,
    this.ipAddress,
    this.wifiSsid,
    this.lastSeen,
    this.provisioningRequired,
    this.devices = const [],
  });

  ControllerDeviceModel copyWith({
    String? uuid,
    String? dbId,
    String? hardwareUid,
    String? name,
    String? firmwareVersion,
    String? status,
    bool? isOnline,
    bool? isIrrigating,
    String? macAddress,
    String? ipAddress,
    String? wifiSsid,
    String? lastSeen,
    bool? provisioningRequired,
    List<DeviceModel>? devices,
  }) {
    return ControllerDeviceModel(
      uuid: uuid ?? this.uuid,
      dbId: dbId ?? this.dbId,
      hardwareUid: hardwareUid ?? this.hardwareUid,
      name: name ?? this.name,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isIrrigating: isIrrigating ?? this.isIrrigating,
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      lastSeen: lastSeen ?? this.lastSeen,
      provisioningRequired: provisioningRequired ?? this.provisioningRequired,
      devices: devices ?? this.devices,
    );
  }

  factory ControllerDeviceModel.fromJson(Map<String, dynamic> json) {
    final uuid = (json['uuid'] ?? json['id'] ?? '').toString();
    final dbId = json['id'] != null ? json['id'].toString() : null;
    final mac =
        json['bluetoothMacAddress'] ??
        json['bluetooth_mac_address'] ??
        json['mac_address'];
    return ControllerDeviceModel(
      uuid: uuid,
      dbId: dbId,
      hardwareUid:
          (json['device_uid'] ??
                  json['hardware_uid'] ??
                  json['controller_uid'] ??
                  uuid)
              .toString(),
      name: json['name'] ?? 'Controladora',
      firmwareVersion: json['firmware_version'] ?? '1.0.0',
      status: json['status'] ?? 'ativo',
      isOnline:
          json['is_online'] == true ||
          json['online'] == true ||
          json['is_online'] == 1 ||
          json['status'] == 'ONLINE' ||
          json['status'] == 'ATIVO',
      isIrrigating:
          json['is_irrigating'] == true ||
          json['irrigating'] == true ||
          json['is_irrigating'] == 1,
      macAddress: mac as String?,
      ipAddress: json['ip_address'] as String?,
      wifiSsid: json['wifi_ssid'] as String?,
      lastSeen: json['last_seen'] as String?,
      provisioningRequired: json['provisioning_required'] == true,
      devices: (json['devices'] as List? ?? [])
          .map((d) => DeviceModel.fromJson(d))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'id': dbId ?? uuid,
      'device_uid': hardwareUid,
      'name': name,
      'bluetoothMacAddress': macAddress ?? '',
      'firmware_version': firmwareVersion,
      'status': status,
      'is_online': isOnline,
      'is_irrigating': isIrrigating,
      'ip_address': ipAddress,
      'wifi_ssid': wifiSsid,
      'last_seen': lastSeen,
      'provisioning_required': provisioningRequired,
      'devices': devices.map((d) => d.toJson()).toList(),
    };
  }
}
