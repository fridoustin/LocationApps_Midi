import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/card_list_skeleton.dart'; // Pastikan import ini benar
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/pages/assignment_detail_page.dart';
import 'package:midi_location/features/penugasan/presentation/pages/assignment_form_page.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/assignment_card.dart';

class AssignmentView extends ConsumerStatefulWidget {
  const AssignmentView({super.key});

  @override
  ConsumerState<AssignmentView> createState() => _AssignmentViewState();
}

class _AssignmentViewState extends ConsumerState<AssignmentView> {
  AssignmentStatus _selectedFilter = AssignmentStatus.pending;
  void _refreshData() {
    Future.microtask(() {
      ref.invalidate(pendingAssignmentsProvider);
      ref.invalidate(inProgressAssignmentsProvider);
      ref.invalidate(allAssignmentsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildFilterTabs(),
            ),
            // Assignment List
            Expanded(child: _buildAssignmentList()),
          ],
        ),

        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'addAssignment',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AssignmentFormPage(),
                ),
              );

              if (result == true) {
                _refreshData();
              }
            },
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            child: const Icon(Icons.add),
          ),
        ),
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
            final tabWidth = constraints.maxWidth / 2;
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
                    _buildFilterTab(
                        'Belum', AssignmentStatus.pending, 0, tabWidth),
                    _buildFilterTab(
                        'Sedang', AssignmentStatus.inProgress, 1, tabWidth),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTab(
      String label, AssignmentStatus status, int index, double width) {
    final isActive = _selectedFilter == status;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = status);
          Future.microtask(() { 
            if (status == AssignmentStatus.pending) {
              ref.invalidate(pendingAssignmentsProvider);
            } else {
              ref.invalidate(inProgressAssignmentsProvider);
            }
          });
        },
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
        )),
      ),
    );
  }

  int _getFilterIndex(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return 0;
      case AssignmentStatus.inProgress:
        return 1;
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
      default:
        assignmentsAsync = ref.watch(pendingAssignmentsProvider);
    }

    if (assignmentsAsync.isLoading || assignmentsAsync.isRefreshing) {
      return const CommonListSkeleton();
    }

    return assignmentsAsync.when(
      data: (assignments) {
        final managerAssignments = assignments
            .where((a) => a.type != AssignmentType.self)
            .toList();

        if (managerAssignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == AssignmentStatus.pending
                      ? 'Belum ada tugas yang diberikan'
                      : 'Belum ada tugas yang sedang dikerjakan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kerjakan tugas yang telah diberikan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refreshData();
          },
          color: AppColors.primaryColor,
          backgroundColor: AppColors.cardColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: managerAssignments.length,
            itemBuilder: (context, index) {
              final assignment = managerAssignments[index];
              return AssignmentCard(
                assignment: assignment,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AssignmentDetailPage(assignment: assignment),
                    ),
                  );
                  if (mounted) {
                    _refreshData();
                  }
                },
              );
            },
          ),
        );
      },
      // Fallback loading (biasanya tidak terpanggil karena logic if di atas)
      loading: () => const CommonListSkeleton(),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                err.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _refreshData,
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      ),
    );
  }
}