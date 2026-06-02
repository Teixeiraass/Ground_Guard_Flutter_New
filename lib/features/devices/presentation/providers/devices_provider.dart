import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/device_model.dart';

final devicesProvider = StateNotifierProvider<DevicesNotifier, AsyncValue<List<DeviceModel>>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return DevicesNotifier(repository);
});

class DevicesNotifier extends StateNotifier<AsyncValue<List<DeviceModel>>> {
  final AuthRepository _repository;

  DevicesNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    state = const AsyncValue.loading();
    try {
      final devicesData = await _repository.getDevicesList(); 
      state = AsyncValue.data(devicesData);
    } catch (e, stack) {
      // O erro aqui já virá como ApiException do repositório
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateName(String deviceId, String newName) async {
    try {
      await _repository.updateDeviceName(deviceId, newName);
      await fetchDevices(); 
    } catch (e) {
      // Deixa o erro subir para ser tratado com um SnackBar na UI
      rethrow;
    }
  }
}
