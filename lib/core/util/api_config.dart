import 'dart:io';

class ApiConfig {
  static const String _machineIp = '192.168.15.15';
  
  static String get baseUrl => Platform.isAndroid 
      ? 'http://10.0.2.2:8080'
      : 'http://$_machineIp:8080';

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl/$path';
  }
}
