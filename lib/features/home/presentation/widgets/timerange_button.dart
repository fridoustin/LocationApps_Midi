import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class AnimatedToggleSwitch extends StatelessWidget {
  final bool isMonthSelected;
  final VoidCallback onMonthTap;
  final VoidCallback onYearTap;

  const AnimatedToggleSwitch({
    super.key,
    required this.isMonthSelected,
    required this.onMonthTap,
    required this.onYearTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 200, // Atur lebar sesuai kebutuhan
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Indikator merah yang bergeser
          AnimatedAlign(
            alignment: isMonthSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          // Teks di atas indikator
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onMonthTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Month',
                      style: TextStyle(
                        fontSize: 14,
                        color: isMonthSelected ? Colors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onYearTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Year',
                      style: TextStyle(
                        fontSize: 14,
                        color: !isMonthSelected ? Colors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
