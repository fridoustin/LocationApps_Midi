import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan package ini ada

class AssignmentTimelineItem extends StatelessWidget {
  final AssignmentActivity activity;
  final bool isLastItem;
  final bool isCompleted;
  final bool isNextTask;
  final bool isCheckingIn;
  final bool isToggling;
  final VoidCallback onCheckIn;
  final Function(bool) onToggle;

  const AssignmentTimelineItem({
    super.key,
    required this.activity,
    required this.isLastItem,
    required this.isCompleted,
    required this.isNextTask,
    required this.isCheckingIn,
    required this.isToggling,
    required this.onCheckIn,
    required this.onToggle,
  });

  // Helper function untuk buka Google Maps
  Future<void> _launchMaps() async {
    if (activity.location == null) return;
    
    final lat = activity.location!.latitude;
    final long = activity.location!.longitude;
    
    // Format URL universal untuk map
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$long");
    
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch maps');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isCompleted
        ? AppColors.successColor
        : (isNextTask ? AppColors.white : Colors.grey[200]!);

    final Color borderColor = isCompleted
        ? AppColors.successColor
        : (isNextTask ? AppColors.primaryColor : Colors.grey[300]!);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: isNextTask
                        ? [
                            BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1)
                          ]
                        : [],
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : (isNextTask
                          ? Center(
                              child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle)))
                          : null),
                ),
                // Line
                if (!isLastItem)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.successColor.withOpacity(0.2)
                          : Colors.grey[200],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.activityName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isCompleted || isNextTask
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (activity.location != null && !isCompleted)
                    Container(
                      height: 140,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05), 
                            blurRadius: 4,
                            offset: const Offset(0,2)
                          )
                        ]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: activity.location!,
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.midi.location',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: activity.location!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: InkWell(
                                onTap: _launchMaps,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                      )
                                    ]
                                  ),
                                  child: const Icon(
                                    Icons.directions, // Icon panah navigasi
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Tombol Aksi
                  if (!isCompleted) _buildActionButton(),

                  // Status Selesai
                  if (isCompleted)
                    Row(
                      children: const [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.successColor),
                        SizedBox(width: 6),
                        Text(
                          "Telah diselesaikan",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (activity.requiresCheckin && activity.checkedInAt == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isCheckingIn ? null : onCheckIn,
          icon: isCheckingIn
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.near_me, size: 18),
          label: Text(isCheckingIn ? "Memproses..." : "Check-in Lokasi"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
        ),
      );
    }

    return InkWell(
      onTap: isToggling ? null : () => onToggle(true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isToggling)
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.check_box_outline_blank,
                  size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              "Tandai Selesai",
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}