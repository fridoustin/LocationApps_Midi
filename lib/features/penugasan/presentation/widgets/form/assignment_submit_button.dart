import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class AssignmentSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isEditMode;
  final VoidCallback onPressed;

  const AssignmentSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.isEditMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSubmitting ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.6),
      ),
      child: isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              isEditMode ? 'Update Penugasan' : 'Buat & Selesaikan Penugasan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}