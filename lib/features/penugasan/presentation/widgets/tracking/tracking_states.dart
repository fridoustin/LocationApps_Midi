import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class TrackingLoadingWidget extends StatelessWidget {
  const TrackingLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }
}

class TrackingLoadingOverlay extends StatelessWidget {
  const TrackingLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }
}

class TrackingErrorWidget extends StatelessWidget {
  final String error;

  const TrackingErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text('Terjadi Kesalahan'),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}