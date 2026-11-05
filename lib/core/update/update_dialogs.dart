import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_version_service.dart';

/// Diálogo bloqueante: sem botão de fechar, sem "agora não". Só fecha quando
/// o usuário sai do app pra atualizar (e volta numa versão nova, que passa
/// a checagem na próxima abertura).
Future<void> showUpdateRequiredDialog(
  BuildContext context,
  AppVersionService service,
  String storeUrl,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        icon: const Icon(
          Icons.system_update_rounded,
          color: AppColors.primary,
          size: 36,
        ),
        title: const Text('Atualização necessária'),
        content: const Text(
          'Uma nova versão do Ground Guard é obrigatória para continuar usando o app. '
          'Atualize para ter acesso às últimas melhorias e correções.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => service.openStore(storeUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Atualizar agora',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Diálogo não-bloqueante: avisa que tem versão nova, mas deixa continuar.
Future<void> showUpdateAvailableDialog(
  BuildContext context,
  AppVersionService service,
  String storeUrl,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.new_releases_outlined,
        color: AppColors.primary,
        size: 36,
      ),
      title: const Text('Nova versão disponível'),
      content: const Text(
        'Uma nova versão do Ground Guard já está disponível, com melhorias e correções.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Agora não'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            service.openStore(storeUrl);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Atualizar'),
        ),
      ],
    ),
  );
}
