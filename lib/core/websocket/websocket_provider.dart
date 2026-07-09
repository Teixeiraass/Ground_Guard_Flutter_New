import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import 'websocket_service.dart';
import 'websocket_message.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  
  // Observa o status de autenticação para conectar/desconectar
  ref.listen(authProvider.select((s) => s.status), (previous, next) {
    if (next == AuthStatus.authenticated || next == AuthStatus.authenticatedNoDevices) {
      service.connect();
    } else if (next == AuthStatus.unauthenticated) {
      service.disconnect();
    }
  });

  // Conexão inicial caso já esteja logado
  final currentStatus = ref.read(authProvider).status;
  if (currentStatus == AuthStatus.authenticated || currentStatus == AuthStatus.authenticatedNoDevices) {
    service.connect();
  }

  ref.onDispose(() => service.dispose());
  return service;
});

final webSocketMessagesProvider = StreamProvider<WebSocketMessage>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.messages;
});

final webSocketStatusProvider = StreamProvider<WebSocketStatus>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.statusStream;
});
