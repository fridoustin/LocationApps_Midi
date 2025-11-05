import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'task_item.dart';
import 'skeletons/task_list_skeleton.dart';
import 'package:midi_location/features/penugasan/presentation/providers/assignment_provider.dart';

class TaskListSection extends ConsumerWidget {
  const TaskListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(pendingAssignmentsProvider);

    return tasksAsync.when(
      loading: () => const TaskListSkeleton(),

      error: (err, stack) => Center(child: Text('Gagal memuat tugas: $err')),

      data: (tasks) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/penugasan.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Tugas Hari Ini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(mainNavigationProvider.notifier).state = 2;
                      },
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1, height: 1),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tidak ada tugas hari ini.'),
                )
              else
                ListView.builder(
                  itemCount: tasks.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final assignment = tasks[index];
                    return TaskItem(assignment: assignment);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
