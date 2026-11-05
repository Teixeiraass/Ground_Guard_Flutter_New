import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/device_groups_remote_datasource.dart';
import '../../data/models/device_group_detail_model.dart';
import '../../data/models/device_group_model.dart';
import '../../data/models/device_group_statistics_model.dart';
import '../../data/repositories/device_groups_repository_impl.dart';
import '../../domain/repositories/device_groups_repository.dart';

final deviceGroupsRemoteDataSourceProvider =
    Provider<DeviceGroupsRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return DeviceGroupsRemoteDataSourceImpl(dio);
    });

final deviceGroupsRepositoryProvider = Provider<DeviceGroupsRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(deviceGroupsRemoteDataSourceProvider);
  return DeviceGroupsRepositoryImpl(remoteDataSource);
});

final deviceGroupsProvider =
    StateNotifierProvider<DeviceGroupsNotifier, AsyncValue<List<DeviceGroupModel>>>((
      ref,
    ) {
      final repository = ref.watch(deviceGroupsRepositoryProvider);
      return DeviceGroupsNotifier(repository);
    });

final deviceGroupDetailProvider = StateNotifierProvider.family<
  DeviceGroupDetailNotifier,
  AsyncValue<DeviceGroupDetailModel>,
  String
>((ref, groupUuid) {
  final repository = ref.watch(deviceGroupsRepositoryProvider);
  return DeviceGroupDetailNotifier(repository, groupUuid);
});

/// Estatísticas agregadas do grupo (consumo de água, histórico, resumo de
/// umidade). `period` aceita "day"/"week"/"month"; `null` usa o default do
/// backend ("week").
final deviceGroupStatisticsProvider = FutureProvider.autoDispose.family<
  DeviceGroupStatisticsModel,
  ({String groupUuid, String? period})
>((ref, params) {
  final repository = ref.watch(deviceGroupsRepositoryProvider);
  return repository.getStatistics(params.groupUuid, period: params.period);
});

class DeviceGroupsNotifier
    extends StateNotifier<AsyncValue<List<DeviceGroupModel>>> {
  final DeviceGroupsRepository _repository;

  DeviceGroupsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    state = const AsyncValue.loading();
    try {
      final groups = await _repository.getGroups();
      if (!mounted) return;
      state = AsyncValue.data(groups);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<DeviceGroupModel> createGroup(String name) async {
    final group = await _repository.createGroup(name);
    await fetchGroups();
    return group;
  }

  Future<void> deleteGroup(String uuid) async {
    await _repository.deleteGroup(uuid);
    await fetchGroups();
  }
}

class DeviceGroupDetailNotifier
    extends StateNotifier<AsyncValue<DeviceGroupDetailModel>> {
  final DeviceGroupsRepository _repository;
  final String groupUuid;

  DeviceGroupDetailNotifier(this._repository, this.groupUuid)
    : super(const AsyncValue.loading()) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = const AsyncValue.loading();
    try {
      final detail = await _repository.getGroup(groupUuid);
      if (!mounted) return;
      state = AsyncValue.data(detail);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> rename(String name) async {
    await _repository.renameGroup(groupUuid, name);
    await fetchDetail();
  }

  Future<List<Map<String, dynamic>>> triggerIrrigation(String action) async {
    final results = await _repository.triggerIrrigation(groupUuid, action);
    await fetchDetail();
    return results;
  }

  Future<void> assignDevice(String deviceUuid) async {
    await _repository.assignDeviceToGroup(deviceUuid, groupUuid);
    await fetchDetail();
  }

  Future<void> removeDevice(String deviceUuid) async {
    await _repository.assignDeviceToGroup(deviceUuid, null);
    await fetchDetail();
  }
}
