import '../../data/models/schedule_model.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleModel>> getSchedules();
  Future<ScheduleModel> createSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String uuid);
}
