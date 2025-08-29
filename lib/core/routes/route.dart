import 'package:flutter/material.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/formkplt_screen.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/profile_screen.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_screen.dart';

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
    default:
      throw ('Route not found');
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
