// lib/features/penugasan/presentation/pages/assignment_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';

class AssignmentDetailPage extends ConsumerStatefulWidget {
  final Assignment assignment;

  const AssignmentDetailPage({super.key, required this.assignment});

  @override
  ConsumerState<AssignmentDetailPage> createState() =>
      _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends ConsumerState<AssignmentDetailPage> {
  bool _isCheckingIn = false;

  Future<void> _checkIn(TrackingStatus status) async {
    if (widget.assignment.location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi penugasan belum ditentukan')),
      );
      return;
    }

    setState(() => _isCheckingIn = true);

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
        widget.assignment.location!,
      );

      // Validate radius
      if (status == TrackingStatus.arrived &&
          meters > widget.assignment.checkInRadius) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Anda terlalu jauh dari lokasi! '
                'Jarak: ${meters.toStringAsFixed(0)}m, '
                'Maksimal: ${widget.assignment.checkInRadius}m',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User not found');

      // Create tracking point
      final trackingPoint = TrackingPoint(
        id: '',
        assignmentId: widget.assignment.id,
        userId: userProfile.id,
        location: currentLocation,
        status: status,
        notes: _getStatusNote(status),
        photoUrl: null,
        createdAt: DateTime.now(),
      );

      // Save tracking point
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.addTrackingPoint(trackingPoint);

      // Update assignment status
      if (status == TrackingStatus.arrived &&
          widget.assignment.status == AssignmentStatus.pending) {
        await repository.updateAssignmentStatus(
          widget.assignment.id,
          AssignmentStatus.inProgress,
        );
      }

      // Refresh data
      ref.invalidate(trackingHistoryProvider);
      ref.invalidate(allAssignmentsProvider);
      ref.invalidate(pendingAssignmentsProvider);
      ref.invalidate(inProgressAssignmentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getSuccessMessage(status)),
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
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  String _getStatusNote(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return 'Check-in berhasil';
      case TrackingStatus.pending:
        return 'Pending - belum sampai lokasi';
      case TrackingStatus.cancelled:
        return 'Dibatalkan';
      default:
        return 'In transit';
    }
  }

  String _getSuccessMessage(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return 'Check-in berhasil! Selamat bekerja.';
      case TrackingStatus.pending:
        return 'Status diupdate: Pending';
      case TrackingStatus.cancelled:
        return 'Penugasan dibatalkan';
      default:
        return 'Status diupdate';
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
    final activitiesAsync =
        ref.watch(assignmentActivitiesProvider(widget.assignment.id));
    final trackingHistoryAsync =
        ref.watch(trackingHistoryProvider(widget.assignment.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penugasan'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title & Description
          Text(
            widget.assignment.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (widget.assignment.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.assignment.description!,
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
                '${DateFormat('dd MMM yyyy').format(widget.assignment.startDate)} - '
                '${DateFormat('dd MMM yyyy').format(widget.assignment.endDate)}',
          ),

          if (widget.assignment.locationName != null) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              label: 'Lokasi',
              value: widget.assignment.locationName!,
            ),
          ],

          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.info_outline,
            label: 'Status',
            value: _getStatusText(widget.assignment.status),
            valueColor: _getStatusColor(widget.assignment.status),
          ),

          // Map
          if (widget.assignment.location != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Lokasi di Map',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InteractiveMapWidget(position: widget.assignment.location!),
          ],

          // Activities
          const SizedBox(height: 24),
          const Text(
            'Aktivitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          activitiesAsync.when(
            data: (activities) => _buildActivitiesList(activities),
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
          if (widget.assignment.status != AssignmentStatus.completed)
            _buildActionButtons(),
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

  Widget _buildActivitiesList(List<AssignmentActivity> activities) {
    if (activities.isEmpty) {
      return const Text('Belum ada aktivitas');
    }

    return Column(
      children: activities.map((activity) {
        return CheckboxListTile(
          title: Text(activity.activityName),
          subtitle: activity.completedAt != null
              ? Text(
                  'Selesai: ${DateFormat('dd MMM yyyy, HH:mm').format(activity.completedAt!)}',
                  style: const TextStyle(fontSize: 12),
                )
              : null,
          value: activity.isCompleted,
          activeColor: AppColors.successColor,
          onChanged: widget.assignment.status == AssignmentStatus.completed
              ? null
              : (value) async {
                  try {
                    final repository = ref.read(assignmentRepositoryProvider);
                    await repository.toggleActivityCompletion(
                      activity.id,
                      value ?? false,
                    );
                    ref.invalidate(
                      assignmentActivitiesProvider(widget.assignment.id),
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  Widget _buildTrackingHistory(List<TrackingPoint> history) {
    if (history.isEmpty) {
      return const Text('Belum ada tracking history');
    }

    return Column(
      children: history.map((point) {
        return ListTile(
          leading: Icon(
            _getTrackingIcon(point.status),
            color: _getTrackingColor(point.status),
          ),
          title: Text(_getTrackingStatusText(point.status)),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.assignment.status == AssignmentStatus.pending) ...[
          ElevatedButton.icon(
            onPressed: _isCheckingIn ? null : () => _checkIn(TrackingStatus.arrived),
            icon: const Icon(Icons.location_on),
            label: const Text('Check-In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (widget.assignment.status == AssignmentStatus.inProgress) ...[
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
          onPressed: _isCheckingIn ? null : () => _checkIn(TrackingStatus.cancelled),
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