import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';
import 'package:midi_location/features/profile/presentation/pages/about_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/help_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/notification_screen.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  static const String route = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    void navigateToEditProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => EditProfilePage(
                currentName: profile.name,
                currentEmail: profile.email,
                currentPhone: profile.phone,
                currentPosition: profile.role,
                currentBranch: profile.branch,
              ),
        ),
      );
    }

    void navigateToAboutScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutScreen()),
      );
    }

    void navigateToHelpScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpScreen()),
      );
    }

    void navigateToNotificationScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationScreen()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: statusBarHeight + 20,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          navigateToNotificationScreen();
                        },
                        icon: SvgPicture.asset(
                          "assets/icons/notification.svg",
                          width: 23,
                          height: 23,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset(
                      "assets/icons/avatar.svg",
                      width: 100,
                      height: 100,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.role,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.branch,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(context, ref),
            const SizedBox(height: 16),
            _buildSupportCard(
              context,
              navigateToAboutScreen,
              navigateToHelpScreen,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement logout functionality
                  print("Logout button pressed!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditProfilePage(
                                  currentName: profile.name,
                                  currentEmail: profile.email,
                                  currentPhone: profile.phone,
                                  currentPosition: profile.role,
                                  currentBranch: profile.branch,
                                ),
                          ),
                        ),
                    child: SvgPicture.asset(
                      "assets/icons/edit_profile.svg",
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/email.svg",
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(profile.email)),
                ],
              ),
              const Divider(height: 25),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/phone.svg",
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(profile.phone)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context,
    VoidCallback onAboutTap,
    VoidCallback onHelpTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      "More Info and Support",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onHelpTap,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/help.svg",
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("Help")),
                    SvgPicture.asset(
                      "assets/icons/right_arrow.svg",
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 25),
              GestureDetector(
                onTap: onAboutTap,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/about.svg",
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("About")),
                    SvgPicture.asset(
                      "assets/icons/right_arrow.svg",
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
