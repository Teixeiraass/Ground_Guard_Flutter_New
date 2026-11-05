import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/components/app_loader.dart';
import 'package:ground_guard_app/core/services/app_initializer.dart';
import '../../core/routes/app_routes.dart';
import '../../core/update/app_version_service.dart';
import '../../core/update/update_dialogs.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../auth/presentation/providers/auth_state.dart';
import '../user/presentation/providers/user_provider.dart';

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
    // Dispara a checagem de versão em paralelo com a inicialização visual,
    // pra não adicionar latência extra na splash em cima da já existente.
    final versionCheckFuture = ref.read(appVersionServiceProvider).check();

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

    final versionResult = await versionCheckFuture;
    if (versionResult != null) {
      final versionService = ref.read(appVersionServiceProvider);
      if (versionResult.updateRequired) {
        if (mounted) {
          // Não aguarda o diálogo fechar: ele não fecha por design, e não
          // há mais nada pra fazer além de ficar bloqueado aqui.
          showUpdateRequiredDialog(context, versionService, versionResult.storeUrl);
        }
        return;
      }
      if (versionResult.updateAvailable && mounted) {
        await showUpdateAvailableDialog(context, versionService, versionResult.storeUrl);
      }
    }

    if (!mounted) return;

    // 2. Garante que o AuthProvider terminou de checar o token e dispositivos
    await ref.read(authProvider.notifier).checkAuth();

    final authStatus = ref.read(authProvider).status;

    // Se logado, dispara a atualização do perfil em paralelo (sem travar o splash)
    if (authStatus == AuthStatus.authenticated ||
        authStatus == AuthStatus.authenticatedNoDevices) {
      ref.read(userProvider.notifier).fetchUserProfile();
    }

    if (!mounted) return;

    // 3. Decisão de rota final
    if (authStatus == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (authStatus == AuthStatus.authenticatedNoDevices) {
      Navigator.pushReplacementNamed(context, AppRoutes.addControllerBluetooth);
    } else if (authStatus == AuthStatus.error) {
      // Se deu erro (ex: Servidor Offline), permanecemos na splash para mostrar a mensagem
      return;
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Center(child: Image.asset('assets/images/logo.png', width: 120)),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Column(
                children: [
                  if (authState.status == AuthStatus.error) ...[
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.errorMessage ??
                          'Não foi possível conectar ao servidor.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 0;
                          label = 'Tentando conectar...';
                        });
                        _start();
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ] else ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: AppLoader(progress: progress, label: label),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
