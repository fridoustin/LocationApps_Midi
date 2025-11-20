// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_eksternal.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_eksternal_provider.dart'; // Import provider yg baru dibuat
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UlokEksternalDetailPage extends ConsumerWidget {
  final String ulokId;
  const UlokEksternalDetailPage({super.key, required this.ulokId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ulokAsyncValue = ref.watch(ulokEksternalDetailProvider(ulokId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Usulan Eksternal',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ulokAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          backgroundColor: AppColors.backgroundColor,
        )),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(ulokEksternalDetailProvider(ulokId)),
        ),
        data: (ulokData) => _UlokEksternalDetailView(
          ulok: ulokData,
          onRefresh: () async {
            ref.invalidate(ulokEksternalDetailProvider(ulokId));
          },
        ),
      ),
    );
  }
}

class _UlokEksternalDetailView extends StatelessWidget {
  final UlokEksternal ulok;
  final Future<void> Function() onRefresh;
  
  const _UlokEksternalDetailView({
    required this.ulok,
    required this.onRefresh,
  });

  Color _getStatusColor() {
    final status = ulok.status.toUpperCase();
    if (status == 'OK') return AppColors.successColor;
    if (status == 'NOK') return Colors.red;
    return AppColors.warningColor;
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        ulok.status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  String _getImageUrl(String filePath) {
    const String bucketName = 'file_storage_eksternal'; 
    return Supabase.instance.client.storage.from(bucketName).getPublicUrl(filePath);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMMM yyyy").format(ulok.createdAt);

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.white,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HeaderCard(
              icon: Icons.location_city,
              title: "Usulan Lokasi Eksternal",
              subtitle: "Masuk pada $formattedDate",
              statusBadge: _buildStatusBadge(),
            ),
            const SizedBox(height: 16),

            DetailSectionCard(
              title: "Data Lokasi",
              icon: Icons.location_on,
              children: [
                InfoRow(label: "Alamat Lengkap", value: ulok.fullAddress),
                const SizedBox(height: 12),
                InfoRow(label: "Koordinat", value: "${ulok.latitude}, ${ulok.longitude}"),
                const SizedBox(height: 12),
                InteractiveMapWidget(position: ulok.latLng),
              ],
            ),
            const SizedBox(height: 16),

            DetailSectionCard(
              title: "Data Bangunan",
              icon: Icons.store,
              children: [
                TwoColumnRowWidget(
                  label1: "Bentuk Objek",
                  value1: ulok.bentukObjek ?? '-',
                  label2: "Alas Hak",
                  value2: ulok.alasHak ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Jumlah Lantai",
                  value1: ulok.jumlahLantai?.toString() ?? '-',
                  label2: "Luas",
                  value2: ulok.luas != null ? '${ulok.luas} m²' : '-',
                ),
                TwoColumnRowWidget(
                  label1: "Lebar Depan",
                  value1: ulok.lebarDepan != null ? '${ulok.lebarDepan} m' : '-',
                  label2: "Panjang",
                  value2: ulok.panjang != null ? '${ulok.panjang} m' : '-',
                ),
                TwoColumnRowWidget(
                  label1: "Harga Sewa",
                  value1: DateFormatter.formatCurrency(ulok.hargaSewa),
                  label2: "", value2: "", // Spacer
                ),
              ],
            ),
            const SizedBox(height: 16),

            DetailSectionCard(
              title: "Data Pemilik",
              icon: Icons.person,
              children: [
                TwoColumnRowWidget(
                  label1: "Nama Pemilik",
                  value1: ulok.namaPemilik ?? '-',
                  label2: "Kontak",
                  value2: ulok.kontakPemilik ?? '-',
                ),
              ],
            ),

            if (ulok.fotoLokasi != null && ulok.fotoLokasi!.isNotEmpty) ...[
              const SizedBox(height: 16),
              DetailSectionCard(
                title: "Foto Lokasi",
                icon: Icons.image,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      FileService.openOrDownloadFile(
                        context,
                        ulok.fotoLokasi,
                        bucketName: 'file_storage_eksternal',
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _getImageUrl(ulok.fotoLokasi!),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                    strokeWidth: 2
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  "Buka File",
                                  style: TextStyle(fontSize: 12, color: AppColors.primaryColor),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.open_in_new, size: 14, color: AppColors.primaryColor),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (ulok.approvedAt != null) ...[
              const SizedBox(height: 16),
              DetailSectionCard(
                title: "Informasi Approval",
                icon: Icons.verified_user,
                children: [
                  InfoRow(
                    label: "Disetujui Pada", 
                    value: DateFormatter.formatDate(ulok.approvedAt!)
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        )
      ),
    );
  }
}