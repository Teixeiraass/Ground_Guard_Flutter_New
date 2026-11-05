import 'package:dio/dio.dart';
import '../models/schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedules();
  Future<ScheduleModel> createSchedule(Map<String, dynamic> data);
  Future<ScheduleModel> updateSchedule(String uuid, Map<String, dynamic> data);
  Future<void> deleteSchedule(String uuid);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final Dio _dio;

  ScheduleRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final response = await _dio.get('/irrigation/schedules');
      if (response.data is List) {
        final List data = response.data;
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      } else if (response.data is Map && response.data['data'] != null) {
        final List data = response.data['data'];
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScheduleModel> createSchedule(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/irrigation/schedules', data: data);
      return ScheduleModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScheduleModel> updateSchedule(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    try {
      // Backend exige método PUT para atualizar schedules, não PATCH.
      final response = await _dio.put(
        '/irrigation/schedules/$uuid',
        data: data,
      );
      return ScheduleModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSchedule(String uuid) async {
    try {
      await _dio.delete('/irrigation/schedules/$uuid');
    } catch (e) {
      rethrow;
    }
  }
}
