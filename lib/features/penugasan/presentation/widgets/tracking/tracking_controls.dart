import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';

class TrackingTopControls extends StatelessWidget {
  final List<Assignment> assignments;

  const TrackingTopControls({
    super.key,
    required this.assignments,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          const Expanded(child: WeekBadge()),
          const SizedBox(width: 12),
          if (assignments.isNotEmpty)
            AssignmentCountBadge(count: assignments.length),
        ],
      ),
    );
  }
}

class WeekBadge extends StatelessWidget {
  const WeekBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final fmt = DateFormat('dd MMM');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 18,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '${fmt.format(monday)} - ${fmt.format(sunday)}',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentCountBadge extends StatelessWidget {
  final int count;

  const AssignmentCountBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.assignment, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingSideControls extends StatelessWidget {
  final int assignmentCount;
  final VoidCallback onLocationPressed;
  final VoidCallback onListPressed;

  const TrackingSideControls({
    super.key,
    required this.assignmentCount,
    required this.onLocationPressed,
    required this.onListPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 80,
      child: Column(
        children: [
          TrackingFloatingButton(
            icon: Icons.my_location,
            onPressed: onLocationPressed,
            tooltip: 'Ke Lokasi Saya',
          ),
          const SizedBox(height: 12),
          if (assignmentCount > 0)
            TrackingFloatingButton(
              icon: Icons.list_alt,
              onPressed: onListPressed,
              tooltip: 'Lihat Semua Tugas',
              badge: assignmentCount.toString(),
            ),
        ],
      ),
    );
  }
}

class TrackingFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final String? badge;

  const TrackingFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: AppColors.primaryColor, size: 24),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}