import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/schedule_remote_datasource.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../data/models/schedule_model.dart';

final scheduleRemoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ScheduleRemoteDataSourceImpl(dio);
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final remoteDataSource = ref.watch(scheduleRemoteDataSourceProvider);
  return ScheduleRepositoryImpl(remoteDataSource);
});

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, AsyncValue<List<ScheduleModel>>>((
      ref,
    ) {
      final repository = ref.watch(scheduleRepositoryProvider);
      return ScheduleNotifier(repository);
    });

class ScheduleNotifier extends StateNotifier<AsyncValue<List<ScheduleModel>>> {
  final ScheduleRepository _repository;

  ScheduleNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _repository.getSchedules();
      if (!mounted) return;
      state = AsyncValue.data(schedules);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      await _repository.createSchedule(schedule);
      await fetchSchedules();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await _repository.updateSchedule(schedule);
      await fetchSchedules();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleSchedule(ScheduleModel schedule) async {
    try {
      final updated = schedule.copyWith(enabled: !schedule.enabled);
      await _repository.updateSchedule(updated);
      if (mounted) {
        state.whenData((schedules) {
          final updatedList = schedules.map((s) {
            if (s.uuid == schedule.uuid) {
              return updated;
            }
            return s;
          }).toList();
          state = AsyncValue.data(updatedList);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSchedule(String uuid) async {
    try {
      await _repository.deleteSchedule(uuid);
      await fetchSchedules();
    } catch (e) {
      rethrow;
    }
  }
}
