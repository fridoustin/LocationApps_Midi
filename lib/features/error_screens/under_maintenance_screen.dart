import 'package:flutter/material.dart';
import 'package:midi_location/features/error_screens/error_base_screen.dart';

class UnderMaintenanceScreen extends StatelessWidget {
  static const String route = '/under-maintenance';
  const UnderMaintenanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBaseScreen(
      title: 'Under Maintenance',
      description:
          'Our services are temporarily unavailable. We expect to be back soon.',
      imagePath: 'assets/icons/under_maintenance.svg',
      buttonText: 'Contact Support',
      onButtonPressed: () {},
      showBackButton: false,
    );
  }
}
