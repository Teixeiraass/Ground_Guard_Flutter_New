import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_provider.dart';

class NewDeviceQrcode extends ConsumerWidget {
  const NewDeviceQrcode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false, // BLOQUEIO TOTAL DO BOTÃO VOLTAR
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurar Dispositivo'),
          automaticallyImplyLeading: false, // Remove a seta de voltar
          actions: [
            // ÚNICA ESCAPATÓRIA: LOGOUT
            TextButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sair', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner_rounded, size: 100, color: Color(0xFF274029)),
                const SizedBox(height: 24),
                const Text(
                  'Nenhum dispositivo encontrado!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para continuar usando o Ground Guard, você precisa cadastrar seu primeiro sensor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addDeviceQrCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF274029),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Escanear QR Code', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
