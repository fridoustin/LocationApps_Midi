// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';

class ActivityDetailSheet extends StatelessWidget {
  final AssignmentActivity activity;
  final Assignment assignment;
  final LatLng? currentLocation;
  final VoidCallback onNavigate;
  final VoidCallback onViewDetail;

  const ActivityDetailSheet({
    super.key,
    required this.activity,
    required this.assignment,
    required this.currentLocation,
    required this.onNavigate,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              _ActivityHeader(activity: activity, assignment: assignment),
              const SizedBox(height: 20),
              _AssignmentInfoCard(assignment: assignment),
              const SizedBox(height: 20),
              if (activity.locationName != null) ...[
                _LocationInfoCard(locationName: activity.locationName!),
                const SizedBox(height: 12),
              ],
              if (currentLocation != null && activity.location != null) ...[
                _DistanceInfoCard(
                  currentLocation: currentLocation!,
                  activityLocation: activity.location!,
                  checkInRadius: activity.checkInRadius,
                ),
                const SizedBox(height: 12),
              ],
              if (activity.checkedInAt != null) ...[
                _CheckInInfoCard(checkedInAt: activity.checkedInAt!),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 8),
              _ActionButtons(
                hasLocation: activity.location != null,
                onNavigate: onNavigate,
                onViewDetail: onViewDetail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  final AssignmentActivity activity;
  final Assignment assignment;

  const _ActivityHeader({
    required this.activity,
    required this.assignment,
  });

  Color get _statusColor {
    if (activity.isCompleted) return AppColors.successColor;
    if (activity.checkedInAt != null) return AppColors.blue;
    return AppColors.warningColor;
  }

  IconData get _statusIcon {
    if (activity.isCompleted) return Icons.check_circle;
    if (activity.checkedInAt != null) return Icons.location_on;
    return Icons.pending;
  }

  String get _statusText {
    if (activity.isCompleted) return 'Sudah Selesai';
    if (activity.checkedInAt != null) return 'Sudah Check-in';
    return 'Belum Check-in';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_statusColor, _statusColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _statusColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(_statusIcon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.activityName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssignmentInfoCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentInfoCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment,
              size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penugasan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationInfoCard extends StatelessWidget {
  final String locationName;

  const _LocationInfoCard({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.place,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceInfoCard extends StatelessWidget {
  final LatLng currentLocation;
  final LatLng activityLocation;
  final int checkInRadius;

  const _DistanceInfoCard({
    required this.currentLocation,
    required this.activityLocation,
    required this.checkInRadius,
  });

  @override
  Widget build(BuildContext context) {
    final distance = Distance();
    final meters =
        distance.as(LengthUnit.Meter, currentLocation, activityLocation);
    final isInRadius = meters <= checkInRadius;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isInRadius
              ? [
                  AppColors.successColor.withOpacity(0.15),
                  AppColors.successColor.withOpacity(0.05),
                ]
              : [
                  AppColors.warningColor.withOpacity(0.15),
                  AppColors.warningColor.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInRadius
              ? AppColors.successColor.withOpacity(0.3)
              : AppColors.warningColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isInRadius ? AppColors.successColor : AppColors.warningColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInRadius ? Icons.check_circle : Icons.social_distance,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInRadius ? 'Anda Berada di Lokasi' : 'Jarak dari Lokasi',
                  style: TextStyle(
                    fontSize: 13,
                    color: isInRadius
                        ? AppColors.successColor
                        : AppColors.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isInRadius
                      ? '${meters.toStringAsFixed(0)} meter dari titik'
                      : '${meters.toStringAsFixed(0)}m (Radius: ${checkInRadius}m)',
                  style: TextStyle(
                    fontSize: 15,
                    color: isInRadius
                        ? AppColors.successColor
                        : AppColors.warningColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInInfoCard extends StatelessWidget {
  final DateTime checkedInAt;

  const _CheckInInfoCard({required this.checkedInAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.successColor,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sudah Check-in',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMM yyyy\nHH:mm WIB').format(checkedInAt),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.successColor,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool hasLocation;
  final VoidCallback onNavigate;
  final VoidCallback onViewDetail;

  const _ActionButtons({
    required this.hasLocation,
    required this.onNavigate,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasLocation ? onNavigate : null,
            icon: const Icon(Icons.directions, size: 20),
            label: const Text(
              'Navigasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onViewDetail,
            icon: const Icon(Icons.info_outline, size: 20),
            label: const Text(
              'Detail Tugas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}