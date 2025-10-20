// lib/core/widgets/custom_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/profile/domain/entities/profile.dart';

enum TopBarType { home, general, profile }

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final TopBarType type;
  final String? title;
  final Widget? leadingWidget;
  final bool showNotificationButton;
  final Profile? profileData;
  final bool hasUnreadNotification;

  const CustomTopBar({
    super.key,
    required this.type,
    this.title,
    this.leadingWidget,
    this.showNotificationButton = true,
    this.profileData,
    this.hasUnreadNotification = false,
  });

  factory CustomTopBar.home({
    bool hasUnreadNotification = false,
    Profile? profileData,
  }) {
    return CustomTopBar(
      type: TopBarType.home,
      profileData: profileData,
      hasUnreadNotification: hasUnreadNotification,
    );
  }

  factory CustomTopBar.general({
    required String title,
    Widget? leadingWidget,
    bool showNotificationButton = true,
    bool hasUnreadNotification = false,
    Profile? profileData,
  }) {
    return CustomTopBar(
      type: TopBarType.general,
      title: title,
      leadingWidget: leadingWidget,
      showNotificationButton: showNotificationButton,
      hasUnreadNotification: hasUnreadNotification,
      profileData: profileData,
    );
  }

  factory CustomTopBar.profile({
    required String title,
    required Profile profileData,
    bool hasUnreadNotification = false,
  }) {
    return CustomTopBar(
      type: TopBarType.profile,
      title: title,
      profileData: profileData,
      hasUnreadNotification: hasUnreadNotification,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type == TopBarType.home) {
      return _buildHomeTopBar(context);
    } else if (type == TopBarType.general) {
      return _buildGeneralTopBar(context);
    } else {
      return _buildProfileTopBar(context);
    }
  }

  Widget _buildHomeTopBar(BuildContext context) {
    const double sideControlWidth = 56;
    const double notificationIconSize = 30;
    const double controlHeight = 56;
    const double avatarRadius = 25;

    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: preferredSize.height,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SizedBox(
            height: controlHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: sideControlWidth,
                  child: Center(
                    child: leadingWidget ??
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            backgroundImage: (profileData != null &&
                                    profileData!.avatarUrl != null &&
                                    profileData!.avatarUrl!.isNotEmpty)
                                ? NetworkImage(profileData!.avatarUrl!)
                                : null,
                            child: (profileData == null ||
                                    profileData!.avatarUrl == null ||
                                    profileData!.avatarUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 24)
                                : null,
                          ),
                        ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/pic/logosamping.png',
                      height: 45,
                    ),
                  ),
                ),
                
                SizedBox(
                  width: sideControlWidth,
                  child: Center(
                    child: showNotificationButton
                        ? GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/notification'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/notifikasi.svg',
                                  width: notificationIconSize,
                                ),
                                if (hasUnreadNotification)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTopBar(BuildContext context) {
    const double sideControlWidth = 56;
    const double notificationIconSize = 30;
    const double controlHeight = 56;
    const double avatarRadius = 25;

    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: preferredSize.height,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SizedBox(
            height: controlHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: sideControlWidth,
                  child: Center(
                    child: leadingWidget ??
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            backgroundImage: (profileData != null &&
                                    profileData!.avatarUrl != null &&
                                    profileData!.avatarUrl!.isNotEmpty)
                                ? NetworkImage(profileData!.avatarUrl!)
                                : null,
                            child: (profileData == null ||
                                    profileData!.avatarUrl == null ||
                                    profileData!.avatarUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 24) 
                                : null,
                          ),
                        ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: sideControlWidth,
                  child: Center(
                    child: showNotificationButton
                        ? GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/notification'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/notifikasi.svg',
                                  width: notificationIconSize,
                                ),
                                if (hasUnreadNotification)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTopBar(BuildContext context) {
    final bool hasAvatar = profileData?.avatarUrl != null &&
        profileData!.avatarUrl!.isNotEmpty;
    return AppBar(
      centerTitle: true,
      toolbarHeight: 100,
      title: Text(
        title ?? '',
        style: const TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 85),
            CircleAvatar(
              radius: 65,
              backgroundColor: Colors.white,
              backgroundImage:
                  hasAvatar ? NetworkImage(profileData!.avatarUrl!) : null,
              child: !hasAvatar
                  ? const Icon(Icons.person,
                      size: 60, color: AppColors.primaryColor)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              profileData?.name ?? 'Memuat Nama...',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              profileData?.position ?? 'Memuat Posisi...',
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/location.svg',
                  width: 15,
                  colorFilter: const ColorFilter.mode(
                    AppColors.cardColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  profileData?.branch ?? 'Memuat Cabang...',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
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
      return const Size.fromHeight(75);
    } else if (type == TopBarType.profile) {
      return const Size.fromHeight(330);
    } else {
      return const Size.fromHeight(75);
    }
  }
}
