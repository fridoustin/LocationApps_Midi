// lib/features/penugasan/presentation/pages/assignment_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_picker.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';

class AssignmentFormPage extends ConsumerStatefulWidget {
  final Assignment? initialAssignment;

  const AssignmentFormPage({super.key, this.initialAssignment});

  @override
  ConsumerState<AssignmentFormPage> createState() => _AssignmentFormPageState();
}

class _AssignmentFormPageState extends ConsumerState<AssignmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  LatLng? _selectedLocation;
  Set<String> _selectedActivityIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAssignment != null) {
      _loadInitialData();
    } else {
      // Default dates
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  void _loadInitialData() {
    final assignment = widget.initialAssignment!;
    _titleController.text = assignment.title;
    _descriptionController.text = assignment.description ?? '';
    _locationNameController.text = assignment.locationName ?? '';
    _startDate = assignment.startDate;
    _endDate = assignment.endDate;
    _selectedLocation = assignment.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
      );
      return;
    }

    if (_selectedActivityIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 aktivitas')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) throw Exception('User not found');

      final assignment = Assignment(
        id: widget.initialAssignment?.id ?? '',
        userId: userProfile.id,
        assignedBy: null,
        title: _titleController.text,
        description: _descriptionController.text,
        type: AssignmentType.self,
        status: widget.initialAssignment?.status ?? AssignmentStatus.pending,
        startDate: _startDate!,
        endDate: _endDate!,
        locationName: _locationNameController.text,
        location: _selectedLocation,
        checkInRadius: 100,
        notes: null,
        completedAt: null,
        createdAt: widget.initialAssignment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(assignmentRepositoryProvider);

      if (widget.initialAssignment == null) {
        await repository.createAssignment(
          assignment,
          _selectedActivityIds.toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Penugasan berhasil dibuat!')),
          );
        }
      } else {
        await repository.updateAssignment(assignment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Penugasan berhasil diupdate!')),
          );
        }
      }

      // Refresh providers
      ref.invalidate(pendingAssignmentsProvider);
      ref.invalidate(allAssignmentsProvider);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialAssignment == null
            ? 'Buat Penugasan'
            : 'Edit Penugasan'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: activitiesAsync.when(
        data: (activities) => _buildForm(activities),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildForm(List<ActivityTemplate> activities) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Judul Penugasan *',
              hintText: 'Contoh: Survey Lokasi Tangerang',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Judul wajib diisi' : null,
          ),

          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Deskripsi penugasan',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Date Range
          InkWell(
            onTap: _selectDateRange,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Periode Penugasan *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),
              child: Text(
                _startDate != null && _endDate != null
                    ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                    : 'Pilih tanggal',
                style: TextStyle(
                  color: _startDate != null ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location Name
          TextFormField(
            controller: _locationNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lokasi',
              hintText: 'Contoh: Tangerang City',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),

          const SizedBox(height: 16),

          // Pick Location
          ElevatedButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.map),
            label: Text(_selectedLocation != null
                ? 'Ubah Lokasi di Map'
                : 'Pilih Lokasi di Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
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

          // Activities Section
          const Text(
            'Pilih Aktivitas *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih aktivitas yang akan dikerjakan dalam penugasan ini',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 12),

          // Activity List
          ...activities.map((activity) {
            final isSelected = _selectedActivityIds.contains(activity.id);
            return CheckboxListTile(
              title: Text(activity.name),
              subtitle: activity.description != null
                  ? Text(activity.description!)
                  : null,
              value: isSelected,
              activeColor: AppColors.primaryColor,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedActivityIds.add(activity.id);
                  } else {
                    _selectedActivityIds.remove(activity.id);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),

          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.initialAssignment == null
                        ? 'Buat Penugasan'
                        : 'Update Penugasan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}