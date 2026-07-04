import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<void> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  });
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
  Future<bool> hasDevices();
  Future<LoginResponse> oauthLogin(String provider, String idToken);
}
