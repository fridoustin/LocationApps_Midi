// lib/core/widgets/custom_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';

enum TopBarType { home, general }

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final TopBarType type;
  final String? branchName;
  final String? title;
  final Widget? leadingWidget;
  final VoidCallback? onNotificationTap;
  final bool showNotificationButton;

  const CustomTopBar({
    super.key,
    required this.type,
    this.branchName,
    this.title,
    this.leadingWidget,
    this.onNotificationTap,
    this.showNotificationButton = true,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        (type == TopBarType.home)
            ? _buildHomeTopBar(context)
            : _buildGeneralTopBar(context),
        
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
      elevation: 2,
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
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      toolbarHeight: preferredSize.height,
    );
  }

  @override
  Size get preferredSize {
    if (type == TopBarType.home) {
      return const Size.fromHeight(160);
    } else {
      return const Size.fromHeight(120);
    }
  }
}