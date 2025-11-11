// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';

class KpltDetailScreen extends ConsumerWidget {
  final String kpltId;
  const KpltDetailScreen({super.key, required this.kpltId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpltAsyncValue = ref.watch(kpltDetailProvider(kpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail KPLT',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: kpltAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(kpltDetailProvider(kpltId)),
        ),
        data: (kpltData) => _KpltDetailView(
          kplt: kpltData,
          onRefresh: () async {
            ref.invalidate(kpltDetailProvider(kpltId));
          },
        ),
      ),
    );
  }
}

class _KpltDetailView extends StatelessWidget {
  final FormKPLT kplt;
  final Future<void> Function() onRefresh;
  
  const _KpltDetailView({
    required this.kplt,
    required this.onRefresh,
  });

  Color _getStatusColor() {
    switch (kplt.status) {
      case 'In Progress':
        return AppColors.secondaryColor;
      case 'OK':
        return AppColors.successColor;
      case 'NOK':
        return AppColors.primaryColor;
      case 'Waiting for Forum':
        return AppColors.secondaryColor;
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
        kplt.status,
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
    final formattedDate = DateFormat("dd MMMM yyyy").format(kplt.tanggal);
    final latLngParts = kplt.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(
      double.tryParse(latLngParts[0]) ?? 0.0,
      double.tryParse(latLngParts[1]) ?? 0.0,
    );
    final fullAddress = [
      kplt.alamat,
      kplt.desaKelurahan,
      kplt.kecamatan.isNotEmpty ? 'Kec. ${kplt.kecamatan}' : '',
      kplt.kabupaten,
      kplt.provinsi,
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
            // Header Card
            HeaderCard(
              icon: Icons.store,
              title: kplt.namaLokasi,
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
                InfoRow(label: "LatLong", value: kplt.latLong ?? "-"),
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
                  value1: kplt.formatStore ?? '-',
                  label2: "Bentuk Objek",
                  value2: kplt.bentukObjek ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Alas Hak",
                  value1: kplt.alasHak ?? '-',
                  label2: "Jumlah Lantai",
                  value2: kplt.jumlahLantai?.toString() ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Lebar Depan",
                  value1: kplt.lebarDepan != null ? '${kplt.lebarDepan} m' : '-',
                  label2: "Panjang",
                  value2: kplt.panjang != null ? '${kplt.panjang} m' : '-',
                ),
                TwoColumnRowWidget(
                  label1: "Luas",
                  value1: kplt.luas != null ? '${kplt.luas} m²' : '-',
                  label2: "Harga Sewa",
                  value2: DateFormatter.formatCurrency(kplt.hargaSewa),
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
                  value1: kplt.namaPemilik ?? '-',
                  label2: "Kontak Pemilik",
                  value2: kplt.kontakPemilik ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form Ulok (if exists)
            if (kplt.formUlok != null && kplt.formUlok!.isNotEmpty) ...[
              DetailSectionCard(
                title: "Form Ulok",
                icon: Icons.description,
                children: [
                  FileRow(
                    label: "Form Ulok",
                    filePath: kplt.formUlok!,
                    onTap: () => FileService.openOrDownloadFile(
                      context,
                      kplt.formUlok,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Analisa & FPL
            DetailSectionCard(
              title: "Analisa & FPL",
              icon: Icons.analytics,
              children: [
                TwoColumnRowWidget(
                  label1: "Karakter Lokasi",
                  value1: kplt.karakterLokasi ?? '-',
                  label2: "Sosial Ekonomi",
                  value2: kplt.sosialEkonomi ?? '-',
                ),
                TwoColumnRowWidget(
                  label1: "Skor FPL",
                  value1: kplt.skorFpl?.toString() ?? '-',
                  label2: "STD",
                  value2: kplt.std != null ? kplt.std!.toInt().toString() : '-',
                ),
                TwoColumnRowWidget(
                  label1: "APC",
                  value1: DateFormatter.formatCurrency(kplt.apc),
                  label2: "SPD",
                  value2: DateFormatter.formatCurrency(kplt.spd),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data PE
            DetailSectionCard(
              title: "Data PE",
              icon: Icons.business,
              children: [
                TwoColumnRowWidget(
                  label1: "PE Status",
                  value1: kplt.peStatus ?? '-',
                  label2: "PE RAB",
                  value2: DateFormatter.formatCurrency(kplt.peRab),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dokumen KPLT
            DetailSectionCard(
              title: "Dokumen KPLT",
              icon: Icons.folder,
              children: [
                ...[
                  FileRow(
                    label: "PDF Foto",
                    filePath: kplt.pdfFoto ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.pdfFoto),
                  ),
                  FileRow(
                    label: "Counting Kompetitor",
                    filePath: kplt.countingKompetitor ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.countingKompetitor),
                  ),
                  FileRow(
                    label: "PDF Pembanding",
                    filePath: kplt.pdfPembanding ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.pdfPembanding),
                  ),
                  FileRow(
                    label: "PDF KKS",
                    filePath: kplt.pdfKks ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.pdfKks),
                  ),
                  FileRow(
                    label: "Excel FPL",
                    filePath: kplt.excelFpl ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.excelFpl),
                  ),
                  FileRow(
                    label: "Excel PE",
                    filePath: kplt.excelPe ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.excelPe),
                  ),
                  FileRow(
                    label: "Video Traffic Siang",
                    filePath: kplt.videoTrafficSiang ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.videoTrafficSiang),
                  ),
                  FileRow(
                    label: "Video Traffic Malam",
                    filePath: kplt.videoTrafficMalam ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.videoTrafficMalam),
                  ),
                  FileRow(
                    label: "Video 360 Siang",
                    filePath: kplt.video360Siang ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.video360Siang),
                  ),
                  FileRow(
                    label: "Video 360 Malam",
                    filePath: kplt.video360Malam ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.video360Malam),
                  ),
                  FileRow(
                    label: "Peta Coverage",
                    filePath: kplt.petaCoverage ?? '',
                    onTap: () => FileService.openOrDownloadFile(context, kplt.petaCoverage),
                  ),
                ].expand((widget) => [widget, const SizedBox(height: 8)]).toList(),
              ],
            ),

            // Data Intip (if exists)
            if (kplt.approvalIntip != null) ...[
              const SizedBox(height: 16),
              DetailSectionCard(
                title: "Data Intip",
                icon: Icons.analytics,
                children: [
                  TwoColumnRowWidget(
                    label1: "Status Intip",
                    value1: kplt.approvalIntip ?? '-',
                    label2: "Tanggal Intip",
                    value2: DateFormatter.formatDate(kplt.tanggalApprovalIntip),
                  ),
                  if (kplt.fileIntip != null && kplt.fileIntip!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    FileRow(
                      label: "File Intip",
                      filePath: kplt.fileIntip!,
                      onTap: () => FileService.openOrDownloadFile(
                        context,
                        kplt.fileIntip,
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Data Ukur (if exists)
            if (kplt.formUkur != null && kplt.formUkur!.isNotEmpty) ...[
              const SizedBox(height: 16),
              DetailSectionCard(
                title: "Data Ukur",
                icon: Icons.straighten,
                children: [
                  InfoRow(
                    label: "Tanggal Ukur",
                    value: DateFormatter.formatDate(kplt.tanggalUkur),
                  ),
                  const SizedBox(height: 12),
                  FileRow(
                    label: "Form Ukur",
                    filePath: kplt.formUkur!,
                    onTap: () => FileService.openOrDownloadFile(
                      context,
                      kplt.formUkur,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}