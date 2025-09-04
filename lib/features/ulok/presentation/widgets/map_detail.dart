import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';

class InteractiveMapWidget extends StatelessWidget {
  final LatLng position;

  const InteractiveMapWidget({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: position,
            initialZoom: 15.0,
            // Anda bisa mengaktifkan interaksi jika perlu
            // interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              // --- PERBAIKAN DI SINI ---
              // Tambahkan identitas aplikasi Anda, sama seperti di MapPickerDialog
              userAgentPackageName: 'com.midi.location',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: position,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: 40.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
