import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ground_guard_app/core/routes/route_guard.dart';
import 'package:ground_guard_app/features/auth/presentation/pages/login_page.dart';
import 'package:ground_guard_app/features/auth/presentation/pages/register_page.dart';
import 'package:ground_guard_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ground_guard_app/features/devices/presentation/pages/add_device_qrcode_page.dart';
import 'package:ground_guard_app/features/devices/presentation/pages/devices_list_page.dart';
import 'package:ground_guard_app/features/devices/presentation/pages/new_device_qrcode.dart';
import 'package:ground_guard_app/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:ground_guard_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:ground_guard_app/features/alerts/presentation/pages/notifications_page.dart';
import 'package:ground_guard_app/features/profile/presentation/pages/irrigation_preferences_page.dart';
import 'package:ground_guard_app/features/support/presentation/pages/support_page.dart';
import 'package:ground_guard_app/features/support/presentation/pages/terms_and_services_page.dart';
import 'package:ground_guard_app/features/splash/splash_page.dart';
import 'package:ground_guard_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'app_routes.dart';

class AppPages {
  static Route<dynamic> generateRoute(RouteSettings settings, AuthStatus status) {
    if (!RouteGuard.canAccess(settings.name ?? '', status)) {
      return _fadeRoute(
        const Scaffold(
          body: Center(
            child: Text('Acesso negado. Cadastre um dispositivo.'),
          ),
        ),
      );
    }

    switch (settings.name) {
      case AppRoutes.login:
        return _slideRoute(const LoginPage(), settings);

      case AppRoutes.register:
        return _slideRoute(const RegisterPage(), settings);

      case AppRoutes.main:
        return _slideRoute(const MainNavigationPage(), settings);

      case AppRoutes.qrCodeDevice:
        return _slideRoute(const NewDeviceQrcode(), settings);

      case AppRoutes.addDeviceQrCode:
        return _slideRoute(const AddDeviceQrCodePage(), settings);

      case AppRoutes.devicesList:
        return _slideRoute(const DevicesListPage(), settings);

      case AppRoutes.onboarding:
        return _slideRoute(const OnboardingPage(), settings);

      case AppRoutes.editProfile:
        return _slideRoute(const EditProfilePage(), settings);

      case AppRoutes.irrigationPreferences:
        return _slideRoute(const IrrigationPreferencesPage(), settings);

      case AppRoutes.notifications:
        return _slideRoute(const NotificationsPage(), settings);

      case AppRoutes.support:
        return _slideRoute(const SupportPage(), settings);

      case AppRoutes.termsAndServices:
        return _slideRoute(const TermsAndServicesPage(), settings);

      case AppRoutes.splash:
      default:
        return _fadeRoute(const SplashPage());
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    );
  }

  static Route<dynamic> _slideRoute(Widget page, RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
