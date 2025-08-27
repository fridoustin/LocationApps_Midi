import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constant/color.dart';

class NavigationBarItemWidget extends StatelessWidget {
  final int index;
  final String iconAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationBarItemWidget({
    super.key,
    required this.index,
    required this.iconAsset,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: !isSelected ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            SvgPicture.asset(
              iconAsset,
              semanticsLabel: label,
              width: 24,
              height: 24,
              colorFilter: isSelected
                ? const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn)
                : const ColorFilter.mode(AppColors.iconColor, BlendMode.srcIn)
            ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primaryColor : AppColors.iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}