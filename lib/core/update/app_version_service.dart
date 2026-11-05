import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/dio_client.dart';

class AppVersionCheckResult {
  final bool updateRequired;
  final bool updateAvailable;
  final String storeUrl;
  final String latestVersion;

  const AppVersionCheckResult({
    required this.updateRequired,
    required this.updateAvailable,
    required this.storeUrl,
    required this.latestVersion,
  });
}

/// Checa no backend a versão mínima/mais recente do app e compara com a
/// versão instalada. Falha "aberta": se o endpoint não responder (ex:
/// offline), retorna null e o app segue normalmente — essa checagem nunca
/// deve ser o motivo de travar o app por um motivo diferente de versão
/// desatualizada de verdade.
class AppVersionService {
  final Dio _dio;

  AppVersionService(this._dio);

  Future<AppVersionCheckResult?> check() async {
    try {
      final response = await _dio.get('/app-version');
      final data = response.data as Map<String, dynamic>;

      final minimumVersion = (data['minimum_version'] as String?) ?? '0.0.0';
      final latestVersion =
          (data['latest_version'] as String?) ?? minimumVersion;
      final storeUrl = Platform.isIOS
          ? (data['ios_store_url'] as String? ?? '')
          : (data['android_store_url'] as String? ?? '');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final belowMinimum = _compare(currentVersion, minimumVersion) < 0;
      final belowLatest = _compare(currentVersion, latestVersion) < 0;

      return AppVersionCheckResult(
        updateRequired: belowMinimum,
        updateAvailable: !belowMinimum && belowLatest,
        storeUrl: storeUrl,
        latestVersion: latestVersion,
      );
    } catch (e) {
      debugPrint('Falha ao checar versão do app: $e');
      return null;
    }
  }

  Future<void> openStore(String storeUrl) async {
    if (storeUrl.isEmpty) return;
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Compara versões "x.y.z" (semver simplificado, sem pré-release/build).
  /// Retorna negativo se [a] < [b], 0 se igual, positivo se [a] > [b].
  int _compare(String a, String b) {
    final partsA = _parse(a);
    final partsB = _parse(b);
    for (var i = 0; i < 3; i++) {
      final diff = partsA[i].compareTo(partsB[i]);
      if (diff != 0) return diff;
    }
    return 0;
  }

  List<int> _parse(String version) {
    final parts = version.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    return List.generate(3, (i) => i < parts.length ? parts[i] : 0);
  }
}

final appVersionServiceProvider = Provider<AppVersionService>((ref) {
  final dio = ref.watch(dioProvider);
  return AppVersionService(dio);
});
