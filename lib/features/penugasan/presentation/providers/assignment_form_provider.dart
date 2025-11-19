import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/activity_location_dialog.dart';

enum AssignmentFormStatus { initial, loading, success, error }

class AssignmentFormState {
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> selectedActivityIds;
  final Map<String, ActivityLocationData> activityLocations;
  final AssignmentFormStatus status;
  final String? errorMessage;
  final String? successMessage;

  const AssignmentFormState({
    this.title = '',
    this.description = '',
    this.startDate,
    this.endDate,
    this.selectedActivityIds = const {},
    this.activityLocations = const {},
    this.status = AssignmentFormStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  AssignmentFormState copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? selectedActivityIds,
    Map<String, ActivityLocationData>? activityLocations,
    AssignmentFormStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AssignmentFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedActivityIds: selectedActivityIds ?? this.selectedActivityIds,
      activityLocations: activityLocations ?? this.activityLocations,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AssignmentFormNotifier extends StateNotifier<AssignmentFormState> {
  final Assignment? initialAssignment;
  final Ref ref;

  AssignmentFormNotifier(this.initialAssignment, this.ref)
      : super(const AssignmentFormState());

  void initialize() {
    if (initialAssignment != null) {
      _loadInitialData();
    } else {
      _setDefaultDates();
    }
  }

  void _loadInitialData() {
    state = state.copyWith(
      title: initialAssignment!.title,
      description: initialAssignment!.description ?? '',
      startDate: initialAssignment!.startDate,
      endDate: initialAssignment!.endDate,
    );
  }

  void _setDefaultDates() {
    final today = DateTime.now();
    state = state.copyWith(
      startDate: DateTime(today.year, today.month, today.day),
      endDate: DateTime(today.year, today.month, today.day),
    );
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void toggleActivitySelection(String activityId, bool isSelected) {
    final newSelection = Set<String>.from(state.selectedActivityIds);
    final newLocations = Map<String, ActivityLocationData>.from(
      state.activityLocations,
    );

    if (isSelected) {
      newSelection.add(activityId);
    } else {
      newSelection.remove(activityId);
      newLocations.remove(activityId);
    }

    state = state.copyWith(
      selectedActivityIds: newSelection,
      activityLocations: newLocations,
    );
  }

  void setActivityLocation(String activityId, ActivityLocationData data) {
    final newLocations = Map<String, ActivityLocationData>.from(
      state.activityLocations,
    );
    newLocations[activityId] = data;
    state = state.copyWith(activityLocations: newLocations);
  }

  void removeActivityLocation(String activityId) {
    final newLocations = Map<String, ActivityLocationData>.from(
      state.activityLocations,
    );
    newLocations.remove(activityId);
    state = state.copyWith(activityLocations: newLocations);
  }

  bool _validateForm() {
    if (state.title.isEmpty) {
      state = state.copyWith(
        status: AssignmentFormStatus.error,
        errorMessage: 'Judul wajib diisi',
      );
      return false;
    }

    if (state.startDate == null || state.endDate == null) {
      state = state.copyWith(
        status: AssignmentFormStatus.error,
        errorMessage: 'Pilih tanggal mulai dan selesai',
      );
      return false;
    }

    if (state.selectedActivityIds.isEmpty && initialAssignment == null) {
      state = state.copyWith(
        status: AssignmentFormStatus.error,
        errorMessage: 'Pilih minimal 1 aktivitas',
      );
      return false;
    }

    return _validateActivityLocations();
  }

  bool _validateActivityLocations() {
    for (final activityId in state.selectedActivityIds) {
      final locationData = state.activityLocations[activityId];
      if (locationData == null ||
          locationData.location == null ||
          locationData.locationName == null ||
          locationData.locationName!.isEmpty) {
        state = state.copyWith(
          status: AssignmentFormStatus.error,
          errorMessage: 'Semua aktivitas yang dipilih wajib memiliki lokasi',
        );
        return false;
      }
    }
    return true;
  }

  Future<void> submitForm() async {
    if (!_validateForm()) return;

    state = state.copyWith(status: AssignmentFormStatus.loading);

    try {
      if (initialAssignment != null) {
        await _updateAssignment();
      } else {
        await _createAssignment();
      }
    } catch (e) {
      state = state.copyWith(
        status: AssignmentFormStatus.error,
        errorMessage: 'Error: $e',
      );
    }
  }

  Future<void> _createAssignment() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile == null) {
      throw Exception('User not found');
    }

    final now = DateTime.now();
    final assignment = _buildAssignment(userProfile.id, now);
    final repository = ref.read(assignmentRepositoryProvider);

    final newAssignment = await repository.createAssignment(
      assignment,
      state.selectedActivityIds.toList(),
    );

    await _processActivities(newAssignment.id, userProfile.id, now, repository);

    state = state.copyWith(
      status: AssignmentFormStatus.success,
      successMessage: 'Penugasan berhasil dibuat dan diselesaikan!',
    );
  }

  Future<void> _updateAssignment() async {
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile == null) {
      throw Exception('User not found');
    }

    final now = DateTime.now();
    final assignment = _buildAssignment(userProfile.id, now);
    final repository = ref.read(assignmentRepositoryProvider);

    await repository.updateAssignment(assignment);

    state = state.copyWith(
      status: AssignmentFormStatus.success,
      successMessage: 'Penugasan berhasil diupdate!',
    );
  }

  Assignment _buildAssignment(String userId, DateTime now) {
    return Assignment(
      id: initialAssignment?.id ?? '',
      userId: userId,
      assignedBy: null,
      title: state.title,
      description: state.description,
      type: AssignmentType.self,
      status: AssignmentStatus.completed,
      startDate: state.startDate!,
      endDate: state.endDate!,
      locationName: null,
      location: null,
      checkInRadius: 100,
      notes: null,
      completedAt: now,
      createdAt: initialAssignment?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _processActivities(
    String assignmentId,
    String userId,
    DateTime now,
    dynamic repository,
  ) async {
    for (final activityId in state.selectedActivityIds) {
      final locationData = state.activityLocations[activityId]!;

      final activities = await repository.getAssignmentActivities(assignmentId);
      final activity = activities.firstWhere(
        (a) => a.activityTemplateId == activityId,
      );

      await repository.updateActivityLocation(
        activity.id,
        locationData.locationName!,
        locationData.location!,
        locationData.requiresCheckin,
        locationData.checkInRadius,
      );

      await repository.toggleActivityCompletion(activity.id, true);

      await _addTrackingPoint(
        assignmentId,
        userId,
        activity.activityName,
        now,
        repository,
      );
    }
  }

  Future<void> _addTrackingPoint(
    String assignmentId,
    String userId,
    String activityName,
    DateTime now,
    dynamic repository,
  ) async {
    final trackingPoint = TrackingPoint(
      id: '',
      assignmentId: assignmentId,
      userId: userId,
      status: TrackingStatus.arrived,
      notes: 'Selesai aktivitas: $activityName',
      photoUrl: null,
      createdAt: now,
    );
    await repository.addTrackingPoint(trackingPoint);
  }
}

final assignmentFormProvider = StateNotifierProvider.family<
    AssignmentFormNotifier,
    AssignmentFormState,
    Assignment?>((ref, initialAssignment) {
  return AssignmentFormNotifier(initialAssignment, ref);
});
