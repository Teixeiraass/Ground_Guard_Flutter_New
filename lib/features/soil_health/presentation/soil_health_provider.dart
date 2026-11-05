import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/websocket/websocket_provider.dart';
import '../data/soil_health_model.dart';

const _refreshAfter = Duration(seconds: 60);

final soilHealthProvider = FutureProvider.autoDispose<SoilHealthModel>((
  ref,
) async {
  final fetchedAt = DateTime.now();

  // Sensors report every few seconds; refetch at most once a minute.
  ref.listen(webSocketMessagesProvider, (_, next) {
    final type = next.valueOrNull?.type;
    if ((type == 'device_telemetry' || type == 'device_state') &&
        DateTime.now().difference(fetchedAt) > _refreshAfter) {
      ref.invalidateSelf();
    }
  });

  try {
    final response = await ref
        .watch(dioProvider)
        .get('/statistics/soil-health');
    return SoilHealthModel.fromJson(Map<String, dynamic>.from(response.data));
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  }
});
