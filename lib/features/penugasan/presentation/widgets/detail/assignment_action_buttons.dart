import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';

class AssignmentActionButtons extends StatelessWidget {
  final AssignmentType assignmentType;
  final bool allActivitiesCompleted;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback? onExternalOk; 
  final VoidCallback? onExternalNok;

  const AssignmentActionButtons({
    super.key,
    required this.assignmentType,
    required this.allActivitiesCompleted,
    required this.onComplete,
    required this.onCancel,
    this.onExternalOk,
    this.onExternalNok,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (allActivitiesCompleted) ...[
          if (assignmentType == AssignmentType.externalCheck) 
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onExternalNok,
                    icon: const Icon(Icons.close),
                    label: const Text('Lokasi NOK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onExternalOk,
                    icon: const Icon(Icons.check),
                    label: const Text('Lokasi OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            )
          
          else 
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