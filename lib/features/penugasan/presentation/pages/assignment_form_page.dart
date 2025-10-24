// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/activity_location_dialog.dart';

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

  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedActivityIds = {};
  final Map<String, ActivityLocationData> _activityLocations = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAssignment != null) {
      _loadInitialData();
    } else {
      // Default dates - hari ini sampai hari ini
      final today = DateTime.now();
      _startDate = DateTime(today.year, today.month, today.day);
      _endDate = DateTime(today.year, today.month, today.day);
    }
  }

  void _loadInitialData() {
    final assignment = widget.initialAssignment!;
    _titleController.text = assignment.title;
    _descriptionController.text = assignment.description ?? '';
    _startDate = assignment.startDate;
    _endDate = assignment.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
      );
      return;
    }

    if (_selectedActivityIds.isEmpty && widget.initialAssignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 aktivitas')),
      );
      return;
    }

    // Validasi: semua aktivitas yang dipilih harus punya lokasi
    for (final activityId in _selectedActivityIds) {
      final locationData = _activityLocations[activityId];
      if (locationData == null || 
          locationData.location == null || 
          locationData.locationName == null ||
          locationData.locationName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua aktivitas yang dipilih wajib memiliki lokasi'),
            backgroundColor: AppColors.warningColor,
          ),
        );
        return;
      }
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
        locationName: null, // Tidak lagi digunakan
        location: null, // Tidak lagi digunakan
        checkInRadius: 100,
        notes: null,
        completedAt: null,
        createdAt: widget.initialAssignment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create assignment
      final repository = ref.read(assignmentRepositoryProvider);

      if (widget.initialAssignment == null) {
        // Create new assignment
        final newAssignment = await repository.createAssignment(
          assignment,
          _selectedActivityIds.toList(),
        );

        // Update activity locations - SEMUA aktivitas sudah pasti punya lokasi
        for (final activityId in _selectedActivityIds) {
          final locationData = _activityLocations[activityId]!;
          
          // Get the created activity
          final activities =
              await repository.getAssignmentActivities(newAssignment.id);
          final activity = activities.firstWhere(
            (a) => a.activityTemplateId == activityId,
          );

          // Update location
          await repository.updateActivityLocation(
            activity.id,
            locationData.locationName!,
            locationData.location!,
            locationData.requiresCheckin,
            locationData.checkInRadius,
          );
        }

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
      appBar: CustomTopBar.general(
        title: widget.initialAssignment == null
            ? 'Buat Penugasan'
            : 'Edit Penugasan',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: activitiesAsync.when(
        data: (activities) => _buildForm(activities),
        loading: () => const Center(child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        )),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(
                  color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildForm(List<ActivityTemplate> activities) {
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

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLabel('Judul Penugasan', isRequired: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            cursorColor: AppColors.primaryColor,
            decoration: InputDecoration(
              hintText: 'Masukkan Judul Penugasan',
              hintStyle: hintStyle,
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(Icons.title_outlined),
              enabledBorder: defaultBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Judul wajib diisi' : null,
          ),

          const SizedBox(height: 16),

          _buildLabel('Deskripsi'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            cursorColor: AppColors.primaryColor,
            decoration: InputDecoration(
              hintText: 'Masukkan Deskripsi Penugasan',
              hintStyle: hintStyle,
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(Icons.description_outlined),
              enabledBorder: defaultBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
            ),
          ),

          const SizedBox(height: 16),
          _buildLabel('Periode Penugasan', isRequired: true),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                enabledBorder: defaultBorder,
                focusedBorder: focusedBorder,
                prefixIcon: const Icon(Icons.calendar_month),
              ),
              child: Text(
                _startDate != null && _endDate != null
                    ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                    : 'Pilih tanggal',
                style: TextStyle(
                  color: _startDate != null ? Colors.black87 : hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Pilih Aktivitas *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih aktivitas dan tentukan lokasi untuk setiap aktivitas',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 12),
          ...activities.map((activity) {
            final isSelected = _selectedActivityIds.contains(activity.id);
            final locationData = _activityLocations[activity.id];
            final hasLocation = locationData?.location != null;

            return Card(
              color: AppColors.white, 
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), 
                side: BorderSide( 
                  color: isSelected && !hasLocation 
                      ? Colors.red.shade300 
                      : hintColor, 
                  width: isSelected && !hasLocation ? 1.0 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
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
                          _activityLocations.remove(activity.id);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  // Show location button when selected
                  if (isSelected && widget.initialAssignment == null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final data =
                                    await showDialog<ActivityLocationData>(
                                  context: context,
                                  builder: (context) => ActivityLocationDialog(
                                    activityName: activity.name,
                                    initialData: locationData,
                                  ),
                                );

                                if (data != null) {
                                  setState(() {
                                    _activityLocations[activity.id] = data;
                                  });
                                }
                              },
                              icon: Icon(
                                hasLocation
                                    ? Icons.edit_location
                                    : Icons.add_location_alt,
                                size: 18,
                              ),
                              label: Text(
                                hasLocation
                                    ? 'Ubah Lokasi (Wajib Check-in)'
                                    : 'Set Lokasi (Wajib)',
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: hasLocation
                                    ? AppColors.successColor
                                    : Colors.red,
                                side: BorderSide(
                                  color: hasLocation
                                      ? AppColors.successColor
                                      : Colors.red,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          if (hasLocation) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _activityLocations.remove(activity.id);
                                });
                              },
                              icon:
                                  const Icon(Icons.delete_outline, size: 20),
                              color: Colors.red,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Location info
                    if (hasLocation && locationData?.locationName != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.place,
                                size: 16,
                                color: AppColors.successColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  locationData!.locationName!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.successColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Warning jika belum set lokasi
                    if (!hasLocation)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Lokasi belum diatur (wajib)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }),

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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}