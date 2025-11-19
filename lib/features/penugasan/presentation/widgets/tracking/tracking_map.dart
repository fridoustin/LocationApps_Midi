import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_marker.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/presentation/providers/tracking_provider.dart';

class TrackingMap extends ConsumerWidget {
  final LatLng? currentLocation;
  final MapController mapController;
  final List<Assignment> assignments;
  final Function(AssignmentActivity, Assignment) onActivityTap;

  const TrackingMap({
    super.key,
    required this.currentLocation,
    required this.mapController,
    required this.assignments,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final center = currentLocation ?? const LatLng(-6.2088, 106.8456);
    final activitiesAsync = ref.watch(trackingActivitiesProvider(assignments));

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.midi.location',
        ),
        activitiesAsync.when(
          data: (activityMarkers) => MarkerLayer(
            markers: [
              if (currentLocation != null)
                _buildCurrentLocationMarker(currentLocation!),
              ...activityMarkers.map(
                (data) => _buildActivityMarker(data, onActivityTap),
              ),
            ],
          ),
          loading: () => const MarkerLayer(markers: []),
          error: (_, __) => const MarkerLayer(markers: []),
        ),
      ],
    );
  }

  Marker _buildCurrentLocationMarker(LatLng location) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withOpacity(0.2),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withOpacity(0.5),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildActivityMarker(
    ActivityMarkerData data,
    Function(AssignmentActivity, Assignment) onTap,
  ) {
    final activity = data.activity;
    final assignment = data.assignment;
    final statusColor = _getActivityStatusColor(activity, assignment.status);

    return Marker(
      point: activity.location!,
      width: 160,
      height: 160,
      child: GestureDetector(
        onTap: () => onTap(activity, assignment),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.85)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.activityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    assignment.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              activity.isCompleted ? Icons.check_circle : Icons.location_on,
              color: statusColor,
              size: 36,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityStatusColor(
    AssignmentActivity activity,
    AssignmentStatus assignmentStatus,
  ) {
    if (activity.isCompleted) return AppColors.successColor;
    if (activity.checkedInAt != null) return AppColors.blue;
    if (assignmentStatus == AssignmentStatus.pending) {
      return AppColors.warningColor;
    }
    return AppColors.primaryColor;
  }
}