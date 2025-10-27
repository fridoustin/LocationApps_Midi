import 'package:flutter/material.dart';
import 'package:midi_location/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:midi_location/features/lokasi/presentation/pages/all_kplt_screen.dart';
import 'package:midi_location/features/lokasi/presentation/pages/formkplt_screen.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/notification/presentation/pages/notification_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/profile_screen.dart';
import 'package:midi_location/features/error_screens/error_404_screen.dart';
import 'package:midi_location/features/error_screens/access_denied_screen.dart';
import 'package:midi_location/features/error_screens/under_maintenance_screen.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_detail_screen.dart';

Route<dynamic> routeGenerators(RouteSettings settings) {
  switch (settings.name) {
    case HomeScreen.route:
      return _buildPageRoute(const HomeScreen());
    case FormKPLTPage.route:
      return _buildPageRoute(const FormKPLTPage());
    case ProfilePage.route:
      return _buildPageRoute(const ProfilePage());
    case LoginPage.route:
      return _buildPageRoute(const LoginPage());
    case ForgotPasswordPage.route:
      return _buildPageRoute(const ForgotPasswordPage());
    case Error404Screen.route:
      return _buildPageRoute(const Error404Screen());
    case AccessDeniedScreen.route:
      return _buildPageRoute(const AccessDeniedScreen());
    case UnderMaintenanceScreen.route:
      return _buildPageRoute(const UnderMaintenanceScreen());
    case NotificationScreen.route:
      return _buildPageRoute(const NotificationScreen());
    case AllKpltListPage.route:
      final args = settings.arguments as Map<String, dynamic>?;
      final needInput = args?['needInput'] as bool? ?? true;
      return _buildPageRoute(AllKpltListPage(needInput: needInput));
    case UlokDetailPage.route:
      return _buildPageRoute(
        UlokDetailPage(ulok: settings.arguments as UsulanLokasi),
      );

    default:
      return _buildPageRoute(const Error404Screen());
  }
}

PageRoute _buildPageRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
