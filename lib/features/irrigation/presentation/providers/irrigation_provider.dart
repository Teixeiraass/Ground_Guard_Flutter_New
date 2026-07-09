import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/irrigation_remote_datasource.dart';
import '../../data/repositories/irrigation_repository_impl.dart';
import '../../domain/repositories/irrigation_repository.dart';
import '../../data/models/irrigation_preference_model.dart';
import '../../data/models/irrigation_command_model.dart';

final irrigationRemoteDataSourceProvider = Provider<IrrigationRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return IrrigationRemoteDataSourceImpl(dio);
});

final irrigationRepositoryProvider = Provider<IrrigationRepository>((ref) {
  final remoteDataSource = ref.watch(irrigationRemoteDataSourceProvider);
  return IrrigationRepositoryImpl(remoteDataSource);
});

final irrigationControllerProvider = StateNotifierProvider<IrrigationController, AsyncValue<IrrigationCommandModel?>>((ref) {
  final repository = ref.watch(irrigationRepositoryProvider);
  return IrrigationController(repository);
});

class IrrigationController extends StateNotifier<AsyncValue<IrrigationCommandModel?>> {
  final IrrigationRepository _repository;

  IrrigationController(this._repository) : super(const AsyncValue.data(null));

  Future<void> startIrrigation(String deviceUuid) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    try {
      final command = await _repository.sendCommand(deviceUuid, 'START');
      state = AsyncValue.data(command);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> stopIrrigation(String deviceUuid) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    try {
      final command = await _repository.sendCommand(deviceUuid, 'STOP');
      state = AsyncValue.data(command);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final irrigationPreferenceProvider = StateNotifierProvider.family<IrrigationPreferenceNotifier, AsyncValue<IrrigationPreferenceModel>, String>((ref, deviceUuid) {
  final repository = ref.watch(irrigationRepositoryProvider);
  return IrrigationPreferenceNotifier(repository, deviceUuid);
});

class IrrigationPreferenceNotifier extends StateNotifier<AsyncValue<IrrigationPreferenceModel>> {
  final IrrigationRepository _repository;
  final String _deviceUuid;

  IrrigationPreferenceNotifier(this._repository, this._deviceUuid) : super(const AsyncValue.loading()) {
    fetchPreference();
  }

  Future<void> fetchPreference() async {
    if (_deviceUuid.isEmpty) {
      state = AsyncValue.data(IrrigationPreferenceModel.empty());
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final preference = await _repository.getIrrigationPreference(_deviceUuid);
      state = AsyncValue.data(preference);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void updateLocalPreference(IrrigationPreferenceModel updated) {
    state = AsyncValue.data(updated);
  }

  Future<void> savePreference(IrrigationPreferenceModel pref) async {
    try {
      if (pref.uuid.isEmpty) {
        final data = {
          "device_uuid": _deviceUuid,
          "irrigation_mode": pref.enabled ? "INTELIGENTE" : "MANUAL",
          "moisture_threshold": pref.moistureThreshold,
          "dry_time_minutes": pref.dryTimeMinutes,
          "max_irrigation_per_day": pref.maxIrrigationsPerDay,
          "start_hour": "07:00",
          "end_hour": "18:00"
        };
        await _repository.createIrrigationPreference(data);
      } else {
        final data = {
          "enabled": pref.enabled,
          "irrigation_mode": pref.enabled ? "INTELIGENTE" : "MANUAL",
          "moisture_threshold": pref.moistureThreshold,
          "dry_time_minutes": pref.dryTimeMinutes,
          "irrigation_duration_seconds": pref.irrigationDurationSeconds,
          "max_irrigations_per_day": pref.maxIrrigationsPerDay,
        };
        await _repository.updateIrrigationPreference(pref.uuid, data);
      }
      await fetchPreference();
    } catch (e) {
      rethrow;
    }
  }
}
