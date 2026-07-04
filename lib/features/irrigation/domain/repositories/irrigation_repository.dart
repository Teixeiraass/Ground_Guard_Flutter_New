import '../../data/models/irrigation_preference_model.dart';
import '../../data/models/irrigation_command_model.dart';

abstract class IrrigationRepository {
  Future<IrrigationPreferenceModel> getIrrigationPreference(String deviceUuid);
  Future<void> createIrrigationPreference(Map<String, dynamic> preferenceData);
  Future<void> updateIrrigationPreference(String uuid, Map<String, dynamic> preferenceData);
  Future<IrrigationCommandModel> sendCommand(String deviceUuid, String action);
  Future<IrrigationCommandModel> getCommandStatus(String commandUuid);
}
