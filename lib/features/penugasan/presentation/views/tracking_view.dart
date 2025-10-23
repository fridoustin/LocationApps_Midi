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
  String _selectedFilter = 'active';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // Check permission
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
    final assignmentsAsync = ref.watch(allAssignmentsProvider);

    return Stack(
      children: [
        _buildMap(assignmentsAsync),
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

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterButton(),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'refreshLocation',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ],
          ),
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
  }

  Widget _buildFilterButton() {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        tooltip: 'Filter assignments',
        initialValue: _selectedFilter,
        onSelected: (v) {
          setState(() {
            _selectedFilter = v;
          });
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'active', 
            child: Text(
              'Active (default)'
            )
          ),
          const PopupMenuItem(
            value: 'all', 
            child: Text(
              'All assignments'
            )
          ),
          const PopupMenuItem(
            value: 'past', 
            child: Text(
              'Past only'
            )
          ),
        ],
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: kElevationToShadow[2],
          ),
          child: Icon(Icons.filter_list, size: 20, color: AppColors.primaryColor),
        ),
      ),
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
          const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryColor),
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

  Widget _buildMap(AsyncValue<List<Assignment>> assignmentsAsync) {
    return assignmentsAsync.when(
      data: (assignments) {
        final center = _currentLocation ?? const LatLng(-6.2088, 106.8456);
        final now = DateTime.now();
        final filtered = assignments.where((a) {
          if (a.location == null) return false;
          final end = a.endDate;
          if (_selectedFilter == 'all') return true;
          if (_selectedFilter == 'past') return end.isBefore(now);
          return !end.isBefore(now);
        }).toList();

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
                ...filtered.map((assignment) {
                  return Marker(
                    point: assignment.location!,
                    width: 120,
                    height: 120,
                    child: GestureDetector(
                      onTap: () => _showAssignmentBottomSheet(assignment),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Marker bubble
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(assignment.status),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              assignment.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Marker pin
                          Icon(
                            Icons.location_on,
                            color: _getStatusColor(assignment.status),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
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

  void _showAssignmentBottomSheet(Assignment assignment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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

            // Title
            Text(
              assignment.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(assignment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(assignment.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(assignment.status),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location
            if (assignment.locationName != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      assignment.locationName!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Distance info
            if (_currentLocation != null && assignment.location != null) ...[
              FutureBuilder<double>(
                future: _calculateDistance(assignment.location!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final distance = snapshot.data!;
                    final isInRadius = distance <= assignment.checkInRadius;
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
                            isInRadius ? Icons.check_circle : Icons.info_outline,
                            color: isInRadius ? AppColors.successColor : AppColors.warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isInRadius
                                  ? 'Anda berada di lokasi (${distance.toStringAsFixed(0)}m)'
                                  : 'Jarak: ${distance.toStringAsFixed(0)}m (Maks: ${assignment.checkInRadius}m)',
                              style: TextStyle(
                                fontSize: 13,
                                color: isInRadius ? AppColors.successColor : AppColors.warningColor,
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

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: assignment.location != null
                        ? () {
                            Navigator.pop(context);
                            _openDirections(assignment.location!);
                          }
                        : null,
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor),
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
                          builder: (_) => AssignmentDetailPage(assignment: assignment),
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
    );
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
        // Prefer native Apple Maps scheme, fallback ke apple web
        final appleMapsScheme = Uri.parse('maps://?daddr=$lat,$lng');
        final appleMapsWeb = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');

        if (await canLaunchUrl(appleMapsScheme)) {
          await launchUrl(appleMapsScheme, mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(appleMapsWeb)) {
          await launchUrl(appleMapsWeb, mode: LaunchMode.externalApplication);
          return;
        }
      } else if (Platform.isAndroid) {
        // Prefer native Google Maps navigation intent, fallback ke google maps web
        final googleMapsScheme = Uri.parse('google.navigation:q=$lat,$lng');
        final googleMapsWeb = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

        if (await canLaunchUrl(googleMapsScheme)) {
          await launchUrl(googleMapsScheme, mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(googleMapsWeb)) {
          await launchUrl(googleMapsWeb, mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        // Other platforms (web, desktop) -> open google maps web
        final web = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
        if (await canLaunchUrl(web)) {
          await launchUrl(web, mode: LaunchMode.externalApplication);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta di perangkat ini')),
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

  String _getStatusText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Belum Dikerjakan';
      case AssignmentStatus.inProgress:
        return 'Sedang Dikerjakan';
      case AssignmentStatus.completed:
        return 'Selesai';
      case AssignmentStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}