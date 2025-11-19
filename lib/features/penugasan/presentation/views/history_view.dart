// lib/features/penugasan/presentation/views/history_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/assignment.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/history/week_selector.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/history/weekly_summary_card.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/history/history_item_card.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedWeekIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allAssignmentsAsync = ref.watch(allAssignmentsProvider);

    return Column(
      children: [
        // Week Selector
        WeekSelector(
          selectedWeekIndex: _selectedWeekIndex,
          onWeekChanged: (index) => setState(() => _selectedWeekIndex = index),
        ),

        // Assignment List
        Expanded(
          child: allAssignmentsAsync.when(
            data: (allAssignments) =>
                _buildHistoryContent(allAssignments),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(List<Assignment> allAssignments) {
    final weeks = WeekRangeHelper.getWeekRanges();
    final selectedWeek = weeks[_selectedWeekIndex];

    // Filter completed & cancelled
    final historyAssignments = allAssignments
        .where((a) =>
            a.status == AssignmentStatus.completed ||
            a.status == AssignmentStatus.cancelled)
        .toList();

    // Filter by selected week
    final weekAssignments = historyAssignments.where((assignment) {
      final completedDate = assignment.completedAt ?? assignment.updatedAt;
      return completedDate.isAfter(selectedWeek.start) && 
            completedDate.isBefore(selectedWeek.end);
    }).toList()..sort((a, b) {
      final dateA = a.completedAt ?? a.updatedAt;
      final dateB = b.completedAt ?? b.updatedAt;
      return dateB.compareTo(dateA); // Newest first
    });

    if (weekAssignments.isEmpty) {
      return _buildEmptyState(historyAssignments.length);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allAssignmentsProvider);
      },
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: weekAssignments.length + 1, // +1 for summary
        itemBuilder: (context, index) {
          if (index == 0) {
            return WeeklySummaryCard(
              assignments: weekAssignments,
              week: selectedWeek,
            );
          }

          final assignment = weekAssignments[index - 1];
          return HistoryItemCard(
            assignment: assignment,
            isLast: index == weekAssignments.length,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(int totalCount) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada history di minggu ini',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total $totalCount penugasan selesai',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}