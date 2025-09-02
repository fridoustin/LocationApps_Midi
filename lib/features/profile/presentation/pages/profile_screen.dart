import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/profile/presentation/widgets/InfoCard/info_card.dart';
import 'package:midi_location/features/profile/presentation/widgets/supportCard/support_card.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  static const String route = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Widget Header (bisa dipisah juga jika makin kompleks)
                const SizedBox(height: 20),
                // Widget Kartu Info
                profileAsync.when(
                  data: (profile) {
                    return InfoCard(profileData: profile);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      const Center(child: Text('Gagal memuat informasi.')),
                ),
                const SizedBox(height: 16),
                // Widget Kartu Bantuan 
                const SupportCard(),
                // Tombol Logout
                _buildLogoutButton(ref),
              ],
            )
          ) 
        ),
      ),
    );
  }
  // Widget untuk Tombol Logout
  Widget _buildLogoutButton(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ElevatedButton(
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.cardColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Logout",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

