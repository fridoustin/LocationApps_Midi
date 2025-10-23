// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
    final double tabWidth = screenWidth / 4; 

    double getIndicatorPosition() {
      const double indicatorWidth = 38;
      return tabWidth * (currentIndex + 0.5) - indicatorWidth / 2;
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
                  label: "Lokasi",
                  isSelected: currentIndex == 1,
                  onTap: () => onItemTapped?.call(1),
                ),
                NavigationBarItemWidget(
                  index: 2,
                  iconAsset: 'assets/icons/penugasan.svg',
                  label: "Tugas",
                  isSelected: currentIndex == 2,
                  onTap: () => onItemTapped?.call(2),
                ),
                NavigationBarItemWidget(
                  index: 3,
                  iconAsset: 'assets/icons/stats.svg',
                  label: "Statistk",
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
        ],
      ),
    );
  }
}
