import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/components/app_loader.dart';
import 'package:ground_guard_app/core/services/app_initializer.dart';
import '../../core/routes/app_routes.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../auth/presentation/providers/auth_state.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double progress = 0.0;
  String label = '';

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // 1. Inicialização visual
    await AppInitializer.initialize((value, text) {
      if (mounted) {
        setState(() {
          progress = value;
          label = text;
        });
      }
    });

    if (!mounted) return;

    // 2. Garante que o AuthProvider terminou de checar o token e dispositivos
    await ref.read(authProvider.notifier).checkAuth();

    final authStatus = ref.read(authProvider).status;

    // 3. Decisão de rota final
    if (authStatus == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (authStatus == AuthStatus.authenticatedNoDevices) {
      Navigator.pushReplacementNamed(context, AppRoutes.qrCodeDevice);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: AppLoader(
                      progress: progress,
                      label: label,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
