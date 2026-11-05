import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/data/models/controller_device_model.dart';
import '../data/controller_firmware_model.dart';
import 'firmware_provider.dart';

class ControllerFirmwarePage extends ConsumerStatefulWidget {
  final ControllerDeviceModel controller;

  const ControllerFirmwarePage({super.key, required this.controller});

  @override
  ConsumerState<ControllerFirmwarePage> createState() =>
      _ControllerFirmwarePageState();
}

class _ControllerFirmwarePageState
    extends ConsumerState<ControllerFirmwarePage> {
  bool _sending = false;
  bool _savingAuto = false;

  String get _uuid => widget.controller.uuid;

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : null,
      ),
    );
  }

  String _friendlyError(Object e) {
    final text = e.toString().toLowerCase();
    if (text.contains('offline')) return 'A controladora está offline.';
    if (text.contains('irrigating')) {
      return 'A controladora está irrigando. Tente quando a rega terminar.';
    }
    if (text.contains('in progress')) {
      return 'Já existe uma atualização em andamento.';
    }
    if (text.contains('latest firmware')) {
      return 'A controladora já está na versão mais recente.';
    }
    return 'Não foi possível iniciar a atualização: $e';
  }

  Future<void> _confirmUpdate(ControllerFirmwareModel fw) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atualizar para ${fw.latestVersion}?'),
        content: const Text(
          'A controladora vai baixar a nova versão e reiniciar sozinha. '
          'Ela fica offline por cerca de um minuto, e nenhuma rega acontece nesse tempo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _sending = true);
    try {
      await ref.read(firmwareActionsProvider).updateNow(_uuid);
      _snack('Atualização enviada para a controladora.');
    } catch (e) {
      _snack(_friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleAuto(bool enabled) async {
    setState(() => _savingAuto = true);
    try {
      await ref.read(firmwareActionsProvider).setAutoUpdate(_uuid, enabled);
    } catch (e) {
      _snack('Não foi possível salvar a preferência: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingAuto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmwareAsync = ref.watch(controllerFirmwareProvider(_uuid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.controller.name),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(controllerFirmwareProvider(_uuid).future),
        child: firmwareAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar o firmware.\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          data: (fw) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _VersionCard(fw: fw),
              const SizedBox(height: 16),
              _StatusCard(
                fw: fw,
                sending: _sending,
                onUpdate: () => _confirmUpdate(fw),
              ),
              const SizedBox(height: 16),
              _AutoUpdateCard(
                enabled: fw.autoUpdate,
                saving: _savingAuto,
                onChanged: _toggleAuto,
              ),
              const SizedBox(height: 20),
              const _SafetyNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _VersionCard extends StatelessWidget {
  final ControllerFirmwareModel fw;

  const _VersionCard({required this.fw});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFD4E9D5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Versão instalada',
                  style: TextStyle(fontSize: 13, color: AppColors.outline),
                ),
                Text(
                  fw.currentVersion.isEmpty ? '—' : 'v${fw.currentVersion}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ],
            ),
          ),
          if (!fw.updateAvailable && fw.latestVersion != null)
            const _Pill(
              icon: Icons.check_circle_rounded,
              text: 'Atualizada',
              color: Color(0xFF2E7D32),
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final ControllerFirmwareModel fw;
  final bool sending;
  final VoidCallback onUpdate;

  const _StatusCard({
    required this.fw,
    required this.sending,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (fw.inProgress) {
      final downloading = fw.otaStatus == 'DOWNLOADING';
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              downloading
                  ? 'Baixando e instalando v${fw.otaTargetVersion}...'
                  : 'Enviando atualização para a controladora...',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1D3520),
              ),
            ),
            const SizedBox(height: 14),
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceContainer,
            ),
            const SizedBox(height: 12),
            const Text(
              'A controladora vai reiniciar sozinha no final. Você pode sair desta tela, avisaremos quando terminar.',
              style: TextStyle(color: Color(0xFF424840), height: 1.4),
            ),
          ],
        ),
      );
    }

    final lastFailed = fw.otaStatus == 'FAILED';
    final lastSucceeded =
        fw.otaStatus == 'SUCCESS' &&
        fw.otaTargetVersion != null &&
        fw.otaTargetVersion == fw.currentVersion;

    if (!fw.updateAvailable) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fw.latestVersion == null
                  ? 'Nenhuma atualização publicada ainda.'
                  : 'Sua controladora está na versão mais recente.',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3520),
              ),
            ),
            if (lastSucceeded) ...[
              const SizedBox(height: 8),
              Text(
                'Atualizada com sucesso para v${fw.currentVersion}.',
                style: const TextStyle(color: Color(0xFF2E7D32)),
              ),
            ],
          ],
        ),
      );
    }

    final blocked = fw.blockedReason;
    final blockedText = blocked == 'OFFLINE'
        ? 'A controladora precisa estar online para atualizar.'
        : blocked == 'IRRIGATING'
        ? 'Aguarde a rega terminar para atualizar.'
        : null;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.system_update_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nova versão v${fw.latestVersion} disponível',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ),
            ],
          ),
          if ((fw.releaseNotes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              fw.releaseNotes!.trim(),
              style: const TextStyle(color: Color(0xFF424840), height: 1.45),
            ),
          ],
          if (lastFailed) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      otaErrorMessage(fw.otaError),
                      style: const TextStyle(
                        color: AppColors.error,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: blocked != null || sending ? null : onUpdate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(lastFailed ? 'Tentar de novo' : 'Atualizar agora'),
            ),
          ),
          if (blockedText != null) ...[
            const SizedBox(height: 8),
            Text(
              blockedText,
              style: const TextStyle(fontSize: 13, color: AppColors.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _AutoUpdateCard extends StatelessWidget {
  final bool enabled;
  final bool saving;
  final ValueChanged<bool> onChanged;

  const _AutoUpdateCard({
    required this.enabled,
    required this.saving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atualizar automaticamente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1D3520),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Instala novas versões sozinha entre 2h e 5h, nunca durante uma rega.',
                  style: TextStyle(color: Color(0xFF424840), height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          saving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: enabled,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  onChanged: onChanged,
                ),
        ],
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified_user_outlined, size: 18, color: AppColors.outline),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Cada atualização tem a integridade conferida antes de ser instalada. '
            'Se a versão nova não iniciar corretamente, a controladora volta sozinha para a anterior.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.outline,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Pill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
