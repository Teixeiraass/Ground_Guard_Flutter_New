class RouteGuard {
  static bool isLogged = false; 

  static String initialRoute() {
    return isLogged ? '/main' : '/login';
  }

  static bool canAccess(String route) {
    if (route == '/home' && !isLogged) {
      return false;
    }
    return true;
  }
}