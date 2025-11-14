// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';

class UlokDetailPage extends ConsumerWidget {
  final String ulokId;
  const UlokDetailPage({super.key, required this.ulokId});
  static const String route = '/ulok/detail';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ulokAsyncValue = ref.watch(ulokDetailProvider(ulokId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Usulan Lokasi',
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(ulokDetailProvider(ulokId)),
        ),
        data: (ulokData) => _UlokDetailView(
          ulok: ulokData,
          onRefresh: () async {
            ref.invalidate(ulokDetailProvider(ulokId));
          },
        ),
      ),
    );
  }
}

class _UlokDetailView extends StatelessWidget {
  final UsulanLokasi ulok;
  final Future<void> Function() onRefresh;
  
  const _UlokDetailView({
    required this.ulok,
    required this.onRefresh,
  });

  Color _getStatusColor() {
    switch (ulok.status) {
      case 'In Progress':
        return AppColors.warningColor;
      case 'OK':
        return AppColors.successColor;
      case 'NOK':
        return AppColors.primaryColor;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMMM yyyy").format(ulok.createdAt);
    final latLngParts = ulok.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(
      double.tryParse(latLngParts[0]) ?? 0.0,
      double.tryParse(latLngParts[1]) ?? 0.0,
    );

    final fullAddress = [
      ulok.alamat,
      ulok.desaKelurahan,
      ulok.kecamatan.isNotEmpty ? 'Kec. ${ulok.kecamatan}' : '',
      ulok.kabupaten,
      ulok.provinsi,
    ].where((e) => e.isNotEmpty).join(', ');

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.white,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with custom status badge
            HeaderCard(
              icon: Icons.location_on,
              title: ulok.namaLokasi,
              subtitle: "Dibuat $formattedDate",
              statusBadge: _buildStatusBadge(),
            ),
            const SizedBox(height: 16),

            // Data Usulan Lokasi
            DetailSectionCard(
              title: "Data Usulan Lokasi",
              icon: Icons.location_on,
              children: [
                InfoRow(label: "Alamat", value: fullAddress),
                const SizedBox(height: 12),
                InfoRow(label: "LatLong", value: ulok.latLong ?? "-"),
                const SizedBox(height: 12),
                InteractiveMapWidget(position: latLng),
              ],
            ),
            const SizedBox(height: 16),

            // Data Store
            DetailSectionCard(
              title: "Data Store",
              icon: Icons.store,
              children: [
                TwoColumnRowWidget(
                  label1: "Format Store",
                  value1: ulok.formatStore ?? '-',
                  label2: "Bentuk Objek",
                  value2: ulok.bentukObjek ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Alas Hak",
                  value1: ulok.alasHak ?? '-',
                  label2: "Jumlah Lantai",
                  value2: ulok.jumlahLantai?.toString() ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Lebar Depan",
                  value1: ulok.lebarDepan != null ? '${ulok.lebarDepan} m' : '-',
                  label2: "Panjang",
                  value2: ulok.panjang != null ? '${ulok.panjang} m' : '-',
                ),
                TwoColumnRowWidget(
                  label1: "Luas",
                  value1: ulok.luas != null ? '${ulok.luas} m²' : '-',
                  label2: "Harga Sewa",
                  value2: DateFormatter.formatCurrency(ulok.hargaSewa),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Pemilik
            DetailSectionCard(
              title: "Data Pemilik",
              icon: Icons.person,
              children: [
                TwoColumnRowWidget(
                  label1: "Nama Pemilik",
                  value1: ulok.namaPemilik ?? '-',
                  label2: "Kontak Pemilik",
                  value2: ulok.kontakPemilik ?? '-',
                ),
              ],
            ),

            // Form Ulok (if exists)
            if (ulok.formUlok != null && ulok.formUlok!.isNotEmpty) ...[
              const SizedBox(height: 16),
              DetailSectionCard(
                title: "Form Ulok",
                icon: Icons.description,
                children: [
                  FileRow(
                    label: "Form Ulok",
                    filePath: ulok.formUlok!,
                    onTap: () => FileService.openOrDownloadFile(
                      context,
                      ulok.formUlok,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            DetailSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              TwoColumnRowWidget(
                  label1: "Tanggal Ulok Dibuat",
                  value1: DateFormatter.formatDate(ulok.createdAt),
                  label2: "Dibuat oleh",
                  value2: ulok.createdBy!,
                ),
              if (ulok.approvedAt != null && ulok.status == 'OK') ...[
                const SizedBox(height: 12),
                TwoColumnRowWidget(
                  label1: "Tanggal Ulok Disetujui",
                  value1: DateFormatter.formatDate(ulok.approvedAt!),
                  label2: "Disetujui oleh",
                  value2: ulok.approvedBy!,
                ),
              ],
              if (ulok.updatedAt != null && ulok.status == 'NOK') ...[
                const SizedBox(height: 12),
                TwoColumnRowWidget(
                  label1: "Tanggal Ulok Ditolak",
                  value1: DateFormatter.formatDate(ulok.updatedAt!),
                  label2: "Ditolak oleh",
                  value2: ulok.updatedBy!,
                ),
              ],
            ],
          ),

            const SizedBox(height: 24),

            // Edit Button (if status is In Progress)
            if (ulok.status == 'In Progress')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final initialState = UlokFormState.fromUsulanLokasi(ulok);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UlokFormPage(initialState: initialState),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text(
                    "Edit Data Usulan Lokasi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        )
      ),
    );
  }
}