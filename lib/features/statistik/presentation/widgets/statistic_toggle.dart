// lib/features/statistik/presentation/widgets/statistic_toggle.dart

import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/presentation/providers/statistic_provider.dart';

class StatisticToggle extends StatelessWidget {
  final ChartType currentType;
  final Function(ChartType) onUlokPressed;
  final Function(ChartType) onKpltPressed;

  const StatisticToggle({
    super.key,
    required this.currentType,
    required this.onUlokPressed,
    required this.onKpltPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CustomToggleChip(
            label: "ULOK",
            isSelected: currentType == ChartType.ulok,
            onTap: () => onUlokPressed(ChartType.ulok),
          ),
          _CustomToggleChip(
            label: "KPLT",
            isSelected: currentType == ChartType.kplt,
            onTap: () => onKpltPressed(ChartType.kplt),
          ),
        ],
      ),
    );
  }
}

class _CustomToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:
                  isSelected ? Colors.white : AppColors.black.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
