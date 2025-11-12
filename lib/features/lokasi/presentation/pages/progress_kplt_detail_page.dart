// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/presentation/pages/grand_opening_detail_page.dart';
import 'package:midi_location/features/lokasi/presentation/pages/izin_tetangga_detail_page.dart';
import 'package:midi_location/features/lokasi/presentation/pages/mou_detail_page.dart';
import 'package:midi_location/features/lokasi/presentation/pages/notaris_detail_page.dart';
import 'package:midi_location/features/lokasi/presentation/pages/perizinan_detail_page.dart';
import 'package:midi_location/features/lokasi/presentation/pages/renovasi_detail_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/error_state.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/progress/progress_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/progress/progress_info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/progress/progress_location_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/progress/progress_status_helper.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/progress/progress_step_config.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/progress/progress_timeline_node.dart';

class ProgressKpltDetailPage extends ConsumerStatefulWidget {
  final ProgressKplt progress;

  const ProgressKpltDetailPage({
    super.key,
    required this.progress,
  });

  @override
  ConsumerState<ProgressKpltDetailPage> createState() =>
      _ProgressKpltDetailPageState();
}

class _ProgressKpltDetailPageState
    extends ConsumerState<ProgressKpltDetailPage> {
  String? _selectedStep;

  String _formatDateSafe(String? dateStr) {
    if (dateStr == null) return '-';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '-';
    return DateFormat('dd MMMM yyyy').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final completionAsync =
        ref.watch(completionStatusProvider(widget.progress.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Progress KPLT',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: completionAsync.when(
        data: (completionData) => _ProgressContent(
          progress: widget.progress,
          completionData: completionData,
          selectedStep: _selectedStep,
          onStepSelected: (step) {
            setState(() {
              _selectedStep = (_selectedStep == step) ? null : step;
            });
          },
          formatDate: _formatDateSafe,
          onRefresh: () async {
            ref.invalidate(progressByKpltIdProvider(widget.progress.id));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          error: err.toString(),
          onRetry: () =>
              ref.invalidate(completionStatusProvider(widget.progress.id)),
        ),
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final ProgressKplt progress;
  final Map<String, dynamic> completionData;
  final String? selectedStep;
  final Function(String) onStepSelected;
  final String Function(String?) formatDate;
  final Future<void> Function() onRefresh;

  const _ProgressContent({
    required this.progress,
    required this.completionData,
    required this.selectedStep,
    required this.onStepSelected,
    required this.formatDate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: AppColors.white,
      color: AppColors.primaryColor,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            ProgressHeaderCard(
              title: progress.kpltNama ?? 'Nama KPLT',
              status: progress.status.value,
              statusColor: ProgressStatusHelper.getStatusColor(
                progress.status.value,
              ),
              statusLabel: ProgressStatusHelper.getStatusLabel(
                progress.status.value,
              ),
            ),

            const SizedBox(height: 16),

            // Location Card
            ProgressLocationCard(
              provinsi: progress.kpltProvinsi,
              kabupaten: progress.kpltKabupaten,
              kecamatan: progress.kpltKecamatan,
              kelurahan: progress.kpltKelurahan,
              alamat: progress.kpltAlamat,
            ),

            const SizedBox(height: 16),

            // Timeline Card
            _TimelineCard(
              completionData: completionData,
              currentStatus: progress.status.value,
              selectedStep: selectedStep,
              onStepSelected: onStepSelected,
            ),

            const SizedBox(height: 16),

            // Detail Card
            _StepDetailCard(
              progress: progress,
              completionData: completionData,
              selectedStep: selectedStep,
              formatDate: formatDate,
            ),

            const SizedBox(height: 24),
          ],
        ),
      )
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Map<String, dynamic> completionData;
  final String currentStatus;
  final String? selectedStep;
  final Function(String) onStepSelected;

  const _TimelineCard({
    required this.completionData,
    required this.currentStatus,
    required this.selectedStep,
    required this.onStepSelected,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.timeline,
                  color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Timeline Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildHorizontalTimeline(),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimeline() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(ProgressStepConfig.steps.length, (index) {
          final step = ProgressStepConfig.steps[index];
          final isCompleted =
              completionData[step.key]?['completed'] == true;
          final isActive = ProgressStatusHelper.isActiveStep(
            step.key,
            currentStatus,
          );
          final isLast = index == ProgressStepConfig.steps.length - 1;
          final isSelected = selectedStep == step.key;

          return Row(
            children: [
              ProgressTimelineNode(
                label: step.label,
                stepKey: step.key,
                iconData: step.icon,
                isCompleted: isCompleted,
                isActive: isActive,
                isSelected: isSelected,
                onTap: () => onStepSelected(step.key),
              ),
              if (!isLast)
                Container(
                  width: 50,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 45),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? LinearGradient(
                            colors: [
                              AppColors.successColor,
                              AppColors.successColor.withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: isCompleted ? null : Colors.grey[300],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _StepDetailCard extends StatelessWidget {
  final ProgressKplt progress;
  final Map<String, dynamic> completionData;
  final String? selectedStep;
  final String Function(String?) formatDate;

  const _StepDetailCard({
    required this.progress,
    required this.completionData,
    required this.selectedStep,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final stepKey = selectedStep ??
        ProgressStatusHelper.getCurrentActiveStep(progress.status.value);
    final stepConfig = ProgressStepConfig.getStep(stepKey);
    final stepData = completionData[stepKey];
    final isCompleted = stepData?['completed'] == true;
    final isActive =
        ProgressStatusHelper.isActiveStep(stepKey, progress.status.value);
    final completedDate = stepData?['date'] as String?;
    final createdDate = stepData?['created_date'] as String?;

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.successColor.withOpacity(0.15)
                      : isActive
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stepConfig.icon,
                  color: isCompleted
                      ? AppColors.successColor
                      : isActive
                          ? Colors.orange
                          : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepConfig.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepConfig.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Status Badge
          _StatusBadge(isCompleted: isCompleted, isActive: isActive),

          // Date Info or Status Message
          if (isCompleted && completedDate != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  ProgressInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Tanggal Mulai',
                    value: formatDate(createdDate),
                  ),
                  const SizedBox(height: 12),
                  ProgressInfoRow(
                    icon: Icons.event_available,
                    label: 'Tanggal Selesai',
                    value: formatDate(completedDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (isActive) ...[
            const SizedBox(height: 20),
            _StatusMessage(
              type: StatusType.warning,
              icon: Icons.info_outline,
              message: 'Tahapan ini sedang dalam proses pengerjaan',
            )
          ] else ...[
            const SizedBox(height: 20),
            _StatusMessage(
              type: StatusType.info,
              icon: Icons.lock_outline,
              message: 'Tahapan ini belum dapat dimulai.',
            )
          ],

          // View Detail Button
          if (isCompleted || isActive) ...[
            const SizedBox(height: 16),
            _ViewDetailButton(
              progressId: progress.id,
              kpltName: progress.kpltNama ?? 'KPLT',
              stepKey: stepKey,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;

  const _StatusBadge({
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (isCompleted) {
      badgeColor = AppColors.successColor;
      badgeIcon = Icons.check_circle;
      badgeText = 'Selesai';
    } else if (isActive) {
      badgeColor = Colors.orange;
      badgeIcon = Icons.schedule;
      badgeText = 'Dalam Pengerjaan';
    } else {
      badgeColor = Colors.grey;
      badgeIcon = Icons.lock_outline;
      badgeText = 'Belum Dimulai';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withOpacity(0.1),
            badgeColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 20, color: badgeColor),
          const SizedBox(width: 8),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final StatusType type; // enum: warning, error, info
  final IconData icon;
  final String message;

  const _StatusMessage({
    required this.type,
    required this.icon,
    required this.message,
  });

  ColorScheme _getColorScheme() {
    switch (type) {
      case StatusType.warning:
        return ColorScheme(
          background: Colors.orange[50]!,
          border: Colors.orange[200]!,
          icon: Colors.orange[700]!,
          text: Colors.orange[900]!,
        );
      case StatusType.error:
        return ColorScheme(
          background: Colors.red[50]!,
          border: Colors.red[200]!,
          icon: Colors.red[700]!,
          text: Colors.red[900]!,
        );
      case StatusType.info:
      return ColorScheme(
          background: Colors.grey[100]!,
          border: Colors.grey[300]!,
          icon: Colors.grey[600]!,
          text: Colors.grey[700]!,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorScheme();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: colors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorScheme {
  final Color background;
  final Color border;
  final Color icon;
  final Color text;

  ColorScheme({
    required this.background,
    required this.border,
    required this.icon,
    required this.text,
  });
}

enum StatusType { warning, error, info }

class _ViewDetailButton extends StatelessWidget {
  final String progressId;
  final String kpltName;
  final String stepKey;

  const _ViewDetailButton({
    required this.progressId,
    required this.kpltName,
    required this.stepKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToStepDetail(context),
        icon: const Icon(Icons.visibility, size: 20),
        label: const Text('Lihat Detail'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _navigateToStepDetail(BuildContext context) {
    Widget? page;

    switch (stepKey) {
      case 'mou':
        page = MouDetailPage(
          progressKpltId: progressId,
          kpltName: kpltName,
        );
        break;
      case 'izin_tetangga':
        page = IzinTetanggaDetailPage(
          progressKpltId: progressId,
          kpltName: kpltName,
        );
        break;
      case 'perizinan':
        page = PerizinanDetailPage(
          progressKpltId: progressId,
          kpltName: kpltName,
        );
        break;
      case 'notaris':
        page = NotarisDetailPage(
          progressKpltId: progressId,
          kpltName: kpltName,
        );
        break;
      case 'renovasi':
        page = RenovasiDetailPage(
          progressKpltId: progressId,
          kpltName: kpltName,
        );
        break;
      case 'grand_opening':
        page = GrandOpeningDetailPage(
          progressKpltId: progressId,
          kpltName: kpltName,
        );
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page!),
      );
    }
  }
}