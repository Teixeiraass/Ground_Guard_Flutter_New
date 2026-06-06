import 'package:ground_guard_app/features/user/data/models/user_model.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      accessTokenExpiresAt:
      DateTime.parse(json['access_token_expires_at']),
      user: UserModel.fromJson(json['user']),
    );
  }
}
