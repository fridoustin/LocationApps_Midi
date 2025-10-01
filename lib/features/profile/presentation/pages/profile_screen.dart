import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/auth_gate.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profileAsync.when(
                data: (profile) {
                  return InfoCard(profileData: profile);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) =>
                        const Center(child: Text('Gagal memuat informasi.')),
              ),
              const SizedBox(height: 19),
              // Widget Kartu Bantuan
              const SupportCard(),
              // PERUBAHAN DI SINI: Tambahkan SizedBox untuk spasi vertikal
              const SizedBox(height: 20),
              // Tombol Logout
              _buildLogoutButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Tombol Logout
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    // PERUBAHAN DI SINI: Hapus widget Padding
    return ElevatedButton(
      onPressed: () async {
        try {
          await ref.read(authRepositoryProvider).signOut();
          ref.invalidate(profileDataProvider);
          ref.invalidate(dashboardStatsProvider);
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Logout gagal: ${e.toString()}")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.cardColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text(
        "Logout",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
