import '../../data/models/user_model.dart';

enum AuthStatus {
  authenticated,
  authenticatedNoDevices,
  unauthenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.loading,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
