import 'package:flutter/foundation.dart';

class ApiConfig {
  // Define o ambiente via --dart-define=APP_ENV=dev
  // Valores possíveis: local, dev, prod
  static const String _explicitEnv = String.fromEnvironment('APP_ENV');

  // A release build without APP_ENV must never talk plain HTTP to a LAN IP.
  static String get _env => _explicitEnv.isNotEmpty
      ? _explicitEnv
      : (kReleaseMode ? 'prod' : 'local');

  static const String _machineIp = '192.168.15.8';

  static String get _host {
    switch (_env) {
      case 'dev':
        return 'api-dev.ground-guard.com.br';
      case 'prod':
        return 'api.ground-guard.com.br';
      case 'local':
        return '$_machineIp:8080';
      default:
        // No local usamos o IP da máquina com a porta 8080
        return '$_machineIp:8080';
    }
  }

  static String get _protocol {
    // Local usa http, dev/prod usam https
    return _env == 'local' ? 'http' : 'https';
  }

  static String get baseUrl => '$_protocol://$_host/api/v1';

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return '$_protocol://$_host/$cleanPath';
  }

  // Helper para saber se estamos em ambiente de desenvolvimento
  static bool get isLocal => _env == 'local';
  static bool get isDev => _env == 'dev';
  static bool get isProd => _env == 'prod';
}
