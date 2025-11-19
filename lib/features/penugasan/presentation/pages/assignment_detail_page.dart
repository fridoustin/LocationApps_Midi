import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_info_section.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_activity_list.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_tracking_history.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/detail/assignment_action_buttons.dart';

class AssignmentDetailPage extends ConsumerStatefulWidget {
  final Assignment assignment;

  const AssignmentDetailPage({
    super.key,
    required this.assignment,
  });

  @override
  ConsumerState<AssignmentDetailPage> createState() =>
      _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends ConsumerState<AssignmentDetailPage> {
  String? _checkingInActivityId;
  String? _togglingActivityId;

  Future<void> _checkInActivity(AssignmentActivity activity) async {
    // Validation
    if (!_canCheckIn(activity)) return;

    setState(() => _checkingInActivityId = activity.id);

    try {
      final currentLocation = await _getCurrentLocation();
      final isInRadius = await _validateDistance(activity, currentLocation);

      if (!isInRadius) return;

      await _performCheckIn(activity, currentLocation);
      await _updateAssignmentStatusIfNeeded();

      _showSuccess('Check-in di ${activity.activityName} berhasil!');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _checkingInActivityId = null);
    }
  }

  bool _canCheckIn(AssignmentActivity activity) {
    if (!activity.requiresCheckin || activity.location == null) {
      _showError('Lokasi aktivitas belum ditentukan');
      return false;
    }

    if (activity.checkedInAt != null) {
      _showError('Aktivitas ini sudah di-checkin');
      return false;
    }

    return true;
  }

  Future<LatLng> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<bool> _validateDistance(
    AssignmentActivity activity,
    LatLng currentLocation,
  ) async {
    final Distance distance = const Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      currentLocation,
      activity.location!,
    );

