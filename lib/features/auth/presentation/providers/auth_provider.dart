import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/network/dio_client.dart';
import 'package:ground_guard_app/core/storage/secure_storage_service.dart';
import 'package:ground_guard_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ground_guard_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ground_guard_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ground_guard_app/features/controllers/domain/repositories/controllers_repository.dart';
import 'package:ground_guard_app/features/controllers/presentation/providers/controllers_provider.dart';
import 'package:ground_guard_app/features/devices/presentation/providers/devices_provider.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';
import 'package:ground_guard_app/core/auth/auth_signals.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ground_guard_app/features/user/presentation/providers/user_provider.dart';
import 'package:ground_guard_app/features/weather/presentation/providers/weather_provider.dart';
import 'package:ground_guard_app/features/irrigation/presentation/providers/irrigation_provider.dart';
import 'auth_state.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId: Platform.isIOS
        ? '427509502373-vsb46tfei7gfff9b6s1qdljlno1jv9rq.apps.googleusercontent.com'
        : '427509502373-u7pppikl9j0ou12naq31ssnes8c4nt2v.apps.googleusercontent.com',
    serverClientId:
        '427509502373-nrr39mln2fki5s66179nei12ks8pam9q.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
});

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
  final controllersRepository = ref.watch(controllersRepositoryProvider);
  return AuthNotifier(authRepository, controllersRepository, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final ControllersRepository _controllersRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._controllersRepository, this._ref)
    : super(AuthState.initial()) {
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
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  Future<bool> _checkHasControllers() async {
    final controllers = await _controllersRepository.getControllers();
    debugPrint('DEBUG_AUTH: Controllers encontrados: ${controllers.length}');
    return controllers.isNotEmpty;
  }

  Future<void> checkAuth() async {
    final token = await SecureStorageService.getAccessToken();
    final user = await SecureStorageService.getUser();

    if (token == null || user == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, user: user);

    _ref.read(userProvider.notifier).setUser(user);

    try {
      final hasControllers = await _checkHasControllers();
      if (!mounted) return;
      state = state.copyWith(
        status: hasControllers
            ? AuthStatus.authenticated
            : AuthStatus.authenticatedNoDevices,
        user: user,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Falha de conexão com o servidor. Verifique sua internet.',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _authRepository.login(email, password);
      final hasControllers = await _checkHasControllers();
      if (!mounted) return;

      state = state.copyWith(
        status: hasControllers
            ? AuthStatus.authenticated
            : AuthStatus.authenticatedNoDevices,
        user: response.user,
      );

      _ref.read(userProvider.notifier).setUser(response.user);
      _ref.read(userProvider.notifier).fetchUserProfile();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final googleSignIn = _ref.read(googleSignInProvider);

      await googleSignIn.disconnect().catchError((_) => null);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Não foi possível obter o ID Token do Google.',
        );
        return;
      }

      final response = await _authRepository.oauthLogin('google', idToken);
      final hasControllers = await _checkHasControllers();

      if (!mounted) return;

      state = state.copyWith(
        status: hasControllers
            ? AuthStatus.authenticated
            : AuthStatus.authenticatedNoDevices,
        user: response.user,
      );

      _ref.read(userProvider.notifier).setUser(response.user);
      _ref.read(userProvider.notifier).fetchUserProfile();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Falha de conexão ou erro no login com Google.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);

    await SecureStorageService.clear();

    try {
      _authRepository.logout();
      _ref.read(googleSignInProvider).signOut();
    } catch (e) {
      debugPrint('Erro ao deslogar do Google/Server: $e');
    }

    _ref.invalidate(userProvider);
    _ref.invalidate(userImageVersionProvider);
    _ref.invalidate(controllersProvider);
    _ref.invalidate(selectedControllerProvider);
    _ref.invalidate(devicesProvider);
    _ref.invalidate(weatherProvider);
    _ref.invalidate(rainForecastProvider);
    _ref.invalidate(irrigationControllerProvider);
    _ref.invalidate(irrigationPreferenceProvider);
  }

  Future<void> requestPasswordReset(String email) async {
    await _authRepository.requestPasswordReset(email);
  }

  void updateAuthStatus(AuthStatus status) {
    state = state.copyWith(status: status);
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}
