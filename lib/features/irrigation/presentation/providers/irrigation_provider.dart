import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/irrigation_remote_datasource.dart';
import '../../data/repositories/irrigation_repository_impl.dart';
import '../../domain/repositories/irrigation_repository.dart';
import '../../data/models/irrigation_preference_model.dart';

final irrigationRemoteDataSourceProvider = Provider<IrrigationRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return IrrigationRemoteDataSourceImpl(dio);
});

final irrigationRepositoryProvider = Provider<IrrigationRepository>((ref) {
  final remoteDataSource = ref.watch(irrigationRemoteDataSourceProvider);
  return IrrigationRepositoryImpl(remoteDataSource);
});

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
        // Create new
        final data = {
          "device_uuid": _deviceUuid,
          "irrigation_mode": pref.enabled ? "INTELIGENTE" : "MANUAL",
          "moisture_threshold": pref.moistureThreshold,
          "dry_time_minutes": pref.dryTimeMinutes,
          "max_irrigation_per_day": pref.maxIrrigationsPerDay,
          "start_hour": "07:00", // Default as per your example
          "end_hour": "18:00"    // Default as per your example
        };
        await _repository.createIrrigationPreference(data);
      } else {
        // Update existing (Assuming there's an update endpoint, or reusing the same logic)
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
      await fetchPreference(); // Refresh data
    } catch (e) {
      rethrow;
    }
  }
}
