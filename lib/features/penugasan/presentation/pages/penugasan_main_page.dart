import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';
import 'package:midi_location/features/penugasan/presentation/views/tracking_view.dart';
import 'package:midi_location/features/penugasan/presentation/views/assignment_view.dart';
import 'package:midi_location/features/penugasan/presentation/widgets/tugas_top_bar_tab.dart';
import 'package:midi_location/features/penugasan/presentation/views/history_view.dart';

class PenugasanMainPage extends ConsumerWidget {
  const PenugasanMainPage({super.key});
  static const String route = '/penugasan';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(penugasanTabProvider);

    return Column(
      children: [
        // Top-level Tab Bar (Tracking, Assignment, History)
        TugasTopTabBar(
          currentIndex: currentTab,
          onTabChanged: (index) {
            ref.read(penugasanTabProvider.notifier).state = index;
          },
        ),

        // Content untuk setiap tab
        Expanded(
          child: IndexedStack(
            index: currentTab,
            children: const [
              TrackingView(),
              AssignmentView(),
              HistoryView(),
            ],
          ),
        ),
      ],
    );
  }
}