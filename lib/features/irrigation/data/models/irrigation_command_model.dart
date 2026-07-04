enum IrrigationStatus { pending, success, failed, timeout, idle }

class IrrigationCommandModel {
  final String uuid;
  final String deviceId;
  final String action;
  final IrrigationStatus status;

  IrrigationCommandModel({
    required this.uuid,
    required this.deviceId,
    required this.action,
    required this.status,
  });

  factory IrrigationCommandModel.fromJson(Map<String, dynamic> json) {
    return IrrigationCommandModel(
      // Aceita uuid ou command_id conforme o retorno da API
      uuid: (json['uuid'] ?? json['command_id'] ?? '').toString(),
      deviceId: (json['device_id'] ?? '').toString(),
      action: json['action'] ?? '',
      status: _mapStatus(json['status']),
    );
  }

  static IrrigationStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING': return IrrigationStatus.pending;
      case 'SUCCESS': return IrrigationStatus.success;
      case 'FAILED': return IrrigationStatus.failed;
      case 'TIMEOUT': return IrrigationStatus.timeout;
      default: return IrrigationStatus.idle;
    }
  }
}
