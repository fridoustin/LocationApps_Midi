// lib/core/widgets/custom_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/profile/domain/entities/profile.dart';

enum TopBarType { home, general , profile}

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final TopBarType type;
  final String? branchName;
  final String? title;
  final Widget? leadingWidget;
  final VoidCallback? onNotificationTap;
  final bool showNotificationButton;
  final Profile? profileData;

  const CustomTopBar({
    super.key,
    required this.type,
    this.branchName,
    this.title,
    this.leadingWidget,
    this.onNotificationTap,
    this.showNotificationButton = true,
    this.profileData
  });

  factory CustomTopBar.home({
    required String branchName,
    VoidCallback? onNotificationTap,
  }) {
    return CustomTopBar(
      type: TopBarType.home,
      branchName: branchName,
      onNotificationTap: onNotificationTap,
    );
  }

  factory CustomTopBar.general({
    required String title,
    Widget? leadingWidget,
    bool showNotificationButton = true,
  }) {
    return CustomTopBar(
        type: TopBarType.general,
        title: title,
        leadingWidget: leadingWidget,
        showNotificationButton: showNotificationButton);
  }

  factory CustomTopBar.profile({
    required String title,
    required Profile profileData,
    VoidCallback? onNotificationTap,
  }) {
    return CustomTopBar(
      type: TopBarType.profile,
      title: title,
      profileData: profileData,
      onNotificationTap: onNotificationTap,
      showNotificationButton: true, // Asumsi tombol notifikasi selalu ada di profil
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (type == TopBarType.home)
          _buildHomeTopBar(context)
        else if (type == TopBarType.general)
          _buildGeneralTopBar(context)
        else if (type == TopBarType.profile)
          _buildProfileTopBar(context),
        
        if (showNotificationButton)
          Positioned(
            top: MediaQuery.of(context).padding.top + 42,
            right: 24,
            child: GestureDetector(
              onTap: onNotificationTap,
              child: SvgPicture.asset(
                'assets/icons/notifikasi.svg',
                width: 32,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHomeTopBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/pic/alfamidilogohd.png',
                width: 200,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/location.svg',
                    width: 20,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    branchName ?? 'Memuat...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTopBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: leadingWidget,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      toolbarHeight: preferredSize.height,
    );
  }

  Widget _buildProfileTopBar(BuildContext context) {
    final bool hasAvatar = profileData?.avatarUrl != null && profileData!.avatarUrl!.isNotEmpty;
    return AppBar(
      centerTitle: true,
      toolbarHeight: 120,
      title: Text(
        title ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100), // Beri ruang untuk tombol notifikasi
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: hasAvatar ? NetworkImage(profileData!.avatarUrl!) : null,
              child: !hasAvatar
                    ? const Icon(Icons.person, size: 60, color: AppColors.primaryColor)
                    : null,
            ),
            const SizedBox(height: 12),
            Text(
              profileData?.name ?? 'Memuat Nama...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              profileData?.position ?? 'Memuat Posisi...',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/location.svg', 
                  // ignore: deprecated_member_use
                  color: AppColors.cardColor,
                  width: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  profileData?.branch ?? 'Memuat Cabang...',
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    if (type == TopBarType.home) {
      return const Size.fromHeight(160);
    } if (type == TopBarType.profile) {
      return const Size.fromHeight(340);
    } else {
      return const Size.fromHeight(120);
    }
  }
}