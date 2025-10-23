// lib/features/penugasan/presentation/pages/assignment_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/activity_item_widget.dart';

class AssignmentDetailPage extends ConsumerStatefulWidget {
  final Assignment assignment;

  const AssignmentDetailPage({super.key, required this.assignment});

  @override
  ConsumerState<AssignmentDetailPage> createState() =>
      _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends ConsumerState<AssignmentDetailPage> {
  String? _checkingInActivityId;
  String? _togglingActivityId;
  
  Future<void> _checkInActivity(AssignmentActivity activity) async {
    if (!activity.requiresCheckin || activity.location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi aktivitas belum ditentukan')),
      );
      return;
    }
    
    // Cek jika sudah check-in
    if (activity.checkedInAt != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas ini sudah di-checkin')),
      );
      return;
    }

    setState(() => _checkingInActivityId = activity.id);

    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final currentLocation = LatLng(position.latitude, position.longitude);

      // Calculate distance
      final Distance distance = const Distance();
      final meters = distance.as(
        LengthUnit.Meter,
        currentLocation,
        activity.location!,
      );

      // Validate radius
      if (meters > activity.checkInRadius) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Anda terlalu jauh dari lokasi! '
                'Jarak: ${meters.toStringAsFixed(0)}m, '
                'Maksimal: ${activity.checkInRadius}m',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User not found');
      
      final repository = ref.read(assignmentRepositoryProvider);

      await repository.checkInActivity(activity.id, currentLocation);

      final trackingPoint = TrackingPoint(
        id: '', 
        assignmentId: widget.assignment.id,
        userId: userProfile.id,
        location: currentLocation,
        status: TrackingStatus.arrived,
        notes: 'Check-in di aktivitas: ${activity.activityName}',
        photoUrl: null,
        createdAt: DateTime.now(),
      );
      await repository.addTrackingPoint(trackingPoint);

      if (widget.assignment.status == AssignmentStatus.pending) {
        await repository.updateAssignmentStatus(
          widget.assignment.id,
          AssignmentStatus.inProgress,
        );
      }

