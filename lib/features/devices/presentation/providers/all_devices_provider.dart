import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_model.dart';
import 'devices_provider.dart';

final allDevicesProvider = FutureProvider.autoDispose<List<DeviceModel>>((
  ref,
) async {
  final repository = ref.watch(devicesRepositoryProvider);
  return repository.getDevicesList(controllerUuid: null);
});
