import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';

class ActivityMarkerData {
  final AssignmentActivity activity;
  final Assignment assignment;

  ActivityMarkerData({
    required this.activity,
    required this.assignment,
  });
}