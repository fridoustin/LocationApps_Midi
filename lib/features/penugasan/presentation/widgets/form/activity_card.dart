import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/activity_location_dialog.dart';

class ActivityCard extends StatelessWidget {
  final ActivityTemplate activity;
  final bool isSelected;
  final ActivityLocationData? locationData;
  final bool isEditMode;
  final Function(bool?) onToggleSelection;
  final Function(ActivityLocationData) onSetLocation;
  final VoidCallback onRemoveLocation;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.isSelected,
    required this.locationData,
    required this.isEditMode,
    required this.onToggleSelection,
    required this.onSetLocation,
    required this.onRemoveLocation,
  });

  bool get hasLocation => locationData?.location != null;

  @override
  Widget build(BuildContext context) {
    final Color hintColor = AppColors.black.withOpacity(0.5);

    return Card(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected && !hasLocation ? Colors.red.shade300 : hintColor,
          width: isSelected && !hasLocation ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
              activity.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: activity.description != null
                ? Text(activity.description!)
                : null,
            value: isSelected,
            activeColor: AppColors.primaryColor,
            onChanged: onToggleSelection,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (isSelected && !isEditMode)
            _ActivityLocationSection(
              activity: activity,
              locationData: locationData,
              hasLocation: hasLocation,
              onSetLocation: onSetLocation,
              onRemoveLocation: onRemoveLocation,
            ),
        ],
      ),
    );
  }
}

class _ActivityLocationSection extends StatelessWidget {
  final ActivityTemplate activity;
  final ActivityLocationData? locationData;
  final bool hasLocation;
  final Function(ActivityLocationData) onSetLocation;
  final VoidCallback onRemoveLocation;

  const _ActivityLocationSection({
    required this.activity,
    required this.locationData,
    required this.hasLocation,
    required this.onSetLocation,
    required this.onRemoveLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showLocationDialog(context),
                  icon: Icon(
                    hasLocation ? Icons.edit_location : Icons.add_location_alt,
                    size: 18,
                  ),
                  label: Text(
                    hasLocation ? 'Ubah Lokasi' : 'Set Lokasi (Wajib)',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        hasLocation ? AppColors.successColor : Colors.red,
                    side: BorderSide(
                      color: hasLocation ? AppColors.successColor : Colors.red,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (hasLocation) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRemoveLocation,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (hasLocation && locationData?.locationName != null)
            _LocationInfoBox(
              text: locationData!.locationName!,
              isSuccess: true,
            )
          else
            const _LocationInfoBox(
              text: 'Lokasi belum diatur (wajib)',
              isSuccess: false,
            ),
        ],
      ),
    );
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    final data = await showDialog<ActivityLocationData>(
      context: context,
      builder: (context) => ActivityLocationDialog(
        activityName: activity.name,
        initialData: locationData,
      ),
    );

    if (data != null) {
      onSetLocation(data);
    }
  }
}

class _LocationInfoBox extends StatelessWidget {
  final String text;
  final bool isSuccess;

  const _LocationInfoBox({
    required this.text,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.successColor.withOpacity(0.1)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.place : Icons.warning_amber_rounded,
            size: 16,
            color: isSuccess ? AppColors.successColor : Colors.red.shade700,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSuccess ? AppColors.successColor : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}