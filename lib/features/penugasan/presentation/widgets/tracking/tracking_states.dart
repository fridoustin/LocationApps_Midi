import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class TrackingEmptyState extends StatelessWidget {
  const TrackingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 100,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 56,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tidak Ada Penugasan Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saat ini tidak ada penugasan yang perlu Anda kerjakan.\nNikmati waktu Anda! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

// ============================================================================
// ERROR WIDGET
// ============================================================================

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