import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_form_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_form_header.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_form_section.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/custom_text_field.dart';

class AssignmentInfoSection extends StatelessWidget {
  final AssignmentFormState formState;
  final AssignmentFormNotifier formNotifier;

  const AssignmentInfoSection({
    super.key,
    required this.formState,
    required this.formNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AssignmentFormSection(
      header: const AssignmentFormHeader(
        title: 'Informasi Penugasan',
        icon: Icons.assignment_outlined,
      ),
      children: [
        CustomTextField(
          initialValue: formState.title,
          label: 'Judul Penugasan',
          isRequired: true,
          hint: 'Masukkan Judul Penugasan',
          prefixIcon: Icons.title_outlined,
          onChanged: formNotifier.updateTitle,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Judul wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          initialValue: formState.description,
          label: 'Deskripsi',
          hint: 'Masukkan Deskripsi Penugasan',
          prefixIcon: Icons.description_outlined,
          maxLines: 3,
          onChanged: formNotifier.updateDescription,
        ),
        const SizedBox(height: 16),
        _DateRangeField(
          startDate: formState.startDate,
          endDate: formState.endDate,
          onDateRangeSelected: formNotifier.updateDateRange,
        ),
      ],
    );
  }
}

class _DateRangeField extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const _DateRangeField({
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color hintColor = AppColors.black.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: 'Periode Penugasan'),
              TextSpan(
                text: " *",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateRange(context),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: hintColor, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.0,
                ),
              ),
              prefixIcon: const Icon(Icons.calendar_month),
            ),
            child: Text(
              startDate != null && endDate != null
                  ? '${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}'
                  : 'Pilih tanggal',
              style: TextStyle(
                color: startDate != null ? Colors.black87 : hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
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
      onDateRangeSelected(picked.start, picked.end);
    }
  }
}