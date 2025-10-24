import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment_activity.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityItemWidget extends ConsumerWidget {
  final AssignmentActivity activity;
  final bool isAssignmentCompleted;
  final bool isCheckingIn;
  final bool isToggling;
  final Function() onCheckIn;
  final Function(bool) onToggle;

  const ActivityItemWidget({
    super.key,
    required this.activity,
    required this.isAssignmentCompleted,
    required this.isCheckingIn,
    required this.isToggling,
    required this.onCheckIn,
    required this.onToggle,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _openDirections(BuildContext context, LatLng destination) async {
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta di perangkat ini')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka peta: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.black.withOpacity(0.5),
          width: 0.5
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      Flexible( 
                        child: Text(activity.activityName, style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                          color: AppColors.black,
                        )),
                      ),
                      const SizedBox(width: 12), 
                      
                      Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          if (activity.requiresCheckin && !activity.isCompleted) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (activity.checkedInAt != null ? AppColors.successColor.withOpacity(0.08) : AppColors.warningColor.withOpacity(0.08)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    activity.checkedInAt != null ? Icons.check_circle : Icons.location_on,
                                    size: 14,
                                    color: activity.checkedInAt != null ? AppColors.successColor : AppColors.warningColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    activity.checkedInAt != null ? 'Sudah Check-in' : 'Perlu Check-in',
                                    style: TextStyle(
                                      color: activity.checkedInAt != null ? AppColors.successColor : AppColors.warningColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (activity.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.task_alt, size: 14, color: AppColors.successColor),
                                  SizedBox(width: 6),
                                  Text('Selesai', style: TextStyle(color: AppColors.successColor, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isToggling)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                        ),
                      ),
                    ),
                  )
                else
                Align(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    value: activity.isCompleted,
                    activeColor: AppColors.successColor,
                    checkColor: Colors.white,
                    fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.successColor;
                      }
                      return null; 
                    }),
                    onChanged: (isAssignmentCompleted || activity.isCompleted)
                        ? null 
                        : (val) => onToggle(val!),
                  ),
                ),
              ],
            ),
            if (activity.locationName != null) ...[
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Lokasi:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  // color: Color(0xFFDDE6F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: AppColors.secondaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activity.locationName!,
                        style: TextStyle(fontSize: 13, color: AppColors.secondaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Map Preview
            if (activity.location != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 180,
                  child: InteractiveMapWidget(
                    position: activity.location!,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Check-in button or status
            if (activity.requiresCheckin) ...[
              if (activity.checkedInAt != null)
                _buildInfoRow(
                  icon: Icons.check_circle,
                  text: 'Check-in: ${DateFormat('dd MMM yyyy, HH:mm').format(activity.checkedInAt!)}',
                  color: AppColors.secondaryColor,
                )
              else if (!isAssignmentCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isCheckingIn ? null : onCheckIn,
                        icon: isCheckingIn
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.location_on, size: 18),
                        label: const Text('Check-in'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (activity.location != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openDirections(context, activity.location!),
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text('Petunjuk'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(color: AppColors.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],

            // Get Direction button untuk yang sudah check-in tapi belum selesai
            if (activity.checkedInAt != null && 
                !activity.isCompleted && 
                activity.location != null &&
                !isAssignmentCompleted) ...[
              OutlinedButton.icon(
                onPressed: () => _openDirections(context, activity.location!),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Petunjuk Arah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Info Selesai (Waktu DAN Durasi)
            if (activity.isCompleted && activity.completedAt != null) ...[
              _buildInfoRow(
                icon: Icons.task_alt,
                text: 'Selesai: ${DateFormat('dd MMM yyyy, HH:mm').format(activity.completedAt!)}',
                color: AppColors.successColor,
              ),
              if (activity.checkedInAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.timer,
                  text: 'Durasi: ${_formatDuration(activity.completedAt!.difference(activity.checkedInAt!))}',
                  color: Colors.grey[700]!,
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}