import 'package:flutter/material.dart';
import 'package:midi_location/features/auth/presentation/pages/update_password_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/formkplt_screen.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/notification/presentation/pages/notification_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/profile_screen.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_screen.dart';
import 'package:midi_location/features/error_screens/error_404_screen.dart';
import 'package:midi_location/features/error_screens/access_denied_screen.dart';
import 'package:midi_location/features/error_screens/under_maintenance_screen.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_detail_screen.dart';

Route<dynamic> routeGenerators(RouteSettings settings) {
  switch (settings.name) {
    case HomePage.route:
      return _buildPageRoute(const HomePage());
    case ULOKPage.route:
      return _buildPageRoute(const ULOKPage());
    case FormKPLTPage.route:
      return _buildPageRoute(const FormKPLTPage());
    case ProfilePage.route:
      return _buildPageRoute(const ProfilePage());
    case LoginPage.route:
      return _buildPageRoute(const LoginPage());
    case UpdatePasswordPage.route:
      return _buildPageRoute(const UpdatePasswordPage());
    case Error404Screen.route:
      return _buildPageRoute(const Error404Screen());
    case AccessDeniedScreen.route:
      return _buildPageRoute(const AccessDeniedScreen());
    case UnderMaintenanceScreen.route:
      return _buildPageRoute(const UnderMaintenanceScreen());
    case NotificationScreen.route:
      return _buildPageRoute(const NotificationScreen());
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
