import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/devices_remote_datasource.dart';
import '../../data/repositories/devices_repository_impl.dart';
import '../../domain/repositories/devices_repository.dart';
import '../../data/models/device_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

final devicesRemoteDataSourceProvider = Provider<DevicesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DevicesRemoteDataSourceImpl(dio);
});

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final remoteDataSource = ref.watch(devicesRemoteDataSourceProvider);
  return DevicesRepositoryImpl(remoteDataSource);
});

final devicesProvider = StateNotifierProvider<DevicesNotifier, AsyncValue<List<DeviceModel>>>((ref) {
  final repository = ref.watch(devicesRepositoryProvider);
  return DevicesNotifier(repository, ref);
});

class DevicesNotifier extends StateNotifier<AsyncValue<List<DeviceModel>>> {
  final DevicesRepository _repository;
  final Ref _ref;

  DevicesNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    state = const AsyncValue.loading();
    try {
      final devicesData = await _repository.getDevicesList(); 
      state = AsyncValue.data(devicesData);
      
      // Update AuthStatus based on devices count
      if (devicesData.isNotEmpty) {
        _ref.read(authProvider.notifier).updateAuthStatus(AuthStatus.authenticated);
      } else {
        _ref.read(authProvider.notifier).updateAuthStatus(AuthStatus.authenticatedNoDevices);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> linkDevice(String deviceId) async {
    try {
      await _repository.linkDevice(deviceId);
      await fetchDevices();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateName(String deviceId, String newName) async {
    try {
      await _repository.updateDeviceName(deviceId, newName);
      await fetchDevices(); 
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkDevice(String deviceId) async {
    try {
      await _repository.unlinkDevice(deviceId);
      await fetchDevices();
    } catch (e) {
      rethrow;
    }
  }
}
