import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_picker.dart';

class ActivityLocationData {
  String? locationName;
  LatLng? location;
  bool requiresCheckin;
  int checkInRadius;

  ActivityLocationData({
    this.locationName,
    this.location,
    this.requiresCheckin = true, 
    this.checkInRadius = 100,
  });
}

class ActivityLocationDialog extends StatefulWidget {
  final String activityName;
  final ActivityLocationData? initialData;

  const ActivityLocationDialog({
    super.key,
    required this.activityName,
    this.initialData,
  });

  @override
  State<ActivityLocationDialog> createState() => _ActivityLocationDialogState();
}

class _ActivityLocationDialogState extends State<ActivityLocationDialog> {
  late TextEditingController _locationNameController;
  late int _checkInRadius;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _locationNameController = TextEditingController(
      text: widget.initialData?.locationName ?? '',
    );
    _checkInRadius = widget.initialData?.checkInRadius ?? 100;
    _selectedLocation = widget.initialData?.location;
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final picked = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(initialPoint: _selectedLocation),
    );

    if (picked != null) {
      setState(() => _selectedLocation = picked);
    }
  }

  void _save() {
    final data = ActivityLocationData(
      locationName: _locationNameController.text.isEmpty
          ? null
          : _locationNameController.text,
      location: _selectedLocation,
      requiresCheckin: true, // Always true
      checkInRadius: _checkInRadius,
    );

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final Color hintColor = AppColors.black.withOpacity(0.5);
    final hintStyle = TextStyle(
      color: hintColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hintColor,
        width: 0.5,
      ),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primaryColor,
        width: 1.0,
      ),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.0,
      ),
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Set Lokasi untuk',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.activityName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Location Name Label
              const Text(
                'Nama Lokasi',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Location Name
              TextField(
                controller: _locationNameController,
                cursorColor: AppColors.primaryColor,
                decoration: InputDecoration(
                  hintText: 'Masukkan Nama lokasi',
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  enabledBorder: defaultBorder,
                  focusedBorder: focusedBorder,
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                ),
              ),

              const SizedBox(height: 16),

              // Pick Location Button
              ElevatedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(_selectedLocation != null
                    ? 'Ubah Lokasi di Map'
                    : 'Pilih Lokasi di Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              if (_selectedLocation != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                  'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // Info: Wajib Check-in (tidak bisa diubah)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_searching,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check-in Wajib',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Semua aktivitas memerlukan check-in di lokasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Check-in Radius
              Text(
                'Radius Check-in: ${_checkInRadius}m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _checkInRadius.toDouble(),
                min: 50,
                max: 500,
                divisions: 9,
                activeColor: AppColors.primaryColor,
                label: '${_checkInRadius}m',
                onChanged: (value) {
                  setState(() => _checkInRadius = value.toInt());
                },
              ),
              Text(
                'User harus berada dalam radius $_checkInRadius meter dari lokasi',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}