// lib/features/penugasan/presentation/views/assignment_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/assignment_card.dart';

class AssignmentView extends ConsumerStatefulWidget {
  const AssignmentView({super.key});

  @override
  ConsumerState<AssignmentView> createState() => _AssignmentViewState();
}

class _AssignmentViewState extends ConsumerState<AssignmentView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AssignmentStatus _selectedFilter = AssignmentStatus.pending;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Filter Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildFilterTabs(),
        ),

        // Assignment List
        Expanded(child: _buildAssignmentList()),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 3;
            final currentIndex = _getFilterIndex(_selectedFilter);

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  left: currentIndex * tabWidth,
                  child: Container(
                    width: tabWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildFilterTab('Belum', AssignmentStatus.pending, 0, tabWidth),
                    _buildFilterTab('Sedang', AssignmentStatus.inProgress, 1, tabWidth),
                    _buildFilterTab('Selesai', AssignmentStatus.completed, 2, tabWidth),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, AssignmentStatus status, int index, double width) {
    final isActive = _selectedFilter == status;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = status),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.black,
              ),
            child: Text(label),
          )
        ),
      ),
    );
  }

  int _getFilterIndex(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 0;
      case AssignmentStatus.inProgress:
        return 1;
      case AssignmentStatus.completed:
        return 2;
      default:
        return 0;
    }
  }

  Widget _buildAssignmentList() {
    final AsyncValue<List<Assignment>> assignmentsAsync;

    switch (_selectedFilter) {
      case AssignmentStatus.pending:
        assignmentsAsync = ref.watch(pendingAssignmentsProvider);
        break;
      case AssignmentStatus.inProgress:
        assignmentsAsync = ref.watch(inProgressAssignmentsProvider);
        break;
      case AssignmentStatus.completed:
        assignmentsAsync = ref.watch(completedAssignmentsProvider);
        break;
      default:
        assignmentsAsync = ref.watch(pendingAssignmentsProvider);
    }

    return assignmentsAsync.when(
      data: (assignments) {
        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada penugasan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingAssignmentsProvider);
            ref.invalidate(inProgressAssignmentsProvider);
            ref.invalidate(completedAssignmentsProvider);
          },
          color: AppColors.primaryColor,
          backgroundColor: AppColors.cardColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return AssignmentCard(
                assignment: assignment,
                onTap: () {
                  // TODO: Navigate to detail page
                  ref.read(selectedAssignmentProvider.notifier).state = assignment;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Detail: ${assignment.title}')),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Error: $err'),
      ),
    );
  }
}