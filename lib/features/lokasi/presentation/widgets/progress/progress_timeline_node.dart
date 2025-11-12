// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class ProgressTimelineNode extends StatelessWidget {
  final String label;
  final String stepKey;
  final IconData iconData;
  final bool isCompleted;
  final bool isActive;
  final bool isSelected;
  final VoidCallback onTap;

  const ProgressTimelineNode({
    super.key,
    required this.label,
    required this.stepKey,
    required this.iconData,
    required this.isCompleted,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData displayIcon;

    if (isCompleted) {
      backgroundColor = AppColors.successColor;
      iconColor = Colors.white;
      displayIcon = Icons.check_circle;
    } else if (isActive) {
      backgroundColor = Colors.orange;
      iconColor = Colors.white;
      displayIcon = iconData;
    } else {
      backgroundColor = Colors.grey[300]!;
      iconColor = Colors.grey[600]!;
      displayIcon = iconData;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 1)
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                displayIcon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}