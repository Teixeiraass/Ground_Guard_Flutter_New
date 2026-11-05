import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/alerts/presentation/providers/notifications_provider.dart';
import '../routes/app_routes.dart';
import '../routes/navigator_key.dart';

/// Registra o device para push notifications (FCM) e mantém o token
/// atualizado no backend.
///
/// IMPORTANTE: este serviço só funciona depois que `Firebase.initializeApp()`
/// roda com sucesso em main.dart — o que por sua vez exige um Firebase
/// Project real configurado (google-services.json/GoogleService-Info.plist
/// de verdade, não os arquivos de OAuth do Google Sign-In que estão no
/// projeto hoje). Ver nota no plano/PR sobre os 3 passos manuais pendentes.
class PushNotificationService {
  final Ref _ref;

  PushNotificationService(this._ref);

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    messaging.onTokenRefresh.listen(_registerToken);

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
    });
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _ref
          .read(notificationsRepositoryProvider)
          .registerPushToken(token, platform);
    } catch (e) {
      debugPrint('Falha ao registrar push token: $e');
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(ref),
);
