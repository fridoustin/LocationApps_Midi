import 'package:flutter/material.dart';

class FormKPLTPage extends StatelessWidget {
  const FormKPLTPage({super.key});
  static const String route = '/formkplt';

  @override
  Widget build(BuildContext context) {
    return Center(
      child : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Form KPLT Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      )
    );
  }
}