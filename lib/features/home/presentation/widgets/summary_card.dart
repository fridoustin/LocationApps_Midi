// lib/features/home/presentation/widgets/summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';

enum SummaryCardStyle { solid, outlined }

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;
  final SummaryCardStyle style;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.style = SummaryCardStyle.solid,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSolid = style == SummaryCardStyle.solid;
    const Duration animationDuration = Duration(milliseconds: 300);
    const Curve animationCurve = Curves.easeInOut;

    final Color backgroundColor =
        isSolid ? AppColors.secondaryColor : AppColors.cardColor;
    final Color textColor = isSolid ? Colors.white : AppColors.secondaryColor;

    final Color iconBackgroundColor =
        isSolid ? Colors.white : AppColors.secondaryColor;
    final Color iconColor = isSolid ? AppColors.secondaryColor : Colors.white;

    final Border border =
        isSolid
            ? Border.all(color: Colors.transparent, width: 1.5)
            : Border.all(color: AppColors.secondaryColor, width: 1.5);

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AnimatedContainer(
              duration: animationDuration,
              curve: animationCurve,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  child: icon,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: animationDuration,
              curve: animationCurve,
              style: TextStyle(color: textColor, fontFamily: 'Poppins'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
