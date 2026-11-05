import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/firmware/data/controller_firmware_model.dart';

void main() {
  group('compareFirmwareVersions', () {
    test('compares segment by segment numerically', () {
      expect(compareFirmwareVersions('1.10.0', '1.9.3'), 1);
      expect(compareFirmwareVersions('1.2.0', '1.10.0'), -1);
      expect(compareFirmwareVersions('2', '1.99.99'), 1);
    });

    test('missing segments count as zero', () {
      expect(compareFirmwareVersions('1.0', '1.0.0'), 0);
      expect(compareFirmwareVersions('1.0.0', '1'), 0);
    });

    test('non-numeric segments count as zero', () {
      expect(compareFirmwareVersions('1.x.0', '1.0.0'), 0);
    });
  });

  group('otaErrorMessage', () {
    test('explains a rollback', () {
      expect(otaErrorMessage('rolled_back'), contains('voltou sozinha'));
    });

    test('groups integrity failures', () {
      final msg = otaErrorMessage('sha256_mismatch');
      expect(otaErrorMessage('size_mismatch'), msg);
      expect(otaErrorMessage('download_incomplete'), msg);
      expect(msg, contains('Nada foi instalado'));
    });

    test('irrigating, timeout and unknown codes have messages', () {
      expect(otaErrorMessage('irrigating'), contains('irrigando'));
      expect(otaErrorMessage('timeout'), contains('não respondeu'));
      expect(otaErrorMessage(null), contains('versão anterior'));
      expect(otaErrorMessage('whatever'), otaErrorMessage(null));
    });
  });

  group('ControllerFirmwareModel.fromJson', () {
    test('parses a full payload', () {
      final m = ControllerFirmwareModel.fromJson({
        'controller_uuid': 'abc',
        'current_version': '1.0.0',
        'latest_version': '1.1.0',
        'release_notes': 'Correções',
        'update_available': true,
        'auto_update': true,
        'ota_status': 'DOWNLOADING',
        'ota_target_version': '1.1.0',
        'ota_error': null,
        'ota_updated_at': '2026-11-04T21:00:00Z',
        'blocked_reason': 'IN_PROGRESS',
      });

      expect(m.controllerUuid, 'abc');
      expect(m.currentVersion, '1.0.0');
      expect(m.latestVersion, '1.1.0');
      expect(m.releaseNotes, 'Correções');
      expect(m.updateAvailable, isTrue);
      expect(m.autoUpdate, isTrue);
      expect(m.otaStatus, 'DOWNLOADING');
      expect(m.otaTargetVersion, '1.1.0');
      expect(m.otaError, isNull);
      expect(m.otaUpdatedAt, isNotNull);
      expect(m.inProgress, isTrue);
    });

    test('tolerates nulls and missing fields', () {
      final m = ControllerFirmwareModel.fromJson({'controller_uuid': 'x'});
      expect(m.currentVersion, '');
      expect(m.latestVersion, isNull);
      expect(m.updateAvailable, isFalse);
      expect(m.autoUpdate, isFalse);
      expect(m.otaUpdatedAt, isNull);
      expect(m.inProgress, isFalse);
    });
  });
}
