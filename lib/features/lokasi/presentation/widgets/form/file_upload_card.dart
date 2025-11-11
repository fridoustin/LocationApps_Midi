// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class FileUploadCard extends StatelessWidget {
  final String label;
  final String? fileName;
  final String? existingUrl;
  final VoidCallback onTap;

  const FileUploadCard({
    super.key,
    required this.label,
    this.fileName,
    this.existingUrl,
    required this.onTap,
  });

  bool get _hasFile =>
      (fileName != null && fileName!.isNotEmpty) ||
      (existingUrl != null && existingUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _hasFile
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _hasFile ? Icons.check_circle : Icons.upload_file,
                  color: _hasFile ? AppColors.primaryColor : Colors.grey[600],
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (_hasFile) ...[
                      const SizedBox(height: 4),
                      Text(
                        fileName ?? existingUrl?.split('/').last ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                _hasFile ? Icons.edit : Icons.add_circle_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}