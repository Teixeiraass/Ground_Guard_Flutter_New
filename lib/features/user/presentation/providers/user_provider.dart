import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/network/dio_client.dart';
import 'package:ground_guard_app/core/storage/secure_storage_service.dart';
import 'package:ground_guard_app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:ground_guard_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:ground_guard_app/features/user/domain/repositories/user_repository.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_state.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDataSourceImpl(dio);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});

// Provider para controlar a versão da imagem e evitar reloads desnecessários
final userImageVersionProvider = StateProvider<int>(
  (ref) => DateTime.now().millisecondsSinceEpoch,
);

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>(
  (ref) {
    final repository = ref.watch(userRepositoryProvider);
    return UserNotifier(repository, ref);
  },
);

class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final UserRepository _repository;
  final Ref _ref;

  UserNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    // Só busca o perfil se o status inicial for autenticado
    final authStatus = _ref.read(authProvider).status;
    if (authStatus == AuthStatus.authenticated ||
        authStatus == AuthStatus.authenticatedNoDevices) {
      fetchUserProfile();
    }
  }

  // Novo método para injetar os dados que já temos do login
  void setUser(UserModel user) {
    state = AsyncValue.data(user);
  }

  Future<void> fetchUserProfile() async {
    // Se não estiver logado, nem tenta buscar para evitar erro de 401 no log
    final token = await SecureStorageService.getAccessToken();
    if (token == null) return;

    // Se já temos dados (do storage), não colocamos o estado em loading puro.
    // Isso evita que a foto desapareça enquanto o app atualiza.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      final user = await _repository.getUserProfile();
      state = AsyncValue.data(user);

      // Atualiza a versão da imagem apenas quando os dados são buscados do servidor
      _ref.read(userImageVersionProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch;

      // Sincroniza com o authProvider para manter o estado global atualizado
      _ref.read(authProvider.notifier).updateUser(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateName(String fullName) async {
    try {
      await _repository.updateUserName(fullName);
      await fetchUserProfile(); // Recarrega os dados após o update
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateImage(String filePath) async {
    try {
      await _repository.updateProfileImage(filePath);
      await fetchUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _repository.changePassword(currentPassword, newPassword);
  }

  Future<void> deleteAccount(String password) async {
    await _repository.deleteAccount(password);
  }

  Future<void> resendVerificationEmail() async {
    await _repository.resendVerificationEmail();
  }
}
