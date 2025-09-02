import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/profile/domain/entities/profile.dart';
import 'package:midi_location/features/profile/presentation/pages/edit_profile_screen.dart';
import 'info_row.dart';

class InfoCard extends StatelessWidget {
  final Profile? profileData;
  const InfoCard({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Lakukan navigasi hanya jika profileData tidak null
                  if (profileData != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          currentProfile: profileData!,
                        ),
                      ),
                    );
                  }
                },
                child: SvgPicture.asset(
                  "assets/icons/editulok.svg",
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoRow(
            iconPath: "assets/icons/email.svg",
            text: profileData?.email ?? '-',
          ),
          const Divider(height: 25),
          InfoRow(
            iconPath: "assets/icons/phone.svg",
            text: profileData?.phone ?? "-",
          ),
        ],
      ),
    );
  }
}
