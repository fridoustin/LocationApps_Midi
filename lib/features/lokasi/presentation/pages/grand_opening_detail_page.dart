import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/grand_opening.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/status_badge.dart';

class GrandOpeningDetailPage extends ConsumerWidget {
  final String progressKpltId;
  final String kpltName;

  const GrandOpeningDetailPage({
    super.key,
    required this.progressKpltId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grandOpeningAsync = ref.watch(grandOpeningDataProvider(progressKpltId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Grand Opening',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: grandOpeningAsync.when(
        data: (grandOpening) => grandOpening == null
            ? const EmptyState(
                title: 'Data Grand Opening Belum Tersedia',
                message: 'Belum ada data Grand Opening untuk KPLT ini',
              )
            : _GrandOpeningContent(
                data: grandOpening,
                kpltName: kpltName,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(grandOpeningDataProvider(progressKpltId)),
        ),
      ),
    );
  }
}

class _GrandOpeningContent extends StatelessWidget {
  final GrandOpening data;
  final String kpltName;

  const _GrandOpeningContent({
    required this.data,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          DetailHeaderCard(
            title: kpltName,
            subtitle: 'Grand Opening',
            icon: Icons.celebration_rounded,
            statusBadge: StatusBadge(isCompleted: data.isCompleted),
          ),
          const SizedBox(height: 16),

          // Rekomendasi Vendor Section
          DetailSectionCard(
            title: 'Rekomendasi Vendor',
            icon: Icons.business_rounded,
            children: [
              InfoRow(
                label: 'Rekomendasi GO Vendor',
                value: data.rekomGoVendor ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Rekomendasi',
                value: DateFormatter.formatDate(data.tglRekomGoVendor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grand Opening Section
          DetailSectionCard(
            title: 'Grand Opening',
            icon: Icons.celebration_rounded,
            children: [
              InfoRow(
                label: 'Final Status',
                value: data.finalStatusGo ?? '-',
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: 'Tanggal Grand Opening',
                value: DateFormatter.formatDate(data.tanggalGo),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Informasi Tambahan Section
          DetailSectionCard(
            title: 'Informasi Tambahan',
            icon: Icons.info_outline,
            children: [
              InfoRow(
                label: 'Terakhir Diupdate',
                value: DateFormatter.formatDateTime(
                  data.updatedAt ?? data.createdAt,
                ),
              ),
              if (data.tglSelesaiGo != null) ...[
                const SizedBox(height: 12),
                InfoRow(
                  label: 'Tanggal Selesai',
                  value: DateFormatter.formatDate(data.tglSelesaiGo),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}