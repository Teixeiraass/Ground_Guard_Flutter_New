import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
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
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    checkAuth();
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
      final hasDevices = await _repository.hasDevices();
      state = state.copyWith(
        status: hasDevices ? AuthStatus.authenticated : AuthStatus.authenticatedNoDevices,
        user: user,
      );
    } catch (e) {
      // Se falhar a checagem de devices, deixamos logado por segurança
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _repository.login(email, password);
      final hasDevices = await _repository.hasDevices();

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
      await _repository.register(
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

  Future<void> linkDevice(String deviceId) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.linkDevice(deviceId);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticatedNoDevices,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateDeviceName(String deviceId, String name) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.updateDeviceName(deviceId, name);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticatedNoDevices,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }
}
