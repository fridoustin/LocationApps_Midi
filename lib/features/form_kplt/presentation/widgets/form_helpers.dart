// lib/features/form_kplt/presentation/widgets/form_helpers.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// WIDGET UNTUK DROPDOWN
class CustomDropdownFormField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hint;
  final ValueChanged<String?> onChanged;

  const CustomDropdownFormField(
      {super.key,
      required this.label,
      this.value,
      required this.items,
      required this.onChanged,
      this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        hint: Text(hint ?? 'Pilih...'),
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}

// WIDGET UNTUK INPUT ANGKA
class CustomNumberTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? suffixText;

  const CustomNumberTextFormField({
    super.key,
    required this.label,
    required this.onChanged,
    required this.controller,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: suffixText,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

// WIDGET UNTUK UPLOAD FILE
class FileUploadWidget extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback onTap;

  const FileUploadWidget(
      {super.key,
      required this.label,
      this.fileName,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fileName ?? 'Pilih file...',
                  style: TextStyle(
                      color: fileName != null ? Colors.black : Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.upload_file_rounded, color: Colors.grey[700]),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function untuk file picker
Future<void> pickFile(
    void Function(String fieldName, File file) onFilePicked,
    String fieldName) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null && result.files.single.path != null) {
    File file = File(result.files.single.path!);
    onFilePicked(fieldName, file);
  }
}