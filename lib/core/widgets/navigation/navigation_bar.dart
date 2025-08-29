// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'navigation_bar_item.dart';

class NavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onItemTapped;
  final VoidCallback? onCenterButtonTapped;

  const NavigationBarWidget({
    super.key,
    required this.currentIndex,
    this.onItemTapped,
    this.onCenterButtonTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = (screenWidth - 80) / 4; // 80px untuk tombol tengah

    double getIndicatorPosition() {
      const double indicatorWidth = 38;

      if (currentIndex <= 1) {
        // sebelum tombol tengah
        return tabWidth * (currentIndex + 0.5) - indicatorWidth / 2;
      } else {
        // setelah tombol tengah (geser +80)
        return tabWidth * (currentIndex + 0.5) + 80 - indicatorWidth / 2;
      }
    }

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Menu items
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                NavigationBarItemWidget(
                  index: 0,
                  iconAsset: 'assets/icons/home.svg',
                  label: "Home",
                  isSelected: currentIndex == 0,
                  onTap: () => onItemTapped?.call(0),
                ),
                NavigationBarItemWidget(
                  index: 1,
                  iconAsset: 'assets/icons/location.svg',
                  label: "ULok",
                  isSelected: currentIndex == 1,
                  onTap: () => onItemTapped?.call(1),
                ),
                const SizedBox(width: 80), // space for center button
                NavigationBarItemWidget(
                  index: 2,
                  iconAsset: 'assets/icons/map.svg',
                  label: "Form KPLT",
                  isSelected: currentIndex == 2,
                  onTap: () => onItemTapped?.call(2),
                ),
                NavigationBarItemWidget(
                  index: 3,
                  iconAsset: 'assets/icons/profile.svg',
                  label: "Profile",
                  isSelected: currentIndex == 3,
                  onTap: () => onItemTapped?.call(3),
                ),
              ],
            ),
          ),

          // indikator merah
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            top: 0,
            left: getIndicatorPosition(),
            child: Container(
              height: 4,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // tombol tengah
          Positioned(
            top: -30,
            left: screenWidth / 2 - 36,
            child: GestureDetector(
              onTap: onCenterButtonTapped,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/addulok.svg',
                    color: Colors.white,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
