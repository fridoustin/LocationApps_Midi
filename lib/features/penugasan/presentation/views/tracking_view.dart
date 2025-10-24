// ignore_for_file: deprecated_member_use

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/presentation/pages/assignment_detail_page.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingView extends ConsumerStatefulWidget {
  const TrackingView({super.key});

  @override
  ConsumerState<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends ConsumerState<TrackingView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  final MapController _mapController = MapController();
  bool _isCardExpanded = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak')),
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allAssignmentsAsync = ref.watch(allAssignmentsProvider);

    return allAssignmentsAsync.when(
      data: (allAssignments) {
        // Filter: pending + in_progress only
        final activeAssignments = allAssignments
            .where((a) =>
                a.status == AssignmentStatus.pending ||
                a.status == AssignmentStatus.inProgress)
            .toList();

        // Get most recent pending assignment
        final pendingAssignments = activeAssignments
            .where((a) => a.status == AssignmentStatus.pending)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final mostRecentPending =
            pendingAssignments.isNotEmpty ? pendingAssignments.first : null;

        return Stack(
          children: [
            _buildMap(activeAssignments),
            
            // Top bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _weekRangeBadge(height: 40),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    heroTag: 'refreshLocation',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location,
                        color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),

            // Bottom card for pending assignment
            if (mostRecentPending != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildPendingCard(mostRecentPending),
              ),

            // Loading indicator
            if (_isLoadingLocation)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildPendingCard(Assignment assignment) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            setState(() => _isCardExpanded = false);
          } else if (details.primaryDelta! < -10) {
            setState(() => _isCardExpanded = true);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              InkWell(
                onTap: () {
                  setState(() => _isCardExpanded = !_isCardExpanded);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      if (!_isCardExpanded) ...[
                        const SizedBox(height: 8),
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Content
              if (_isCardExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Belum Dikerjakan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warningColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        assignment.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (assignment.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          assignment.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            '${DateFormat('dd MMM').format(assignment.startDate)} - ${DateFormat('dd MMM yyyy').format(assignment.endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aktivitas:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildActivityList(assignment),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssignmentDetailPage(
                                  assignment: assignment),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Lihat Detail Penugasan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(Assignment assignment) {
    final activitiesAsync = ref.watch(assignmentActivitiesProvider(assignment.id));

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Text('Belum ada aktivitas',
              style: TextStyle(fontSize: 12, color: Colors.grey));
        }

        return Column(
          children: activities.take(3).map((activity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () {
                  if (activity.location != null) {
                    _showActivityBottomSheet(activity, assignment);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        activity.checkedInAt != null
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: activity.checkedInAt != null
                            ? AppColors.successColor
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.activityName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (activity.locationName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                activity.locationName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (activity.location != null)
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      )),
      error: (_, __) => const Text('Error loading activities'),
    );
  }

  Widget _weekRangeBadge({double height = 40}) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final fmt = DateFormat('dd MMM yyyy');
    final label = '${fmt.format(monday)} - ${fmt.format(sunday)}';

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[2],
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today,
              size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<Assignment> assignments) {
    final center = _currentLocation ?? const LatLng(-6.2088, 106.8456);

    return FutureBuilder<List<_ActivityMarkerData>>(
      future: _collectActivities(assignments),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final activityMarkers = snapshot.data!;

        return FlutterMap(
          mapController: _mapController,
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
            MarkerLayer(
              markers: [
                // Current location marker
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.blue,
                      size: 40,
                    ),
                  ),

                // Activity markers
                ...activityMarkers.map((markerData) {
                  final activity = markerData.activity;
                  final assignment = markerData.assignment;

                  return Marker(
                    point: activity.location!,
                    width: 140,
                    height: 140,
                    child: GestureDetector(
                      onTap: () =>
                          _showActivityBottomSheet(activity, assignment),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Marker bubble
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getActivityStatusColor(
                                  activity, assignment.status),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  assignment.title,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Marker pin
                          Icon(
                            activity.isCompleted
                                ? Icons.check_circle
                                : Icons.location_on,
                            color: _getActivityStatusColor(
                                activity, assignment.status),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  );
                })
              ],
            ),
          ],
        );
      },
    );
  }

  Future<List<_ActivityMarkerData>> _collectActivities(
      List<Assignment> assignments) async {
    final List<_ActivityMarkerData> result = [];

    for (final assignment in assignments) {
      try {
        final activities =
            await ref.read(assignmentActivitiesProvider(assignment.id).future);

        for (final activity in activities) {
          // Only show activities that have location
          if (activity.location != null) {
            result.add(_ActivityMarkerData(
              activity: activity,
              assignment: assignment,
            ));
          }
        }
      } catch (e) {
        debugPrint('Error fetching activities for ${assignment.id}: $e');
      }
    }

    return result;
  }

  Color _getActivityStatusColor(
      AssignmentActivity activity, AssignmentStatus assignmentStatus) {
    if (activity.isCompleted) {
      return AppColors.successColor;
    } else if (activity.checkedInAt != null) {
      return AppColors.blue;
    } else if (assignmentStatus == AssignmentStatus.pending) {
      return AppColors.warningColor;
    } else {
      return AppColors.warningColor;
    }
  }

  void _showActivityBottomSheet(
      AssignmentActivity activity, Assignment assignment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Activity name
                Text(
                  activity.activityName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Assignment title
                Text(
                  'Penugasan: ${assignment.title}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getActivityStatusColor(
                                activity, assignment.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getActivityStatusText(activity),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getActivityStatusColor(
                              activity, assignment.status),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Location info
                if (activity.locationName != null) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activity.locationName!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Distance info
                if (_currentLocation != null && activity.location != null) ...[
                  FutureBuilder<double>(
                    future: _calculateDistance(activity.location!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final distance = snapshot.data!;
                        final isInRadius = distance <= activity.checkInRadius;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isInRadius
                                ? AppColors.successColor.withOpacity(0.1)
                                : AppColors.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isInRadius
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: isInRadius
                                    ? AppColors.successColor
                                    : AppColors.warningColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isInRadius
                                      ? 'Anda berada di lokasi (${distance.toStringAsFixed(0)}m)'
                                      : 'Jarak: ${distance.toStringAsFixed(0)}m (Maks: ${activity.checkInRadius}m)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isInRadius
                                        ? AppColors.successColor
                                        : AppColors.warningColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Check-in info
                if (activity.checkedInAt != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.successColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Check-in: ${DateFormat('dd MMM yyyy, HH:mm').format(activity.checkedInAt!)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: activity.location != null
                            ? () {
                                Navigator.pop(context);
                                _openDirections(activity.location!);
                              }
                            : null,
                        icon: const Icon(Icons.directions),
                        label: const Text('Petunjuk'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side:
                              const BorderSide(color: AppColors.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssignmentDetailPage(
                                  assignment: assignment),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Detail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getActivityStatusText(AssignmentActivity activity) {
    if (activity.isCompleted) {
      return 'Selesai';
    } else if (activity.checkedInAt != null) {
      return 'Sudah Check-in';
    } else {
      return 'Perlu Check-in';
    }
  }

  Future<double> _calculateDistance(LatLng destination) async {
    if (_currentLocation == null) return double.infinity;

    final distance = Distance();
    return distance.as(LengthUnit.Meter, _currentLocation!, destination);
  }

  Future<void> _openDirections(LatLng destination) async {
    final lat = destination.latitude;
    final lng = destination.longitude;

    try {
      if (Platform.isIOS) {
        final appleMapsScheme = Uri.parse('maps://?daddr=$lat,$lng');
        final appleMapsWeb =
            Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');

        if (await canLaunchUrl(appleMapsScheme)) {
          await launchUrl(appleMapsScheme,
              mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(appleMapsWeb)) {
          await launchUrl(appleMapsWeb, mode: LaunchMode.externalApplication);
          return;
        }
      } else if (Platform.isAndroid) {
        final googleMapsScheme = Uri.parse('google.navigation:q=$lat,$lng');
        final googleMapsWeb = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

        if (await canLaunchUrl(googleMapsScheme)) {
          await launchUrl(googleMapsScheme,
              mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(googleMapsWeb)) {
          await launchUrl(googleMapsWeb,
              mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        final web = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
        if (await canLaunchUrl(web)) {
          await launchUrl(web, mode: LaunchMode.externalApplication);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Tidak dapat membuka aplikasi peta di perangkat ini')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka peta: $e')),
        );
      }
    }
  }
}

// Helper class to store activity with its assignment
class _ActivityMarkerData {
  final AssignmentActivity activity;
  final Assignment assignment;

  _ActivityMarkerData({
    required this.activity,
    required this.assignment,
  });
}