import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class TugasTopTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const TugasTopTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;
          
          return Stack(
            children: [
              // Animated bottom indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                left: currentIndex * tabWidth,
                bottom: 0,
                child: Container(
                  width: tabWidth,
                  height: 3,
                  color: AppColors.primaryColor,
                ),
              ),
              
              // Tab buttons
              Row(
                children: [
                  _buildTab('Tracking', 0, tabWidth),
                  _buildTab('Assignment', 1, tabWidth),
                  _buildTab('History', 2, tabWidth),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index, double width) {
    final isActive = currentIndex == index;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.primaryColor : Colors.black54,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}