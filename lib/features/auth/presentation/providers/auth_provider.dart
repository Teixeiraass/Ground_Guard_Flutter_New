import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/network/dio_client.dart';
import 'package:ground_guard_app/core/storage/secure_storage_service.dart';
import 'package:ground_guard_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ground_guard_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ground_guard_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ground_guard_app/features/devices/domain/repositories/devices_repository.dart';
import 'package:ground_guard_app/features/devices/presentation/providers/devices_provider.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';
import 'package:ground_guard_app/core/auth/auth_signals.dart';
import 'auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final devicesRepository = ref.watch(devicesRepositoryProvider);
  return AuthNotifier(authRepository, devicesRepository, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final DevicesRepository _devicesRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._devicesRepository, this._ref) : super(AuthState.initial()) {
    checkAuth();
    _listenToForceLogout();
  }

  void _listenToForceLogout() {
    _ref.listen(forceLogoutProvider, (previous, next) {
      if (next == true) {
        logoutLocal();
        _ref.read(forceLogoutProvider.notifier).state = false;
      }
    });
  }

  void logoutLocal() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  Future<void> checkAuth() async {
    final token = await SecureStorageService.getAccessToken();
    final user = await SecureStorageService.getUser();

    if (token == null || user == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, user: user);

    try {
      final hasDevices = await _devicesRepository.hasDevices();
      state = state.copyWith(
        status: hasDevices ? AuthStatus.authenticated : AuthStatus.authenticatedNoDevices,
        user: user,
      );
    } catch (e) {
      if (state.status != AuthStatus.unauthenticated) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _authRepository.login(email, password);
      final hasDevices = await _devicesRepository.hasDevices();

      state = state.copyWith(
        status: hasDevices ? AuthStatus.authenticated : AuthStatus.authenticatedNoDevices,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _authRepository.register(
        username: username,
        fullName: fullName,
        email: email,
        password: password,
      );
      await login(email: email, password: password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  void updateAuthStatus(AuthStatus status) {
    state = state.copyWith(status: status);
  }
  
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}
