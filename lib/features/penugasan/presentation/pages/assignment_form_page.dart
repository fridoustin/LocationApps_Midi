import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/core/widgets/custom_success_dialog.dart';
import 'package:midi_location/features/penugasan/domain/entities/activity_template.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_form_provider.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_activities_section.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_info_section.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/form/assignment_submit_button.dart';

class AssignmentFormPage extends ConsumerStatefulWidget {
  final Assignment? initialAssignment;

  const AssignmentFormPage({super.key, this.initialAssignment});

  @override
  ConsumerState<AssignmentFormPage> createState() => _AssignmentFormPageState();
}

class _AssignmentFormPageState extends ConsumerState<AssignmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.initialAssignment != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(
        assignmentFormProvider(widget.initialAssignment).notifier,
      );
      notifier.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = assignmentFormProvider(widget.initialAssignment);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);
    final activitiesAsync = ref.watch(activityTemplatesProvider);

    // Listen to status changes
    ref.listen<AssignmentFormState>(formProvider, (previous, next) {
      if (previous?.status != next.status) {
        _handleStatusChange(next);
      }
    });

    return Scaffold(
      appBar: CustomTopBar.general(
        title: _isEditMode ? 'Edit Penugasan' : 'Buat Penugasan',
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
        data: (activities) => _buildForm(
          context,
          formState,
          formNotifier,
          activities,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
        error: (err, stack) => _buildErrorState(err),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AssignmentFormState formState,
    AssignmentFormNotifier formNotifier,
    List<ActivityTemplate> activities,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AssignmentInfoSection(
            formState: formState,
            formNotifier: formNotifier,
          ),
          const SizedBox(height: 16),
          AssignmentActivitiesSection(
            formState: formState,
            formNotifier: formNotifier,
            activities: activities,
            isEditMode: _isEditMode,
          ),
          const SizedBox(height: 24),
          AssignmentSubmitButton(
            isSubmitting: formState.status == AssignmentFormStatus.loading,
            isEditMode: _isEditMode,
            onPressed: () => _handleSubmit(formNotifier),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleSubmit(AssignmentFormNotifier formNotifier) {
    if (_formKey.currentState?.validate() ?? false) {
      formNotifier.submitForm();
    }
  }

  void _handleStatusChange(AssignmentFormState state) {
    if (!mounted) return;

    switch (state.status) {
      case AssignmentFormStatus.success:
        _showSuccessDialog(state.successMessage ?? 'Berhasil!');
        break;
      case AssignmentFormStatus.error:
        _showErrorSnackBar(state.errorMessage ?? 'Terjadi kesalahan');
        break;
      default:
        break;
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomSuccessDialog(
        title: message,
        iconPath: 'assets/icons/success.svg',
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ref.invalidate(completedAssignmentsProvider);
      ref.invalidate(allAssignmentsProvider);
      Navigator.pop(context); // Close dialog
      Navigator.pop(context, true); // Close form
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(activityTemplatesProvider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}