    if (meters > activity.checkInRadius) {
      if (mounted) {
        _showError(
          'Anda terlalu jauh dari lokasi! '
          'Jarak: ${meters.toStringAsFixed(0)}m, '
          'Maksimal: ${activity.checkInRadius}m',
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _performCheckIn(
    AssignmentActivity activity,
    LatLng location,
  ) async {
    final repository = ref.read(assignmentRepositoryProvider);
    final userProfile = await ref.read(userProfileProvider.future);

    if (userProfile == null) throw Exception('User not found');

    await repository.checkInActivity(activity.id, location);

    final trackingPoint = TrackingPoint(
      id: '',
      assignmentId: widget.assignment.id,
      userId: userProfile.id,
      status: TrackingStatus.arrived,
      notes: 'Check-in di aktivitas: ${activity.activityName}',
      photoUrl: null,
      createdAt: DateTime.now(),
    );

    await repository.addTrackingPoint(trackingPoint);

    // Invalidate providers
    ref.invalidate(trackingHistoryProvider(widget.assignment.id));
    ref.invalidate(assignmentActivitiesProvider(widget.assignment.id));
    ref.invalidate(allAssignmentsProvider);
  }

  Future<void> _updateAssignmentStatusIfNeeded() async {
    if (widget.assignment.status == AssignmentStatus.pending) {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.updateAssignmentStatus(
        widget.assignment.id,
        AssignmentStatus.inProgress,
      );
    }
  }

  Future<void> _toggleCompletion(
    AssignmentActivity activity,
    bool value,
  ) async {
    if (value == false) return;

    if (!activity.canBeCompleted()) {
      _showError(
        'Silakan check-in terlebih dahulu untuk menyelesaikan aktivitas ini',
      );
      return;
    }

    final confirmed = await _showCompletionDialog(activity);
    if (confirmed != true) return;

    setState(() => _togglingActivityId = activity.id);

    try {
      await _performToggleCompletion(activity);
      _showSuccess('Aktivitas "${activity.activityName}" berhasil diselesaikan.');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _togglingActivityId = null);
    }
  }

  Future<bool?> _showCompletionDialog(AssignmentActivity activity) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Sudah Selesai?'),
        content: Text(
          'Apakah tugas anda "${activity.activityName}" sudah selesai?',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.primaryColor),
              ),
              backgroundColor: AppColors.white,
            ),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: AppColors.successColor,
            ),
            child: const Text(
              'Selesai',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performToggleCompletion(AssignmentActivity activity) async {
    final repository = ref.read(assignmentRepositoryProvider);
    final userProfile = await ref.read(userProfileProvider.future);

    if (userProfile == null) throw Exception('User not found');

    await repository.toggleActivityCompletion(activity.id, true);

    final trackingPoint = TrackingPoint(
      id: '',
      assignmentId: widget.assignment.id,
      userId: userProfile.id,
      status: TrackingStatus.arrived,
      notes: 'Selesai aktivitas: ${activity.activityName}',
      photoUrl: null,
      createdAt: DateTime.now(),
    );

    await repository.addTrackingPoint(trackingPoint);

    // Invalidate providers
    ref.invalidate(trackingHistoryProvider(widget.assignment.id));
    ref.invalidate(assignmentActivitiesProvider(activity.assignmentId));
  }

  // ============================================================================
  // ASSIGNMENT ACTIONS
  // ============================================================================

  Future<void> _cancelAssignment() async {
    final confirmed = await _showCancelDialog();
    if (confirmed != true) return;

    try {
      await _performCancelAssignment();
      if (mounted) {
        Navigator.pop(context);
        _showSuccess('Penugasan berhasil dibatalkan', color: Colors.red);
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Penugasan?'),
        content: const Text(
          'Penugasan yang dibatalkan tidak dapat dikembalikan lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancelAssignment() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile == null) throw Exception('User not found');

    final repository = ref.read(assignmentRepositoryProvider);

    final trackingPoint = TrackingPoint(
      id: '',
      assignmentId: widget.assignment.id,
      userId: userProfile.id,
      status: TrackingStatus.cancelled,
      notes: 'Penugasan dibatalkan oleh user',
      photoUrl: null,
      createdAt: DateTime.now(),
    );

    await repository.addTrackingPoint(trackingPoint);
    await repository.updateAssignmentStatus(
      widget.assignment.id,
      AssignmentStatus.cancelled,
    );

    // Invalidate all providers
    ref.invalidate(allAssignmentsProvider);
    ref.invalidate(pendingAssignmentsProvider);
    ref.invalidate(inProgressAssignmentsProvider);
    ref.invalidate(completedAssignmentsProvider);
    ref.invalidate(trackingHistoryProvider(widget.assignment.id));
  }

  Future<void> _completeAssignment() async {
    final confirmed = await _showCompleteDialog();
    if (confirmed != true) return;

    try {
      await _performCompleteAssignment();
      if (mounted) {
        Navigator.pop(context);
        _showSuccess('Penugasan berhasil diselesaikan!');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<bool?> _showCompleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Penugasan?'),
        content: const Text(
          'Pastikan semua aktivitas sudah selesai. '
          'Penugasan yang sudah selesai tidak dapat diubah lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
            ),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCompleteAssignment() async {
    final repository = ref.read(assignmentRepositoryProvider);
    await repository.updateAssignmentStatus(
      widget.assignment.id,
      AssignmentStatus.completed,
    );

    // Invalidate providers
    ref.invalidate(completedAssignmentsProvider);
    ref.invalidate(inProgressAssignmentsProvider);
    ref.invalidate(allAssignmentsProvider);
    ref.invalidate(trackingHistoryProvider(widget.assignment.id));
  }

  void _showSuccess(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.successColor,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final allAssignmentsAsync = ref.watch(allAssignmentsProvider);

    // Get updated assignment
    final Assignment currentAssignment = allAssignmentsAsync.maybeWhen(
      data: (assignments) => assignments.firstWhere(
        (a) => a.id == widget.assignment.id,
        orElse: () => widget.assignment,
      ),
      orElse: () => widget.assignment,
    );

    final activitiesAsync =
        ref.watch(assignmentActivitiesProvider(currentAssignment.id));
    final trackingHistoryAsync =
        ref.watch(trackingHistoryProvider(currentAssignment.id));

    final activities = activitiesAsync.valueOrNull ?? [];
    final allActivitiesCompleted =
        activities.isNotEmpty && activities.every((a) => a.isCompleted);

    return Scaffold(
      appBar: CustomTopBar.general(
        title: 'Detail Penugasan',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Assignment Info Section
          AssignmentInfoSection(assignment: currentAssignment),

          const SizedBox(height: 24),

          // Activities Section
          const Text(
            'Aktivitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          AssignmentActivityList(
            activitiesAsync: activitiesAsync,
            currentAssignment: currentAssignment,
            checkingInActivityId: _checkingInActivityId,
            togglingActivityId: _togglingActivityId,
            onCheckIn: _checkInActivity,
            onToggle: _toggleCompletion,
          ),

          // Tracking History Section
          const SizedBox(height: 24),
          const Text(
            'Tracking History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          AssignmentTrackingHistory(
            trackingHistoryAsync: trackingHistoryAsync,
          ),

          const SizedBox(height: 24),

          // Action Buttons
          if (currentAssignment.status != AssignmentStatus.completed &&
              currentAssignment.status != AssignmentStatus.cancelled)
            AssignmentActionButtons(
              allActivitiesCompleted: allActivitiesCompleted,
              onComplete: _completeAssignment,
              onCancel: _cancelAssignment,
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}