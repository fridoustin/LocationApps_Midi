import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/month_picker.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';
import 'package:midi_location/features/statistik/presentation/providers/statistic_provider.dart';
import 'package:midi_location/features/statistik/presentation/widgets/achievement_card.dart';
import 'package:midi_location/features/statistik/presentation/widgets/annual_ulok_chart.dart';
import 'package:midi_location/features/statistik/presentation/widgets/assignment_card.dart';
import 'package:midi_location/features/statistik/presentation/widgets/kplt_progress_summary_card.dart';
import 'package:midi_location/features/statistik/presentation/widgets/statistic_skeleton.dart';
import 'package:midi_location/features/statistik/presentation/widgets/summary_grid.dart';
import 'package:midi_location/features/statistik/presentation/widgets/ulok_status_card.dart';

class StatistikScreen extends ConsumerWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticDataAsync = ref.watch(statisticProvider);

    return statisticDataAsync.when(
      data: (data) {
        return _BuildStatisticsPage(data: data);
      },
      loading: () {
        return const StatisticsLoadingSkeleton();
      },
      error: (error, stackTrace) {
        print('Error di StatistikScreen: $error');
        print(stackTrace);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gagal memuat data:\n${error.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class _BuildStatisticsPage extends ConsumerWidget {
  final StatisticData data;
  const _BuildStatisticsPage({required this.data});

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await CustomMonthPicker.show(
      context,
      initialDate: ref.read(statisticDateProvider),
      primaryColor: AppColors.primaryColor,
      firstDate: DateTime(DateTime.now().year - 10, 1),
      lastDate: DateTime(DateTime.now().year + 1, 12),
    );

    if (picked != null && picked != ref.read(statisticDateProvider)) {
      ref.read(statisticDateProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(statisticDateProvider);
    final String formattedDate = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(selectedDate);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(statisticProvider);
        await ref.read(statisticProvider.future);
      },
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ringkasan Aktivitas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _selectDate(context, ref);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SummaryGrid(data: data),
                  const SizedBox(height: 16),
                  AnnualUlokChart(data: data),
                  const SizedBox(height: 16),
                  UlokStatusCard(data: data),
                  const SizedBox(height: 16),
                  KpltProgressSummaryCard(data: data),
                  const SizedBox(height: 16),
                  AssignmentCard(data: data),
                  const SizedBox(height: 16),
                  AchievementCard(data: data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
