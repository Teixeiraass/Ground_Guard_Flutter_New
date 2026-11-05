import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/statistics_remote_datasource.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../data/models/statistics_model.dart';

final statisticsRemoteDataSourceProvider = Provider<StatisticsRemoteDataSource>(
  (ref) {
    final dio = ref.watch(dioProvider);
    return StatisticsRemoteDataSourceImpl(dio);
  },
);

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final remoteDataSource = ref.watch(statisticsRemoteDataSourceProvider);
  return StatisticsRepositoryImpl(remoteDataSource);
});

final statisticsFiltersProvider = StateProvider<StatisticsFilters>(
  (ref) => StatisticsFilters(),
);

class StatisticsFilters {
  final String? date;
  final String period;
  final String? deviceUuid;

  StatisticsFilters({this.date, this.period = 'week', this.deviceUuid});

  StatisticsFilters copyWith({
    String? date,
    String? period,
    String? deviceUuid,
    bool clearDeviceUuid = false,
  }) {
    return StatisticsFilters(
      date: date ?? this.date,
      period: period ?? this.period,
      deviceUuid: clearDeviceUuid ? null : (deviceUuid ?? this.deviceUuid),
    );
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, AsyncValue<StatisticsModel>>((
      ref,
    ) {
      final repository = ref.watch(statisticsRepositoryProvider);
      final filters = ref.watch(statisticsFiltersProvider);
      return StatisticsNotifier(repository, filters);
    });

class StatisticsNotifier extends StateNotifier<AsyncValue<StatisticsModel>> {
  final StatisticsRepository _repository;
  final StatisticsFilters _filters;

  StatisticsNotifier(this._repository, this._filters)
    : super(const AsyncValue.loading()) {
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    state = const AsyncValue.loading();
    try {
      final statistics = await _repository.getStatistics(
        date: _filters.date,
        period: _filters.period,
        deviceUuid: _filters.deviceUuid,
      );
      state = AsyncValue.data(statistics);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
