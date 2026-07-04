import 'dart:io';

class ApiConfig {
  static const String _machineIp = '192.168.15.15';
  
  static String get baseUrl => Platform.isAndroid 
      ? 'http://10.0.2.2:8080/api/v1'
      : 'http://$_machineIp:8080/api/v1';

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    // Ensure path doesn't start with / to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // Images are typically served from the root, not /api/v1
    return 'http://$_machineIp:8080/$cleanPath';
  }
}
