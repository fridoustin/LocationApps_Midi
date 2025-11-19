import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/presentation/pages/assignment_detail_page.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/tracking/tracking_map.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/tracking/tracking_controls.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/tracking/tracking_states.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/tracking/assignment_list_sheet.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/tracking/activity_detail_sheet.dart';
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

  // State
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
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
        _showError('Gagal mendapatkan lokasi: $e');
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showError('Izin lokasi ditolak');
        }
        return false;
      }
    }

    return true;
  }

  void _centerToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      _showError('Lokasi tidak tersedia');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Assignment> _filterActiveAssignments(List<Assignment> assignments) {
    return assignments
        .where((a) =>
            a.type != AssignmentType.self &&
            (a.status == AssignmentStatus.pending ||
            a.status == AssignmentStatus.inProgress))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _showAssignmentListSheet(List<Assignment> assignments) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AssignmentListSheet(
        assignments: assignments,
        onAssignmentTap: (assignment) {
          Navigator.pop(context);
          _zoomToAssignment(assignment);
        },
      ),
    );
  }

  void _showActivityBottomSheet(
    AssignmentActivity activity,
    Assignment assignment,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ActivityDetailSheet(
        activity: activity,
        assignment: assignment,
        currentLocation: _currentLocation,
        onNavigate: () {
          Navigator.pop(context);
          _openDirections(activity.location!);
        },
        onViewDetail: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignmentDetailPage(assignment: assignment),
            ),
          );
        },
      ),
    );
  }

  void _zoomToAssignment(Assignment assignment) async {
    try {
      final activities = await ref.read(
        assignmentActivitiesProvider(assignment.id).future,
      );

      final locatedActivities =
          activities.where((a) => a.location != null).toList();

      if (locatedActivities.isEmpty) return;

      if (locatedActivities.length == 1) {
        _mapController.move(locatedActivities.first.location!, 15.0);
      } else {
        final bounds = LatLngBounds.fromPoints(
          locatedActivities.map((a) => a.location!).toList(),
        );
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(80),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error zooming to assignment: $e');
    }
  }

  Future<void> _openDirections(LatLng destination) async {
    final lat = destination.latitude;
    final lng = destination.longitude;

    try {
      Uri? uri;

      if (Platform.isIOS) {
        uri = Uri.parse('maps://?daddr=$lat,$lng');
        if (!await canLaunchUrl(uri)) {
          uri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');
        }
      } else if (Platform.isAndroid) {
        uri = Uri.parse('google.navigation:q=$lat,$lng');
        if (!await canLaunchUrl(uri)) {
          uri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
          );
        }
      }

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No navigation app available');
      }
    } catch (e) {
      if (mounted) {
        _showError('Tidak dapat membuka aplikasi navigasi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allAssignmentsAsync = ref.watch(allAssignmentsProvider);

    return allAssignmentsAsync.when(
      data: (allAssignments) => _buildTrackingContent(allAssignments),
      loading: () => const TrackingLoadingWidget(),
      error: (err, stack) => TrackingErrorWidget(error: err.toString()),
    );
  }

  Widget _buildTrackingContent(List<Assignment> allAssignments) {
    final activeAssignments = _filterActiveAssignments(allAssignments);

    return Stack(
      children: [
        // Map
        TrackingMap(
          currentLocation: _currentLocation,
          mapController: _mapController,
          assignments: activeAssignments,
          onActivityTap: _showActivityBottomSheet,
        ),

        // Top Controls
        TrackingTopControls(assignments: activeAssignments),

        // Side Controls
        TrackingSideControls(
          assignmentCount: activeAssignments.length,
          onLocationPressed: _centerToCurrentLocation,
          onListPressed: () => _showAssignmentListSheet(activeAssignments),
        ),

        // Empty State
        if (activeAssignments.isEmpty && !_isLoadingLocation)
          const TrackingEmptyState(),

        // Loading Overlay
        if (_isLoadingLocation) const TrackingLoadingOverlay(),
      ],
    );
  }
}