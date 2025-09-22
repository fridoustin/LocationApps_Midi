import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isRequired;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isRequired = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator ??
                (value) {
                  if (isRequired && (value == null || value.isEmpty)) {
                    return '$label tidak boleh kosong';
                  }
                  return null;
                },
            decoration: InputDecoration(
              hintText: hint ?? 'Masukkan $label',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
