import 'package:flutter/material.dart';
import 'package:midi_location/features/error_screens/error_base_screen.dart';

class Error404Screen extends StatelessWidget {
  static const String route = '/404';
  const Error404Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBaseScreen(
      title: 'Something went wrong',
      description: 'We\'re having issues loading this page.',
      imagePath: 'assets/icons/404.svg',
      buttonText: 'Go Back',
      onButtonPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
