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
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(status: AuthStatus.authenticated);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _repository.login(email, password);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Falha no login. Verifique suas credenciais.';
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: message,
      );
    } catch (e, stack) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Erro inesperado. Tente novamente.',
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
        errorMessage: 'Falha no registro. Tente novamente.',
      );
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
