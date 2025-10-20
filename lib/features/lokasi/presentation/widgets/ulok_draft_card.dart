import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';

class UlokDraftCardNew extends StatelessWidget {
  final UlokFormState draft;
  final VoidCallback onTap;
  final VoidCallback onContinue;
  final VoidCallback onDelete;

  const UlokDraftCardNew({
    super.key,
    required this.draft,
    required this.onTap,
    required this.onContinue,
    required this.onDelete,
  });

  String _formatLastEdited() {
    if (draft.lastEdited == null) return 'Draft tersimpan';
    
    final now = DateTime.now();
    final edited = draft.lastEdited!;
    final difference = now.difference(edited);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final day = edited.day.toString().padLeft(2, '0');
      final month = edited.month.toString().padLeft(2, '0');
      return '$day/$month/${edited.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaDraft = draft.namaUlok ?? '';
    final alamatDraft = draft.alamat ?? '';
    final lastEditedText = _formatLastEdited();
    
    const double outerRadius = 14.0;
    const double innerRadius = 12.0; 
    const double highlightWidth = 5.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      clipBehavior: Clip.hardEdge, 
      child: Padding(
        padding: const EdgeInsets.only(left: highlightWidth), 
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(innerRadius), 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                namaDraft.isEmpty ? 'Tanpa Nama' : namaDraft,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 10),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alamatDraft.isEmpty ? '(Alamat belum diisi)' : alamatDraft,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last edited: $lastEditedText',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lanjutkan Ulok',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete button
                  Material(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}