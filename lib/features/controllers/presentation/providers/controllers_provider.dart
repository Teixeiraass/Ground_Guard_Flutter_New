import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/websocket/websocket_message.dart';
import '../../../../core/websocket/websocket_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/datasources/controllers_remote_datasource.dart';
import '../../data/models/controller_device_model.dart';
import '../../data/repositories/controllers_repository_impl.dart';
import '../../domain/repositories/controllers_repository.dart';

final controllersRemoteDataSourceProvider =
    Provider<ControllersRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return ControllersRemoteDataSourceImpl(dio);
    });

final controllersRepositoryProvider = Provider<ControllersRepository>((ref) {
  final remoteDataSource = ref.watch(controllersRemoteDataSourceProvider);
  return ControllersRepositoryImpl(remoteDataSource);
});

final selectedControllerProvider = StateProvider<ControllerDeviceModel?>(
  (ref) => null,
);

final controllersProvider =
    StateNotifierProvider<
      ControllersNotifier,
      AsyncValue<List<ControllerDeviceModel>>
    >((ref) {
      final repository = ref.watch(controllersRepositoryProvider);
      return ControllersNotifier(repository, ref);
    });

class ControllersNotifier
    extends StateNotifier<AsyncValue<List<ControllerDeviceModel>>> {
  final ControllersRepository _repository;
  final Ref _ref;

  ControllersNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<WebSocketMessage>>(webSocketMessagesProvider, (
      previous,
      next,
    ) {
      final message = next.valueOrNull;
      if (message == null) return;

      if (message.type == 'controller_device_state' ||
          message.type == 'controller_state' ||
          message.type == 'controller_device_telemetry') {
        _applyControllerState(message);
      }
    });
    fetchControllers();
  }

  void _applyControllerState(WebSocketMessage message) {
    debugPrint(
      'WebSocket WS_CONTROLLER_EVENT: '
      'type=${message.type}, '
      'controller_uuid=${message.controllerUuid}, '
      'device_uid=${message.deviceUid}, '
      'status=${message.status}, '
      'is_online=${message.isOnline}',
    );

    final current = state.valueOrNull;
    if (current == null) return;

    final targetUuid = message.controllerUuid.trim().toLowerCase();
    final targetDeviceUid = message.deviceUid.trim().toUpperCase();

    // Busca primeiro por controller_uuid (identificador principal da entidade)
    int controllerIndex = -1;
    if (targetUuid.isNotEmpty) {
      controllerIndex = current.indexWhere(
        (c) => c.uuid.trim().toLowerCase() == targetUuid,
      );
    }

    // Se não encontrou por controller_uuid, busca por device_uid
    if (controllerIndex == -1 && targetDeviceUid.isNotEmpty) {
      controllerIndex = current.indexWhere(
        (c) => c.hardwareUid.trim().toUpperCase() == targetDeviceUid,
      );
    }

    if (controllerIndex == -1) {
      debugPrint(
        'WebSocket controladora não encontrada localmente: '
        'controller_uuid=${message.controllerUuid}, device_uid=${message.deviceUid}',
      );
      return;
    }

    final old = current[controllerIndex];
    final updated = old.copyWith(
      isOnline: message.isOnline,
      status: message.status ?? (message.isOnline ? 'online' : 'offline'),
      isIrrigating: message.isIrrigating,
      ipAddress: message.ipAddress ?? old.ipAddress,
      wifiSsid: message.wifiSsid ?? old.wifiSsid,
      lastSeen: message.lastSeen ?? old.lastSeen,
      provisioningRequired:
          message.provisioningRequired ?? old.provisioningRequired,
    );

    final updatedList = [...current];
    updatedList[controllerIndex] = updated;
    state = AsyncValue.data(updatedList);

    final selected = _ref.read(selectedControllerProvider);
    if (selected != null &&
        (selected.uuid == updated.uuid ||
            (targetDeviceUid.isNotEmpty &&
                selected.hardwareUid.toUpperCase() == targetDeviceUid))) {
      _ref.read(selectedControllerProvider.notifier).state = updated;
    }
  }

  Future<void> fetchControllers() async {
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final controllers = await _repository.getControllers();
      if (!mounted) return;
      state = AsyncValue.data(controllers);

      final currentSelected = _ref.read(selectedControllerProvider);
      if (controllers.isNotEmpty) {
        if (currentSelected != null) {
          final updatedSelected = controllers
              .where((c) => c.uuid == currentSelected.uuid)
              .firstOrNull;
          _ref.read(selectedControllerProvider.notifier).state =
              updatedSelected ?? controllers.first;
        } else {
          _ref.read(selectedControllerProvider.notifier).state =
              controllers.first;
        }
        _ref
            .read(authProvider.notifier)
            .updateAuthStatus(AuthStatus.authenticated);
      } else {
        _ref.read(selectedControllerProvider.notifier).state = null;
        _ref
            .read(authProvider.notifier)
            .updateAuthStatus(AuthStatus.authenticatedNoDevices);
      }
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<ControllerDeviceModel> registerController({
    required String name,
    required String bluetoothMacAddress,
  }) async {
    try {
      final newController = await _repository.registerController(
        name: name,
        bluetoothMacAddress: bluetoothMacAddress,
      );
      await fetchControllers();
      _ref.read(selectedControllerProvider.notifier).state = newController;
      return newController;
    } catch (e) {
      rethrow;
    }
  }

  Future<ControllerDeviceModel> registerAndClaimBleController({
    required String deviceUid,
    required String name,
    required String firmwareVersion,
    required String firmwareBuild,
  }) async {
    try {
      await _repository.registerBleController(
        deviceUid: deviceUid,
        name: name,
        firmwareVersion: firmwareVersion,
        firmwareBuild: firmwareBuild,
      );

      final claimedController = await _repository.claimController(deviceUid);

      // O claim já confirma (com o objeto retornado pela própria API) que
      // este usuário tem pelo menos uma controladora. Atualiza o estado
      // local e o status de autenticação AGORA, em vez de depender de um
      // fetchControllers() subsequente: esse GET pode, por qualquer motivo
      // de rede/latência, ainda não refletir o claim e devolver lista vazia,
      // o que rebaixaria authProvider para authenticatedNoDevices e
      // bloquearia a navegação para a tela principal no route guard (só a
      // seleção de controller era corrigida depois, não o status de auth).
      final current = state.valueOrNull ?? [];
      final updatedList = [
        ...current.where((c) => c.uuid != claimedController.uuid),
        claimedController,
      ];
      state = AsyncValue.data(updatedList);
      _ref.read(selectedControllerProvider.notifier).state = claimedController;
      _ref
          .read(authProvider.notifier)
          .updateAuthStatus(AuthStatus.authenticated);

      unawaited(fetchControllers());
      return claimedController;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> triggerPairing(String deviceUid) async {
    try {
      await _repository.triggerPairing(deviceUid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateName(String uuid, String newName) async {
    try {
      await _repository.updateControllerName(uuid, newName);
      await fetchControllers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteController(String uuid) async {
    try {
      await _repository.deleteController(uuid);
      await fetchControllers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleIrrigation(String uuid, bool start) async {
    try {
      await _repository.sendControllerCommand(uuid, start ? 'START' : 'STOP');
      await fetchControllers();
    } catch (e) {
      rethrow;
    }
  }
}
