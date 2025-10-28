// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/auth_gate.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/profile/presentation/widgets/InfoCard/info_card.dart';
import 'package:midi_location/features/profile/presentation/widgets/supportCard/support_card.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';
import 'package:midi_location/core/widgets/topbar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  static const String route = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: profileAsync.when(
        data:
            (profile) => CustomTopBar.profile(
              title: 'Profile',
              profileData: profile, 
            ),
        loading:
            () => CustomTopBar.profile(title: 'Memuat...', profileData: null),
        error:
            (err, stack) =>
                CustomTopBar.profile(title: 'Error', profileData: null),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Gagal memuat data profile.'),
                      ),
                    );
                  }
                  // ---
                  return InfoCard(profileData: profile);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) =>
                        const Center(child: Text('Gagal memuat informasi.')),
              ),
              const SizedBox(height: 15),
              const SupportCard(),
              const SizedBox(height: 18),
              _buildLogoutButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        _showLogoutConfirmationDialog(context, ref);
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

  void _showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Anda yakin ingin keluar?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: AppColors.black,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ).copyWith(
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>((
                                  Set<MaterialState> states,
                                ) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.black.withOpacity(0.12);
                                  }
                                  return null;
                                }),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text(
                            'Tidak',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      SizedBox(
                        width: 90,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ).copyWith(
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.black.withOpacity(0.12);
                                  }
                                  return null;
                                }),
                          ),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            try {
                              await ref.read(authRepositoryProvider).signOut();

                              ref.invalidate(authStateProvider);
                              ref.invalidate(userProfileProvider);
                              ref.invalidate(dashboardStatsProvider);
                              ref.invalidate(ulokListProvider);
                              ref.invalidate(notificationListProvider);
                              ref.invalidate(ulokTabProvider);
                              ref.invalidate(kpltNeedInputProvider);
                              ref.invalidate(kpltInProgressProvider);
                              ref.invalidate(kpltHistoryProvider);

                              if (!context.mounted) return;

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const AuthGate(),
                                ),
                                (route) => false,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Logout gagal: ${e.toString()}",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Ya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
