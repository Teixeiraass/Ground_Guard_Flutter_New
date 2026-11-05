import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  dio.interceptors.add(
    AuthInterceptor(
      dio,
      onUnauthorized: () async {
        await SecureStorageService.clear();
        ref.read(forceLogoutProvider.notifier).state = true;
      },
    ),
  );

  // Debug builds only, and never headers or bodies: they carry the bearer
  // token, passwords, refresh/ID tokens and chat messages.
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (obj) => debugPrint('DEBUG_DIO: $obj'),
      ),
    );
  }

  return dio;
});
