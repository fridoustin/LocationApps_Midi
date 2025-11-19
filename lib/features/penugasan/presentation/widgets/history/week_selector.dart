import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';

class WeekRange {
  final DateTime start;
  final DateTime end;
  final String label;

  WeekRange({
    required this.start,
    required this.end,
    required this.label,
  });
}

class WeekRangeHelper {
  static List<WeekRange> getWeekRanges() {
    final List<WeekRange> weeks = [];
    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final weekStart = _getStartOfWeek(now.subtract(Duration(days: i * 7)));
      final weekEnd = weekStart.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      String label;
      if (i == 0) {
        label = 'Minggu Ini';
      } else if (i == 1) {
        label = 'Minggu Lalu';
      } else {
        label =
            '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}';
      }

      weeks.add(WeekRange(start: weekStart, end: weekEnd, label: label));
    }

    return weeks;
  }

  static DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = (date.weekday - 1) % 7;
    final monday = date.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }

  static List<T> filterAssignmentsByWeek<T>(
    List<T> items,
    WeekRange week,
    DateTime Function(T) getDate,
  ) {
    return items.where((item) {
      final date = getDate(item);
      return date.isAfter(week.start) && date.isBefore(week.end);
    }).toList();
  }
}

class WeekSelector extends StatelessWidget {
  final int selectedWeekIndex;
  final Function(int) onWeekChanged;

  const WeekSelector({
    super.key,
    required this.selectedWeekIndex,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = WeekRangeHelper.getWeekRanges();
    final selectedWeek = weeks[selectedWeekIndex];

    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
      child: Row(
        children: [
          // Previous week
          IconButton(
            onPressed: selectedWeekIndex < weeks.length - 1
                ? () => onWeekChanged(selectedWeekIndex + 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: selectedWeekIndex < weeks.length - 1
                ? AppColors.primaryColor
                : Colors.grey,
          ),

          // Week label
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedWeek.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('dd MMM').format(selectedWeek.start)} - ${DateFormat('dd MMM yyyy').format(selectedWeek.end)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next week
          IconButton(
            onPressed: selectedWeekIndex > 0
                ? () => onWeekChanged(selectedWeekIndex - 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: selectedWeekIndex > 0 ? AppColors.primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }
}
