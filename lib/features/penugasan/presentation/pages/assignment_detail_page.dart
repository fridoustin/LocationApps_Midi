import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_eksternal_detail_screen.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_detail_controller.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_header_card.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_timeline_item.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_tracking_history.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_action_buttons.dart';

class AssignmentDetailPage extends ConsumerStatefulWidget {
  final Assignment assignment;
  const AssignmentDetailPage({super.key, required this.assignment});

  @override
  ConsumerState<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends ConsumerState<AssignmentDetailPage> {

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: confirmColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: confirmColor),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(confirmText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: AppColors.primaryColor),
              SizedBox(height: 20),
              Text("Memproses data...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: AppColors.successColor),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Oke, Mengerti", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text("Terjadi Kesalahan", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCheckIn(AssignmentActivity activity) async {
    final confirm = await _showConfirmDialog(
      title: "Check-in Lokasi",
      content: "Pastikan Anda sudah berada di lokasi ${activity.activityName}.",
      confirmText: "Ya, Check-in",
      confirmColor: AppColors.primaryColor,
      icon: Icons.location_on,
    );

    if (confirm != true) return;
    if (!mounted) return;
    
    _showLoadingDialog();

    try {
      await ref.read(assignmentDetailControllerProvider).checkInActivity(activity, widget.assignment.id);
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog("Check-in Berhasil!", "Anda berhasil check-in di lokasi ini.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _onToggleCompletion(AssignmentActivity activity, bool val) async {
    if (!val) return;
    if (!activity.canBeCompleted()) {
      _showErrorDialog('Silakan check-in terlebih dahulu.');
      return;
    }

    final confirm = await _showConfirmDialog(
      title: "Selesaikan Aktivitas?",
      content: "Apakah tugas \"${activity.activityName}\" benar-benar sudah selesai?",
      confirmText: "Ya, Selesai",
      confirmColor: AppColors.successColor,
      icon: Icons.check_circle_outline,
    );

    if (confirm != true) return;
    if (!mounted) return;

    _showLoadingDialog();

    try {
      await ref.read(assignmentDetailControllerProvider).toggleCompletion(activity, widget.assignment.id);
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog("Aktivitas Selesai!", "Kerja bagus, lanjutkan ke aktivitas berikutnya.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _onCancelAssignment(List<AssignmentActivity> activities) async {
    final confirm = await _showConfirmDialog(
      title: "Batalkan Penugasan?",
      content: "Penugasan yang dibatalkan tidak dapat dikembalikan. Yakin ingin lanjut?",
      confirmText: "Ya, Batalkan",
      confirmColor: Colors.red,
      icon: Icons.cancel_outlined,
    );

    if (confirm != true) return;
    if (!mounted) return;

    _showLoadingDialog();

    try {
      final ulokId = _findExternalLocationId(activities);
      await ref.read(assignmentDetailControllerProvider).updateAssignmentStatus(
        assignmentId: widget.assignment.id, 
        status: AssignmentStatus.cancelled,
        notes: 'Penugasan dibatalkan oleh user',
        ulokId: ulokId
      );
      if (mounted) {
        Navigator.pop(context);
        await _showSuccessDialog("Dibatalkan", "Status penugasan telah diperbarui.");
        if (mounted) Navigator.pop(context); // Tutup Halaman
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _onCompleteAssignment() async {
    final confirm = await _showConfirmDialog(
      title: "Selesaikan Penugasan?",
      content: "Pastikan semua data sudah benar. Penugasan yang selesai tidak dapat diubah.",
      confirmText: "Selesaikan",
      confirmColor: AppColors.successColor,
      icon: Icons.task_alt,
    );

    if (confirm != true) return;
    if (!mounted) return;

    _showLoadingDialog();

    try {
      await ref.read(assignmentDetailControllerProvider).updateAssignmentStatus(
        assignmentId: widget.assignment.id, 
        status: AssignmentStatus.completed,
        notes: 'Penugasan diselesaikan oleh user',
      );
      if (mounted) {
        Navigator.pop(context);
        await _showSuccessDialog("Selesai!", "Terima kasih atas kerja keras Anda.");
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  String? _findExternalLocationId(List<AssignmentActivity> activities) {
    for (var activity in activities) {
      if (activity.externalLocationId != null) {
        return activity.externalLocationId;
      }
    }
    return null;
  }

  Future<void> _onExternalCheckOk(List<AssignmentActivity> activities) async {
    final ulokId = _findExternalLocationId(activities);
    if (ulokId == null) {
      _showErrorDialog("Error: Tidak ditemukan data Ulok Eksternal di aktivitas manapun.");
      return;
    }
    final confirm = await _showConfirmDialog(
      title: "Setujui Lokasi?",
      content: "Status Ulok Eksternal akan diubah menjadi OK dan penugasan diselesaikan.",
      confirmText: "Ya, Setujui (OK)",
      confirmColor: AppColors.successColor,
      icon: Icons.thumb_up_alt_outlined,
    );

    if (confirm != true) return;
    if (!mounted) return;
    _showLoadingDialog();

    try {
      await ref.read(assignmentDetailControllerProvider).submitExternalCheckResult(
        assignmentId: widget.assignment.id,
        ulokId: ulokId,
        isApproved: true,
        notes: 'Disetujui oleh Location Specialist',
      );
      
      if (mounted) {
        Navigator.pop(context);
        await _showSuccessDialog("Berhasil", "Lokasi disetujui (OK).");
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString());
      }
    }
  }

  // Handler untuk External Check NOK
  Future<void> _onExternalCheckNok(List<AssignmentActivity> activities) async {
    final ulokId = _findExternalLocationId(activities);
    if (ulokId == null) {
      _showErrorDialog("Error: Tidak ditemukan data Ulok Eksternal di aktivitas manapun.");
      return;
    }
    final confirm = await _showConfirmDialog(
      title: "Tolak Lokasi?",
      content: "Status Ulok Eksternal akan diubah menjadi NOK. Pastikan alasan penolakan sudah jelas.",
      confirmText: "Ya, Tolak (NOK)",
      confirmColor: Colors.red,
      icon: Icons.thumb_down_alt_outlined,
    );

    if (confirm != true) return;
    if (!mounted) return;
    _showLoadingDialog();

    try {
      await ref.read(assignmentDetailControllerProvider).submitExternalCheckResult(
        assignmentId: widget.assignment.id,
        ulokId: ulokId,
        isApproved: false,
        notes: 'Ditolak oleh Location Specialist',
      );
      
      if (mounted) {
        Navigator.pop(context);
        await _showSuccessDialog("Berhasil", "Lokasi ditolak (NOK).");
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAssignmentsAsync = ref.watch(allAssignmentsProvider);
    
    final Assignment currentAssignment = allAssignmentsAsync.maybeWhen(
      data: (assignments) => assignments.firstWhere(
        (a) => a.id == widget.assignment.id,
        orElse: () => widget.assignment,
      ),
      orElse: () => widget.assignment,
    );

    final activitiesAsync = ref.watch(assignmentActivitiesProvider(currentAssignment.id));
    final trackingHistoryAsync = ref.watch(trackingHistoryProvider(currentAssignment.id));
    
    final isLoading = ref.watch(assignmentActionStateProvider);

    final activities = activitiesAsync.valueOrNull ?? []; 
    final completedCount = activities.where((a) => a.isCompleted).length;
    final totalCount = activities.length;
    final double progress = totalCount == 0 ? 0 : completedCount / totalCount;
    final allActivitiesCompleted = totalCount > 0 && completedCount == totalCount;

    final externalIdForNav = activities.isNotEmpty 
                  ? activities.firstWhere((a) => a.externalLocationId != null, orElse: () => activities.first).externalLocationId 
                  : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Penugasan',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset("assets/icons/left_arrow.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.cardColor,
        onRefresh: () async {
          ref.invalidate(assignmentActivitiesProvider(currentAssignment.id));
          ref.invalidate(trackingHistoryProvider(currentAssignment.id));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AssignmentHeaderCard(
                assignment: currentAssignment,
                progress: progress,
                completedCount: completedCount,
                totalCount: totalCount,
              ),

              const SizedBox(height: 24),

              if (currentAssignment.type == AssignmentType.externalCheck && 
                  externalIdForNav != null) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UlokEksternalDetailPage(ulokId: externalIdForNav),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business_outlined,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Cek Detail Lokasi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Lihat data lengkap usulan eksternal",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildSectionTitle('Daftar Aktivitas', Icons.format_list_bulleted),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: activitiesAsync.when(
                  data: (list) {
                    if (list.isEmpty) return const Center(child: Text('Belum ada aktivitas'));
                    return Column(
                      children: List.generate(list.length, (index) {
                        final act = list[index];
                        final isNext = !act.isCompleted && (index == 0 || list[index - 1].isCompleted);
                        
                        return AssignmentTimelineItem(
                          activity: act,
                          isLastItem: index == list.length - 1,
                          isCompleted: act.isCompleted,
                          isNextTask: isNext,
                          isCheckingIn: isLoading,
                          isToggling: isLoading,
                          onCheckIn: () => _onCheckIn(act),
                          onToggle: (val) => _onToggleCompletion(act, val),
                        );
                      }),
                    );
                  },
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                  error: (e, s) => Text('Error: $e'),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Riwayat Tracking', Icons.history),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: AssignmentTrackingHistory(trackingHistoryAsync: trackingHistoryAsync),
              ),

              const SizedBox(height: 24),

              if (currentAssignment.status != AssignmentStatus.completed &&
                  currentAssignment.status != AssignmentStatus.cancelled)
                AssignmentActionButtons(
                  assignmentType: currentAssignment.type,
                  allActivitiesCompleted: allActivitiesCompleted,
                  onComplete: _onCompleteAssignment,
                  onCancel: () => _onCancelAssignment(activities),
                  onExternalOk: () => _onExternalCheckOk(activities), 
                  onExternalNok: () => _onExternalCheckNok(activities),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}