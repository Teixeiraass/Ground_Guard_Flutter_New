import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/io.dart';
import '../util/api_config.dart';
import '../storage/secure_storage_service.dart';
import 'websocket_message.dart';

enum WebSocketStatus { connecting, connected, disconnected }

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  
  final StreamController<WebSocketStatus> _statusController =
      StreamController<WebSocketStatus>.broadcast();
  
  bool _isConnecting = false;
  bool _shouldReconnect = false;
  Timer? _reconnectTimer;

  Stream<WebSocketMessage> get messages => _messageController.stream;
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  Future<void> connect() async {
    // Se já estiver conectando ou já tiver um canal ativo, ignora
    if (_isConnecting || _channel != null) {
      return;
    }

    _isConnecting = true;
    _shouldReconnect = true;
    _statusController.add(WebSocketStatus.connecting);
    
    // Cancela timer de reconexão se existir (evita spam)
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      final token = await SecureStorageService.getAccessToken();
      if (token == null) {
        debugPrint('WebSocket: Erro - Token não encontrado');
        _isConnecting = false;
        _statusController.add(WebSocketStatus.disconnected);
        return;
      }

      final baseUrl = ApiConfig.baseUrl.replaceAll('http', 'ws');
      final wsUrl = Uri.parse('$baseUrl/ws');

      debugPrint('WebSocket: Conectando em $wsUrl');

      if (kIsWeb) {
        _channel = WebSocketChannel.connect(wsUrl);
      } else {
        _channel = IOWebSocketChannel.connect(
          wsUrl,
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }

      // Aguarda handshake
      await _channel!.ready;

      _channel!.stream.listen(
        (data) {
          _onMessage(data);
        },
        onDone: () {
          debugPrint('WebSocket fechado');
          _cleanupAndReconnect();
        },
        onError: (error) {
          debugPrint('WebSocket erro no stream: $error');
          _cleanupAndReconnect();
        },
      );

      debugPrint('WebSocket conectado com sucesso');
      _statusController.add(WebSocketStatus.connected);
    } catch (e) {
      debugPrint('WebSocket falha na conexão: $e');
      _cleanupAndReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _cleanupAndReconnect() {
    _channel = null;
    _statusController.add(WebSocketStatus.disconnected);
    _reconnect();
  }

  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data);
      final message = WebSocketMessage.fromJson(json);
      _messageController.add(message);
    } catch (e) {
      debugPrint('Erro ao processar mensagem WebSocket: $e');
    }
  }

  void _reconnect() {
    if (!_shouldReconnect || _isConnecting || (_reconnectTimer?.isActive ?? false)) return;

    _reconnectTimer?.cancel();
    debugPrint('Reconectando em 5 segundos...');
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    debugPrint('WebSocket: Desconectando manual...');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    _isConnecting = false;
    _statusController.add(WebSocketStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}
