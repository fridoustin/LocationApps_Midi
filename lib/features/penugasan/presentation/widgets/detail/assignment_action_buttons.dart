import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class AssignmentActionButtons extends StatelessWidget {
  final bool allActivitiesCompleted;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const AssignmentActionButtons({
    super.key,
    required this.allActivitiesCompleted,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (allActivitiesCompleted) ...[
          ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle),
            label: const Text('Selesaikan Penugasan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel),
          label: const Text('Batalkan Penugasan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
      ],
    );
  }
}