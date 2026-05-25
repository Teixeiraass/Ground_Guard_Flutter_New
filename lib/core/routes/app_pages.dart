import 'package:flutter/material.dart';
import 'package:ground_guard_app/core/routes/route_guard.dart';
import 'package:ground_guard_app/features/auth/presentation/pages/login_page.dart';
import 'package:ground_guard_app/features/auth/presentation/pages/register_page.dart';
import 'package:ground_guard_app/features/home/home_page.dart';
import 'package:ground_guard_app/features/navigation/main_navigation_page.dart';
import 'package:ground_guard_app/features/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    if (!RouteGuard.canAccess(settings.name!)) {
      return _fadeRoute(
        const Scaffold(
          body: Center(
            child: Text('Acesso negado'),
          ),
        ),
      );
    }

    switch (settings.name) {
      case AppRoutes.login:
        return _slideRoute(const LoginPage());

      case AppRoutes.register:
        return _slideRoute(const RegisterPage());

      case AppRoutes.home:
        return _slideRoute(const HomePage());

      case AppRoutes.main:
        return _slideRoute(const MainNavigationPage());

      case AppRoutes.splash:
      default:
        return _fadeRoute(const SplashPage());
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      opaque: true,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.08, 0);
        const end = Offset.zero;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  static PageRouteBuilder _noAnimationRoute(Widget page) {
    return PageRouteBuilder(
      opaque: true,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}