      ref.invalidate(trackingHistoryProvider(widget.assignment.id));
      ref.invalidate(assignmentActivitiesProvider(widget.assignment.id));
      ref.invalidate(allAssignmentsProvider); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in di ${activity.activityName} berhasil!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _checkingInActivityId = null);
    }
  }

  Future<void> _toggleCompletion(AssignmentActivity activity, bool value) async {
    if (value == false) return; 

    if (value && !activity.canBeCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan check-in terlebih dahulu untuk menyelesaikan aktivitas ini'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Aktivitas?'),
        content: Text('Apakah Anda yakin ingin menyelesaikan aktivitas "${activity.activityName}"?'),
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
            child: const Text('Ya, Selesaikan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _togglingActivityId = activity.id);

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User not found');

      await repository.toggleActivityCompletion(activity.id, true);
      
      final trackingPoint = TrackingPoint(
        id: '',
        assignmentId: widget.assignment.id,
        userId: userProfile.id,
        location: activity.checkedInLocation ?? activity.location ?? const LatLng(0,0), 
        status: TrackingStatus.arrived, 
        notes: 'Selesai aktivitas: ${activity.activityName}', 
        photoUrl: null,
        createdAt: DateTime.now(), 
      );
      await repository.addTrackingPoint(trackingPoint);

      ref.invalidate(trackingHistoryProvider(widget.assignment.id));
      ref.invalidate(assignmentActivitiesProvider(activity.assignmentId));

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aktivitas "${activity.activityName}" berhasil diselesaikan.'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingActivityId = null);
    }
  }

  Future<void> _cancelAssignment() async {
    final confirmed = await showDialog<bool>(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User not found');

      final repository = ref.read(assignmentRepositoryProvider);
      
      // Add tracking point for cancellation
      final trackingPoint = TrackingPoint(
        id: '',
        assignmentId: widget.assignment.id,
        userId: userProfile.id,
        location: widget.assignment.location ?? const LatLng(0, 0),
        status: TrackingStatus.cancelled,
        notes: 'Penugasan dibatalkan oleh user',
        photoUrl: null,
        createdAt: DateTime.now(),
      );
      
      await repository.addTrackingPoint(trackingPoint);
      
      // Update assignment status to cancelled
      await repository.updateAssignmentStatus(
        widget.assignment.id,
        AssignmentStatus.cancelled,
      );

      // Refresh all providers
      ref.invalidate(allAssignmentsProvider);
      ref.invalidate(pendingAssignmentsProvider);
      ref.invalidate(inProgressAssignmentsProvider);
      ref.invalidate(completedAssignmentsProvider);
      ref.invalidate(trackingHistoryProvider(widget.assignment.id));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penugasan berhasil dibatalkan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completeAssignment() async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed != true) return;

    try {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.updateAssignmentStatus(
        widget.assignment.id,
        AssignmentStatus.completed,
      );

      ref.invalidate(completedAssignmentsProvider);
      ref.invalidate(inProgressAssignmentsProvider);
      ref.invalidate(allAssignmentsProvider);
      ref.invalidate(trackingHistoryProvider(widget.assignment.id));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penugasan berhasil diselesaikan!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch assignment updates
    final allAssignmentsAsync = ref.watch(allAssignmentsProvider);
    
    // Find updated assignment from provider
    final Assignment currentAssignment = allAssignmentsAsync.maybeWhen(
      data: (assignments) {
        return assignments.firstWhere(
          (a) => a.id == widget.assignment.id,
          orElse: () => widget.assignment,
        );
      },
      orElse: () => widget.assignment,
    );
    
    final activitiesAsync =
        ref.watch(assignmentActivitiesProvider(currentAssignment.id));
    final trackingHistoryAsync =
        ref.watch(trackingHistoryProvider(currentAssignment.id));

    final activities = activitiesAsync.valueOrNull ?? [];
    final allActivitiesCompleted = activities.isNotEmpty &&
        activities.every((a) => a.isCompleted);

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
          Text(
            currentAssignment.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (currentAssignment.description != null) ...[
            const SizedBox(height: 8),
            Text(
              currentAssignment.description!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Info Cards
          _buildInfoCard(
            icon: Icons.calendar_today,
            label: 'Periode',
            value:
                '${DateFormat('dd MMM yyyy').format(currentAssignment.startDate)} - '
                '${DateFormat('dd MMM yyyy').format(currentAssignment.endDate)}',
          ),

          if (currentAssignment.locationName != null) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              label: 'Lokasi',
              value: currentAssignment.locationName!,
            ),
          ],

          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.info_outline,
            label: 'Status',
            value: _getStatusText(currentAssignment.status),
            valueColor: _getStatusColor(currentAssignment.status),
          ),

          // Map
          if (currentAssignment.location != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Lokasi di Map',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InteractiveMapWidget(position: currentAssignment.location!),
          ],

          // Activities
          const SizedBox(height: 24),
          const Text(
            'Aktivitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          activitiesAsync.when(
            data: (activities) => _buildActivitiesList(activities, currentAssignment),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),

          // Tracking History
          const SizedBox(height: 24),
          const Text(
            'Tracking History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          trackingHistoryAsync.when(
            data: (history) => _buildTrackingHistory(history),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          if (currentAssignment.status != AssignmentStatus.completed &&
              currentAssignment.status != AssignmentStatus.cancelled)
            _buildActionButtons(currentAssignment, allActivitiesCompleted),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<AssignmentActivity> activities, Assignment currentAssignment) {
    if (activities.isEmpty) {
      return const Text('Belum ada aktivitas');
    }

    return Column(
      children: activities.map((activity) {
        return ActivityItemWidget(
          activity: activity,
          isAssignmentCompleted: currentAssignment.status == AssignmentStatus.completed ||
              currentAssignment.status == AssignmentStatus.cancelled,
          isCheckingIn: _checkingInActivityId == activity.id,
          isToggling: _togglingActivityId == activity.id,
          onCheckIn: () => _checkInActivity(activity),
          onToggle: (value) => _toggleCompletion(activity, value),
        );
      }).toList(),
    );
  }

  Widget _buildTrackingHistory(List<TrackingPoint> history) {
    if (history.isEmpty) {
      return const Text('Belum ada tracking history');
    }
    
    final sortedHistory = history.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: sortedHistory.map((point) {
        return ListTile(
          leading: Icon(
            _getTrackingIcon(point.status),
            color: _getTrackingColor(point.status),
          ),
          title: Text(point.notes ?? _getTrackingStatusText(point.status)),
          subtitle: Text(
            DateFormat('dd MMM yyyy, HH:mm').format(point.createdAt),
          ),
          trailing: point.notes != null
              ? Tooltip(
                  message: point.notes!,
                  child: const Icon(Icons.info_outline, size: 20),
                )
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(Assignment currentAssignment, bool allActivitiesCompleted) {
    return Column(
      children: [
        if (allActivitiesCompleted) ...[
          ElevatedButton.icon(
            onPressed: _completeAssignment,
            icon: const Icon(Icons.check_circle),
            label: const Text('Selesaikan Penugasan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
          const SizedBox(height: 12),
        ],

        OutlinedButton.icon(
          onPressed: _cancelAssignment,
          icon: const Icon(Icons.cancel),
          label: const Text('Batalkan Penugasan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
      ],
    );
  }

  String _getStatusText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Belum Dikerjakan';
      case AssignmentStatus.inProgress:
        return 'Sedang Dikerjakan';
      case AssignmentStatus.completed:
        return 'Sudah Selesai';
      case AssignmentStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return AppColors.warningColor;
      case AssignmentStatus.inProgress:
        return AppColors.blue;
      case AssignmentStatus.completed:
        return AppColors.successColor;
      case AssignmentStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getTrackingIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return Icons.check_circle;
      case TrackingStatus.pending:
        return Icons.pending;
      case TrackingStatus.cancelled:
        return Icons.cancel;
      case TrackingStatus.inTransit:
        return Icons.directions_walk;
    }
  }

  Color _getTrackingColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return AppColors.successColor;
      case TrackingStatus.pending:
        return AppColors.warningColor;
      case TrackingStatus.cancelled:
        return Colors.red;
      case TrackingStatus.inTransit:
        return AppColors.blue;
    }
  }

  String _getTrackingStatusText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return 'Check-in berhasil';
      case TrackingStatus.pending:
        return 'Pending';
      case TrackingStatus.cancelled:
        return 'Dibatalkan';
      case TrackingStatus.inTransit:
        return 'Dalam perjalanan';
    }
  }
}