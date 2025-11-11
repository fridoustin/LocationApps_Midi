import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class FormActionButtons extends StatelessWidget {
  final bool isLoading;
  final bool showDraftButton;
  final VoidCallback? onDraftPressed;
  final VoidCallback? onSubmitPressed;
  final String submitLabel;

  const FormActionButtons({
    super.key,
    required this.isLoading,
    this.showDraftButton = true,
    this.onDraftPressed,
    this.onSubmitPressed,
    this.submitLabel = 'Submit',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showDraftButton && onDraftPressed != null) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onDraftPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Draft',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmitPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    submitLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}