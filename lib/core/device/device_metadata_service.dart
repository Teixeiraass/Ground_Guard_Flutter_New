import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Metadados do aparelho/app enviados no login e no cadastro, pra o backend
/// guardar o último modelo de celular, SO e versão do app usados pela conta
/// (suporte, diagnóstico, estatísticas de uso — nada crítico: se a coleta
/// falhar por qualquer motivo, os campos simplesmente ficam vazios).
class DeviceMetadata {
  final String deviceModel;
  final String platform;
  final String osVersion;
  final String appVersion;

  const DeviceMetadata({
    required this.deviceModel,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
  });

  static const empty = DeviceMetadata(
    deviceModel: '',
    platform: '',
    osVersion: '',
    appVersion: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'device_model': deviceModel,
      'platform': platform,
      'os_version': osVersion,
      'app_version': appVersion,
    };
  }
}

class DeviceMetadataService {
  static Future<DeviceMetadata> collect() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return DeviceMetadata(
          deviceModel: info.utsname.machine,
          platform: 'ios',
          osVersion: info.systemVersion,
          appVersion: packageInfo.version,
        );
      }

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return DeviceMetadata(
          deviceModel: '${info.manufacturer} ${info.model}'.trim(),
          platform: 'android',
          osVersion: info.version.release,
          appVersion: packageInfo.version,
        );
      }

      return DeviceMetadata.empty;
    } catch (e) {
      debugPrint('Falha ao coletar metadados do dispositivo: $e');
      return DeviceMetadata.empty;
    }
  }
}
