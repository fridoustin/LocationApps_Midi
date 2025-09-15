import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/error_screens/error_base_screen.dart';

class NoConnectionScreen extends StatelessWidget {
  static const String route = '/no-connection';
  final VoidCallback onRefresh;
  final VoidCallback? onGoToOfflineForm;

  const NoConnectionScreen({
    super.key,
    required this.onRefresh,
    this.onGoToOfflineForm,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBaseScreen(
      title: 'Tidak Ada Koneksi Internet',
      description: 'Periksa koneksi Anda, lalu segarkan halaman.',
      imagePath: 'assets/icons/no_connection.svg',
      
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: onRefresh,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: AppColors.primaryColor, 
              side: const BorderSide(color: AppColors.primaryColor, width: 1.5), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Segarkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        if (onGoToOfflineForm != null)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onGoToOfflineForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor, 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Buat ULOK Offline',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}