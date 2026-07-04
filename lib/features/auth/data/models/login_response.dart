import 'package:ground_guard_app/features/user/data/models/user_model.dart';

class LoginResponse {
  final String sessionId;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final UserModel user;

  LoginResponse({
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      sessionId: json['session_id'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      // Supporting both spellings for the access token expiry
      accessTokenExpiresAt: DateTime.parse(
          json['acces_token_expires_at'] ?? json['access_token_expires_at']),
      refreshTokenExpiresAt: DateTime.parse(json['refresh_token_expires_at']),
      user: UserModel.fromJson(json['user']),
    );
  }
}
