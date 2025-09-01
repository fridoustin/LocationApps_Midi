import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isEnabled;
  final TextInputType keyboardType;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isEnabled = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16,
            color: isEnabled ? Colors.black : Colors.grey[600],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
