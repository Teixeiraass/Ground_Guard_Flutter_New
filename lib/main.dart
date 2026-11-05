import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ground_guard_app/core/routes/app_pages.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/core/routes/navigator_key.dart';
import 'package:ground_guard_app/core/theme/app_theme.dart';
import 'package:ground_guard_app/core/websocket/websocket_provider.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a barra do sistema para não cortar o app
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantém o serviço de WebSocket ativo enquanto o app estiver rodando
    ref.watch(webSocketServiceProvider);

    // Escuta o status de autenticação globalmente para redirecionar em caso de logout
    ref.listen(authProvider.select((state) => state.status), (previous, next) {
      if (next == AuthStatus.unauthenticated) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    });

    final authStatus = ref.watch(authProvider.select((state) => state.status));

    return MaterialApp(
      title: 'Ground Guard',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) =>
          AppPages.generateRoute(settings, authStatus),
    );
  }
}
