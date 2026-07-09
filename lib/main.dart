import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_pages.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/core/theme/app_theme.dart';
import 'package:ground_guard_app/core/websocket/websocket_provider.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantém o serviço de WebSocket ativo enquanto o app estiver rodando
    ref.watch(webSocketServiceProvider);

    // Escuta o status de autenticação globalmente
    final authStatus = ref.watch(authProvider.select((state) => state.status));

    return MaterialApp(
      title: 'Ground Guard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) => AppPages.generateRoute(settings, authStatus),
    );
  }
}
