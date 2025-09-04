import 'package:flutter/material.dart';
import 'package:midi_location/features/error_screens/error_base_screen.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';

class AccessDeniedScreen extends StatelessWidget {
  static const String route = '/access-denied';
  const AccessDeniedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBaseScreen(
      title: 'Access Denied',
      description: 'You don\'t have permission to view this page.',
      imagePath: 'assets/icons/access_denied.svg',
      buttonText: 'Log In',
      onButtonPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.route,
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
