import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';

class SlidingTabBar extends StatelessWidget {
  final UlokTab activeTab;
  final Function(UlokTab) onTabChanged;

  const SlidingTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52, // Tinggi kontainer
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;
            final isRecentActive = activeTab == UlokTab.recent;

            return Stack(
              children: [
                // LAPISAN BAWAH: Kotak Merah yang Bergeser
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  left: isRecentActive ? 0 : tabWidth,
                  child: Container(
                    width: tabWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // LAPISAN ATAS: Teks dan Area Tap
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChanged(UlokTab.recent),
                        behavior: HitTestBehavior.opaque, // Agar area kosong bisa di-tap
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isRecentActive ? Colors.white : AppColors.black,
                            ),
                            child: const Text('Recent'),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChanged(UlokTab.history),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !isRecentActive ? Colors.white : AppColors.black,
                            ),
                            child: const Text('History'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}