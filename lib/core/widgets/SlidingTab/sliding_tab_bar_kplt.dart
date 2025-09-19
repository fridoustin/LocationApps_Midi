import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class SlidingTabBarKplt extends StatefulWidget {
  final TabController controller;

  const SlidingTabBarKplt({
    super.key,
    required this.controller,
  });

  @override
  State<SlidingTabBarKplt> createState() => _SlidingTabBarKpltState();
}

class _SlidingTabBarKpltState extends State<SlidingTabBarKplt> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
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
            final isRecentActive = widget.controller.index == 0;

            return Stack(
              children: [
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
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.controller.animateTo(0),
                        behavior: HitTestBehavior.opaque,
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
                        onTap: () => widget.controller.animateTo(1),
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