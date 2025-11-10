// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/renovasi.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/empty_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/compact_file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_card_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/history/history_section_title.dart';

class HistoryRenovasiPage extends ConsumerWidget {
  final String renovasiId;
  final String kpltName;

  const HistoryRenovasiPage({
    super.key,
    required this.renovasiId,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyRenovasiProvider(renovasiId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'History Renovasi',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: historyAsync.when(
        data: (historyList) => historyList.isEmpty
            ? const EmptyState(
                title: 'Belum Ada History',
                message: 'Belum ada history renovasi untuk data ini',
                icon: Icons.history,
              )
            : _HistoryRenovasiList(
                historyList: historyList,
                kpltName: kpltName,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () => ref.invalidate(historyRenovasiProvider(renovasiId)),
        ),
      ),
    );
  }
}

class _HistoryRenovasiList extends StatelessWidget {
  final List<HistoryRenovasi> historyList;
  final String kpltName;

  const _HistoryRenovasiList({
    required this.historyList,
    required this.kpltName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HistoryHeader(title: kpltName, historyCount: historyList.length),
          const SizedBox(height: 16),
          ...historyList.asMap().entries.map((entry) {
            final index = entry.key;
            final history = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == historyList.length - 1 ? 0 : 16,
              ),
              child: _HistoryRenovasiCard(
                history: history,
                number: index + 1,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _HistoryRenovasiCard extends StatelessWidget {
  final HistoryRenovasi history;
  final int number;

  const _HistoryRenovasiCard({
    required this.history,
    required this.number,
  });

  bool get _hasProgressData =>
      history.planRenov != null ||
      history.prosesRenov != null ||
      history.deviasi != null;

  @override
  Widget build(BuildContext context) {
    final prosesPercentage = history.prosesRenov ?? 0;
    final progressColor = history.progressColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryCardHeader(number: number, createdAt: history.createdAt),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Progress Tracking
          if (_hasProgressData) ...[
            _buildProgressSection(prosesPercentage, progressColor),
            const SizedBox(height: 16),
          ],

          // Informasi Store
          if (history.kodeStore != null ||
              history.tipeToko != null ||
              history.bentukObjek != null) ...[
            const HistorySectionTitle(title: 'Informasi Store'),
            const SizedBox(height: 8),
            if (history.kodeStore != null)
              HistoryInfoRow(label: 'Kode Store', value: history.kodeStore!),
            if (history.kodeStore != null && history.tipeToko != null)
              const SizedBox(height: 8),
            if (history.tipeToko != null)
              HistoryInfoRow(label: 'Tipe Toko', value: history.tipeToko!),
            if (history.tipeToko != null && history.bentukObjek != null)
              const SizedBox(height: 8),
            if (history.bentukObjek != null)
              HistoryInfoRow(label: 'Bentuk Objek', value: history.bentukObjek!),
            const SizedBox(height: 16),
          ],

          // Rekomendasi
          if (history.rekomRenovasi != null ||
              history.tglRekomRenovasi != null) ...[
            const HistorySectionTitle(title: 'Rekomendasi Renovasi'),
            const SizedBox(height: 8),
            if (history.rekomRenovasi != null)
              HistoryInfoRow(
                label: 'Rekomendasi',
                value: history.rekomRenovasi!,
              ),
            if (history.rekomRenovasi != null &&
                history.tglRekomRenovasi != null)
              const SizedBox(height: 8),
            if (history.tglRekomRenovasi != null)
              HistoryInfoRow(
                label: 'Tanggal',
                value: DateFormatter.formatDate(history.tglRekomRenovasi),
              ),
            if (history.fileRekomRenovasi != null) ...[
              const SizedBox(height: 8),
              CompactFileRow(
                label: 'File Rekomendasi',
                filePath: history.fileRekomRenovasi!,
                onTap: () => FileService.openOrDownloadFile(
                  context,
                  history.fileRekomRenovasi,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // SPK
          if (history.startSpkRenov != null || history.endSpkRenov != null) ...[
            const HistorySectionTitle(title: 'SPK Renovasi'),
            const SizedBox(height: 8),
            if (history.startSpkRenov != null)
              HistoryInfoRow(
                label: 'Start SPK',
                value: DateFormatter.formatDate(history.startSpkRenov),
              ),
            if (history.startSpkRenov != null && history.endSpkRenov != null)
              const SizedBox(height: 8),
            if (history.endSpkRenov != null)
              HistoryInfoRow(
                label: 'End SPK',
                value: DateFormatter.formatDate(history.endSpkRenov),
              ),
            const SizedBox(height: 16),
          ],

          // Informasi Tambahan
          if (history.tglSerahTerima != null ||
              history.tglSelesaiRenov != null) ...[
            const HistorySectionTitle(title: 'Informasi Tambahan'),
            const SizedBox(height: 8),
            if (history.tglSerahTerima != null)
              HistoryInfoRow(
                label: 'Tanggal Serah Terima',
                value: DateFormatter.formatDate(history.tglSerahTerima),
              ),
            if (history.tglSerahTerima != null &&
                history.tglSelesaiRenov != null)
              const SizedBox(height: 8),
            if (history.tglSelesaiRenov != null)
              HistoryInfoRow(
                label: 'Tanggal Selesai',
                value: DateFormatter.formatDate(history.tglSelesaiRenov),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(double prosesPercentage, Color progressColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            progressColor.withOpacity(0.1),
            progressColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: progressColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    history.progressStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${prosesPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prosesPercentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressMiniItem(
                'Plan',
                history.planRenov != null
                    ? '${history.planRenov!.toStringAsFixed(1)}%'
                    : '-',
                Colors.blue,
              ),
              _buildProgressMiniItem(
                'Proses',
                history.prosesRenov != null
                    ? '${history.prosesRenov!.toStringAsFixed(1)}%'
                    : '-',
                progressColor,
              ),
              _buildProgressMiniItem(
                'Deviasi',
                history.deviasi != null
                    ? '${history.deviasi! >= 0 ? '+' : ''}${history.deviasi!.toStringAsFixed(1)}%'
                    : '-',
                history.deviasi != null
                    ? (history.deviasi! >= 0 ? Colors.green : Colors.red)
                    : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMiniItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}