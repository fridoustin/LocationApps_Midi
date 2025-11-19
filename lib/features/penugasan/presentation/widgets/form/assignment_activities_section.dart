import 'package:flutter/material.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_form_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_form_header.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_form_section.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/activity_card.dart';

class AssignmentActivitiesSection extends StatelessWidget {
  final AssignmentFormState formState;
  final AssignmentFormNotifier formNotifier;
  final List<ActivityTemplate> activities;
  final bool isEditMode;

  const AssignmentActivitiesSection({
    super.key,
    required this.formState,
    required this.formNotifier,
    required this.activities,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return AssignmentFormSection(
      header: const AssignmentFormHeader(
        title: 'Pilih Aktivitas',
        icon: Icons.checklist_outlined,
      ),
      children: [
        const Text(
          'Pilih aktivitas dan tentukan lokasi untuk setiap aktivitas',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ...activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(
                activity: activity,
                isSelected: formState.selectedActivityIds.contains(activity.id),
                locationData: formState.activityLocations[activity.id],
                isEditMode: isEditMode,
                onToggleSelection: (value) =>
                    formNotifier.toggleActivitySelection(activity.id, value!),
                onSetLocation: (data) =>
                    formNotifier.setActivityLocation(activity.id, data),
                onRemoveLocation: () =>
                    formNotifier.removeActivityLocation(activity.id),
              ),
            )),
      ],
    );
  }
}