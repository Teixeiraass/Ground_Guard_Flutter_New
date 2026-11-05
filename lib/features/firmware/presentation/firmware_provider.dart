import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/websocket/websocket_provider.dart';
import '../data/controller_firmware_model.dart';

/// Latest published firmware version, or null when none was published yet.
final latestFirmwareVersionProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  try {
    final response = await ref.watch(dioProvider).get('/firmware/latest');
    return Map<String, dynamic>.from(response.data)['version']?.toString();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    throw ApiException.fromDioError(e);
  }
});

final controllerFirmwareProvider = FutureProvider.autoDispose
    .family<ControllerFirmwareModel, String>((ref, controllerUuid) async {
      // Progress (DOWNLOADING, SUCCESS, FAILED) is pushed over the websocket.
      ref.listen(webSocketMessagesProvider, (_, next) {
        final message = next.valueOrNull;
        if (message?.type == 'controller_ota' &&
            message?.controllerUuid == controllerUuid) {
          ref.invalidateSelf();
          ref.invalidate(latestFirmwareVersionProvider);
        }
      });

      try {
        final response = await ref
            .watch(dioProvider)
            .get('/controller-devices/$controllerUuid/firmware');
        return ControllerFirmwareModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      } on DioException catch (e) {
        throw ApiException.fromDioError(e);
      }
    });

class FirmwareActions {
  final Ref _ref;

  FirmwareActions(this._ref);

  Future<void> updateNow(String controllerUuid) async {
    try {
      await _ref
          .read(dioProvider)
          .post('/controller-devices/$controllerUuid/firmware/update');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } finally {
      _ref.invalidate(controllerFirmwareProvider(controllerUuid));
    }
  }

  Future<void> setAutoUpdate(String controllerUuid, bool enabled) async {
    try {
      await _ref
          .read(dioProvider)
          .put(
            '/controller-devices/$controllerUuid/firmware/auto-update',
            data: {'enabled': enabled},
          );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } finally {
      _ref.invalidate(controllerFirmwareProvider(controllerUuid));
    }
  }
}

final firmwareActionsProvider = Provider<FirmwareActions>(FirmwareActions.new);
