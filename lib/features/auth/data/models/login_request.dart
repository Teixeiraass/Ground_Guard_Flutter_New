import '../../../../core/device/device_metadata_service.dart';

class LoginRequest {
  final String email;
  final String password;
  final DeviceMetadata device;

  LoginRequest({
    required this.email,
    required this.password,
    this.device = DeviceMetadata.empty,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, ...device.toJson()};
  }
}
