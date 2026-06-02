import '../../features/auth/presentation/providers/auth_state.dart';
import 'app_routes.dart';

class RouteGuard {
  static AuthStatus authStatus = AuthStatus.unauthenticated;

  static String initialRoute() {
    if (authStatus == AuthStatus.authenticated) return AppRoutes.main;
    if (authStatus == AuthStatus.authenticatedNoDevices) return AppRoutes.qrCodeDevice;
    return AppRoutes.login;
  }

  static bool canAccess(String route, AuthStatus status) {
    // Permite navegação se estiver carregando para evitar o "Acesso Negado" momentâneo
    if (status == AuthStatus.loading) return true;

    // Se o status for "sem dispositivos", permite apenas telas de setup e auth
    if (status == AuthStatus.authenticatedNoDevices) {
      return route == AppRoutes.qrCodeDevice || 
             route == AppRoutes.addDeviceQrCode || 
             route == AppRoutes.login || 
             route == AppRoutes.register || 
             route == AppRoutes.splash;
    }

    // Bloqueia acesso à Home se não estiver logado
    if (route == AppRoutes.main && status != AuthStatus.authenticated) {
      return false;
    }

    return true;
  }
}
