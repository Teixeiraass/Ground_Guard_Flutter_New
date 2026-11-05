class ControllerFirmwareModel {
  final String controllerUuid;
  final String currentVersion;
  final String? latestVersion;
  final String? releaseNotes;
  final bool updateAvailable;
  final bool autoUpdate;
  final String? otaStatus;
  final String? otaTargetVersion;
  final String? otaError;
  final DateTime? otaUpdatedAt;

  /// OFFLINE, IRRIGATING or IN_PROGRESS when "update now" is disabled.
  final String? blockedReason;

  const ControllerFirmwareModel({
    required this.controllerUuid,
    required this.currentVersion,
    required this.updateAvailable,
    required this.autoUpdate,
    this.latestVersion,
    this.releaseNotes,
    this.otaStatus,
    this.otaTargetVersion,
    this.otaError,
    this.otaUpdatedAt,
    this.blockedReason,
  });

  bool get inProgress => blockedReason == 'IN_PROGRESS';

  factory ControllerFirmwareModel.fromJson(Map<String, dynamic> json) {
    String? str(String key) => json[key]?.toString();
    return ControllerFirmwareModel(
      controllerUuid: str('controller_uuid') ?? '',
      currentVersion: str('current_version') ?? '',
      latestVersion: str('latest_version'),
      releaseNotes: str('release_notes'),
      updateAvailable: json['update_available'] == true,
      autoUpdate: json['auto_update'] == true,
      otaStatus: str('ota_status'),
      otaTargetVersion: str('ota_target_version'),
      otaError: str('ota_error'),
      otaUpdatedAt: DateTime.tryParse(str('ota_updated_at') ?? '')?.toLocal(),
      blockedReason: str('blocked_reason'),
    );
  }
}

/// Dotted numeric comparison ("1.10.0" > "1.9.3"), matching the API.
int compareFirmwareVersions(String a, String b) {
  List<int> parts(String v) =>
      v.trim().split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final x = parts(a), y = parts(b);
  for (var i = 0; i < x.length || i < y.length; i++) {
    final xi = i < x.length ? x[i] : 0;
    final yi = i < y.length ? y[i] : 0;
    if (xi != yi) return xi < yi ? -1 : 1;
  }
  return 0;
}

String otaErrorMessage(String? code) {
  switch (code) {
    case 'irrigating':
      return 'A controladora estava irrigando. Tente de novo quando a rega terminar.';
    case 'rolled_back':
      return 'A nova versão não iniciou corretamente, então a controladora voltou sozinha para a versão anterior.';
    case 'sha256_mismatch':
    case 'size_mismatch':
    case 'download_incomplete':
      return 'O download chegou incompleto ou corrompido e foi descartado. Nada foi instalado.';
    case 'download_failed':
    case 'manifest_unavailable':
      return 'A controladora não conseguiu baixar a atualização. Verifique a internet dela.';
    case 'timeout':
      return 'A controladora não respondeu a tempo. Ela pode ter perdido a conexão.';
    case 'publish_failed':
      return 'Não conseguimos falar com a controladora agora.';
    case 'installed_version_mismatch':
    case 'version_mismatch':
      return 'A versão instalada não confere com a publicada. Nosso time foi avisado.';
    case 'no_space':
    case 'flash_write_failed':
      return 'A controladora não conseguiu gravar a atualização.';
    default:
      return 'A atualização não foi concluída. A controladora continua na versão anterior.';
  }
}
