import 'package:flutter/material.dart';
import 'package:midi_location/features/error_screens/error_base_screen.dart';

class NoConnectionScreen extends StatelessWidget {
  static const String route = '/no-connection';
  const NoConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBaseScreen(
      title: 'No Internet Connection',
      description: 'Check your connection, then refresh the page.',
      imagePath: 'assets/icons/no_connection.svg',
      buttonText: 'Refresh',
      onButtonPressed: () {},
    );
  }
}
