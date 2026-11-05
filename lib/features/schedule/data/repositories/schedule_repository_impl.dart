import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';
import '../models/schedule_model.dart';
import '../../../../core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;

  ScheduleRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    try {
      return await _remoteDataSource.getSchedules();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    try {
      return await _remoteDataSource.createSchedule(schedule.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    try {
      return await _remoteDataSource.updateSchedule(
        schedule.uuid,
        schedule.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteSchedule(String uuid) async {
    try {
      await _remoteDataSource.deleteSchedule(uuid);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
