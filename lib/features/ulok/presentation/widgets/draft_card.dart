import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form_state.dart';

class UlokDraftCard extends StatelessWidget {
  final UlokFormState draft;
  final VoidCallback onTap;
  final VoidCallback onDeletePressed;

  const UlokDraftCard({
    super.key,
    required this.draft,
    required this.onTap,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final namaDraft = draft.namaUlok ?? '';
    final alamatDraft = draft.alamat ?? '';

    final fullAddress = alamatDraft.isEmpty
        ? '(Alamat belum diisi)'
        : alamatDraft;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      namaDraft.isEmpty ? '(Tanpa Nama)' : namaDraft,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onDeletePressed, 
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.primaryColor,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              Text(
                fullAddress,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                  fontStyle: alamatDraft.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          color: AppColors.cardColor,
                          fontWeight: FontWeight.bold,
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