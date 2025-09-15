import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';

class UlokDraftCard extends StatelessWidget {
  final UlokFormData draft;
  final VoidCallback onTap; // Kita tetap gunakan onTap dari parent

  const UlokDraftCard({
    super.key,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan alamat dari draft, jika kosong tampilkan placeholder
    final fullAddress = draft.alamat.isEmpty
        ? '(Alamat belum diisi)'
        : draft.alamat;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap, // Aksi utama saat card ditekan
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
                      draft.namaUlok.isEmpty ? '(Tanpa Nama)' : draft.namaUlok,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Ikon edit SELALU tampil untuk draft
                  IconButton(
                    onPressed: onTap, // Arahkan juga ke halaman edit
                    icon: SvgPicture.asset(
                      'assets/icons/editulok.svg',
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor, // Warna ikon tetap sama
                        BlendMode.srcIn,
                      ),
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
                  // Tampilkan miring jika alamat masih placeholder
                  fontStyle: draft.alamat.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Status "Draft" dengan warna yang disesuaikan
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
                  // Kita tidak menampilkan tanggal pada draft
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}