import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';

final assignmentActionStateProvider = StateProvider<bool>((ref) => false);

final assignmentDetailControllerProvider = Provider((ref) {
  return AssignmentDetailController(ref);
});

class AssignmentDetailController {
  final Ref ref;

  AssignmentDetailController(this.ref);

  /// Logic Check-In
  Future<void> checkInActivity(AssignmentActivity activity, String assignmentId) async {
    try {
      ref.read(assignmentActionStateProvider.notifier).state = true;

      // 1. Validasi Data
      if (!activity.requiresCheckin || activity.location == null) {
        throw Exception('Lokasi aktivitas belum ditentukan oleh sistem.');
      }
      if (activity.checkedInAt != null) {
        throw Exception('Anda sudah melakukan check-in di aktivitas ini.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final currentLocation = LatLng(position.latitude, position.longitude);
      
      final Distance distance = const Distance();
      final meters = distance.as(LengthUnit.Meter, currentLocation, activity.location!);

      if (meters > activity.checkInRadius) {
        throw Exception(
          'Jarak terlalu jauh!\n\n'
          'Posisi Anda: ${meters.toStringAsFixed(0)}m dari titik lokasi.\n'
          'Maksimal radius: ${activity.checkInRadius}m',
        );
      }

      final repository = ref.read(assignmentRepositoryProvider);
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User session not found');

      await repository.checkInActivity(activity.id, currentLocation);

      final trackingPoint = TrackingPoint(
        id: '',
        assignmentId: assignmentId,
        userId: userProfile.id,
        status: TrackingStatus.arrived,
        notes: 'Check-in di aktivitas: ${activity.activityName}',
        photoUrl: null,
        createdAt: DateTime.now(),
      );

      await repository.addTrackingPoint(trackingPoint);

      final allAssignments = await ref.read(allAssignmentsProvider.future);
      final currentAssignment = allAssignments.firstWhere((a) => a.id == assignmentId);
      
      if (currentAssignment.status == AssignmentStatus.pending) {
        await repository.updateAssignmentStatus(assignmentId, AssignmentStatus.inProgress);
      }

      ref.invalidate(trackingHistoryProvider(assignmentId));
      ref.invalidate(assignmentActivitiesProvider(assignmentId));
      ref.invalidate(allAssignmentsProvider);

    } finally {
      ref.read(assignmentActionStateProvider.notifier).state = false;
    }
  }

  Future<void> toggleCompletion(AssignmentActivity activity, String assignmentId) async {
    try {
      ref.read(assignmentActionStateProvider.notifier).state = true;

      final repository = ref.read(assignmentRepositoryProvider);
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User session not found');

      await repository.toggleActivityCompletion(activity.id, true);

      final trackingPoint = TrackingPoint(
        id: '',
        assignmentId: assignmentId,
        userId: userProfile.id,
        status: TrackingStatus.arrived,
        notes: 'Selesai aktivitas: ${activity.activityName}',
        photoUrl: null,
        createdAt: DateTime.now(),
      );

      await repository.addTrackingPoint(trackingPoint);
      
      ref.invalidate(trackingHistoryProvider(assignmentId));
      ref.invalidate(assignmentActivitiesProvider(assignmentId));

    } finally {
      ref.read(assignmentActionStateProvider.notifier).state = false;
    }
  }

  Future<void> updateAssignmentStatus({
    required String assignmentId,
    required AssignmentStatus status,
    required String notes,
    String? ulokId,
  }) async {
    try {
      ref.read(assignmentActionStateProvider.notifier).state = true;
      
      final repository = ref.read(assignmentRepositoryProvider);
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User session not found');

      if (status == AssignmentStatus.cancelled && ulokId != null) {
        await repository.removeUlokPenanggungjawab(ulokId);
      }

      // Buat tracking point penutup
      if (status == AssignmentStatus.cancelled || status == AssignmentStatus.completed) {
        final trackingStatus = status == AssignmentStatus.cancelled 
            ? TrackingStatus.cancelled 
            : TrackingStatus.arrived;

        final trackingPoint = TrackingPoint(
          id: '',
          assignmentId: assignmentId,
          userId: userProfile.id,
          status: trackingStatus,
          notes: notes,
          photoUrl: null,
          createdAt: DateTime.now(),
        );
        await repository.addTrackingPoint(trackingPoint);
      }

      await repository.updateAssignmentStatus(assignmentId, status);
      
      ref.invalidate(allAssignmentsProvider);
      ref.invalidate(trackingHistoryProvider(assignmentId));
    } finally {
      ref.read(assignmentActionStateProvider.notifier).state = false;
    }
  }

  Future<void> submitExternalCheckResult({
    required String assignmentId,
    required String? ulokId,
    required bool isApproved,
    required String notes,
  }) async {
    try {
      ref.read(assignmentActionStateProvider.notifier).state = true;

      if (ulokId == null) {
        throw Exception('ID Usulan Lokasi Eksternal tidak ditemukan dalam penugasan ini.');
      }

      final repository = ref.read(assignmentRepositoryProvider);
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User session not found');

      final statusUlok = isApproved ? 'OK' : 'NOK';
      await repository.updateUlokStatus(ulokId, statusUlok, userProfile.id);

      final actionText = isApproved ? 'Menyetujui (OK)' : 'Menolak (NOK)';
      
      final trackingPoint = TrackingPoint(
        id: '',
        assignmentId: assignmentId,
        userId: userProfile.id,
        status: TrackingStatus.arrived,
        notes: 'External Check Selesai: $actionText. Catatan: $notes',
        photoUrl: null,
        createdAt: DateTime.now(),
      );
      
      await repository.addTrackingPoint(trackingPoint);
      await repository.updateAssignmentStatus(assignmentId, AssignmentStatus.completed);

      ref.invalidate(allAssignmentsProvider);
      ref.invalidate(trackingHistoryProvider(assignmentId));

    } finally {
      ref.read(assignmentActionStateProvider.notifier).state = false;
    }
  }
}