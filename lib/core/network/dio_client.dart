import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';
import '../util/api_config.dart';
import '../storage/secure_storage_service.dart';
import '../auth/auth_signals.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ApiConfig.baseUrl;

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(AuthInterceptor(
    dio,
    onUnauthorized: () async {
      await SecureStorageService.clear();
      ref.read(forceLogoutProvider.notifier).state = true;
    },
  ));

  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => print('DEBUG_DIO: $obj'),
  ));

  return dio;
});
