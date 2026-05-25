import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';
import 'dart:io';

final dioProvider = Provider<Dio>((ref) {
  const String machineIp = '192.168.15.15';

  final baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8080' 
      : 'http://$machineIp:8080';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(AuthInterceptor(dio));

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
