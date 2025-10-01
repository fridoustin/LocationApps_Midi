// lib/features/home/presentation/pages/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/home/presentation/widgets/donut_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/filter_dropdown.dart';
import 'package:midi_location/features/home/presentation/widgets/monthly_kplt_barchart.dart';
import 'package:midi_location/features/home/presentation/widgets/monthly_ulok_barchart.dart';
import 'package:midi_location/features/home/presentation/widgets/skeletons/homepage_skeleton.dart';
import 'package:midi_location/features/home/presentation/widgets/status_summary_card.dart';
import 'package:midi_location/features/home/presentation/widgets/summary_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String route = '/home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final List<int> years = List.generate(
    5,
    (index) => DateTime.now().year - index,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationService().requestPermissionAndGetToken();
      }
    });
  }

  Future<void> _refreshData() async {
    ref.invalidate(dashboardStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(filteredDashboardStatsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedView = ref.watch(selectedDashboardViewProvider);

    return Container(
      color: AppColors.backgroundColor,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data:
                      (profile) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo,\n${profile?.name ?? 'User'}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Berikut Ringkasan Pekerjaan Anda",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                  loading: () => const HaloTextSkeleton(),
                  error:
                      (err, stack) => const Text("Gagal memuat nama pengguna."),
                ),
                const SizedBox(height: 20),

                statsAsync.when(
                  data: (stats) {
                    final bool isUlokView = selectedView == DashboardView.ulok;
                    final statusCounts =
                        isUlokView
                            ? stats.ulokStatusCounts
                            : stats.kpltStatusCounts;
                    final String chartTitle =
                        isUlokView ? "ULok Statistics" : "KPLT Statistics";

                    String title = isUlokView ? "ULok" : "KPLT";
                    final yearToDisplay = selectedYear ?? DateTime.now().year;

                    if (selectedMonth != null) {
                      final monthName = months[selectedMonth - 1];
                      title = '$title - $monthName $yearToDisplay';
                    } else if (selectedYear != null) {
                      title = '$title - Tahun $yearToDisplay';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilterDropdown<int?>(
                                hintText: 'Pilih Bulan',
                                value: selectedMonth,
                                items: List.generate(months.length, (index) {
                                  return DropdownMenuItem(
                                    value: index + 1,
                                    child: Text(months[index]),
                                  );
                                }),
                                onChanged: (value) {
                                  ref
                                      .read(selectedMonthProvider.notifier)
                                      .state = value;
                                },
                                onClear: () {
                                  ref
                                      .read(selectedMonthProvider.notifier)
                                      .state = null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilterDropdown<int?>(
                                hintText: 'Pilih Tahun',
                                value: selectedYear,
                                items:
                                    years.map((year) {
                                      return DropdownMenuItem(
                                        value: year,
                                        child: Text(year.toString()),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  ref
                                      .read(selectedYearProvider.notifier)
                                      .state = value;
                                },
                                onClear: () {
                                  ref
                                      .read(selectedYearProvider.notifier)
                                      .state = null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        ref
                                            .read(
                                              selectedDashboardViewProvider
                                                  .notifier,
                                            )
                                            .state = DashboardView.ulok,
                                child: SummaryCard(
                                  title: 'Total ULok',
                                  value: stats.totalUlok.toString(),
                                  icon: SvgPicture.asset(
                                    'assets/icons/locations.svg',
                                    width: 21,
                                  ),
                                  style:
                                      isUlokView
                                          ? SummaryCardStyle.solid
                                          : SummaryCardStyle.outlined,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        ref
                                            .read(
                                              selectedDashboardViewProvider
                                                  .notifier,
                                            )
                                            .state = DashboardView.kplt,
                                child: SummaryCard(
                                  title: 'Total KPLT',
                                  value: stats.totalKplt.toString(),
                                  icon: SvgPicture.asset(
                                    'assets/icons/maps.svg',
                                    width: 25,
                                  ),
                                  style:
                                      !isUlokView
                                          ? SummaryCardStyle.solid
                                          : SummaryCardStyle.outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: DonutChartCard(
                                title: chartTitle,
                                data: statusCounts,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  StatusSummaryCard(
                                    title: 'OK',
                                    value:
                                        statusCounts['OK']?.toString() ?? '0',
                                    svgAssetPath: 'assets/icons/ok.svg',
                                    color: AppColors.successColor,
                                  ),
                                  const SizedBox(height: 5),
                                  StatusSummaryCard(
                                    title: 'NOK',
                                    value:
                                        statusCounts['NOK']?.toString() ?? '0',
                                    svgAssetPath: 'assets/icons/nok.svg',
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(height: 5),
                                  StatusSummaryCard(
                                    title: 'In Progress',
                                    value:
                                        statusCounts['In Progress']
                                            ?.toString() ??
                                        '0',
                                    svgAssetPath:
                                        'assets/icons/in_progress.svg',
                                    color: AppColors.warningColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              isUlokView
                                  ? MonthlyUlokBarChart(
                                    key: const ValueKey('ulok_chart'),
                                    data: stats.monthlyUlokData,
                                    year: selectedYear,
                                  )
                                  : MonthlyKpltBarChart(
                                    key: const ValueKey('kplt_chart'),
                                    data: stats.monthlyKpltData,
                                    year: selectedYear,
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },

                  loading: () => const HomepageSkeleton(),
                  error:
                      (err, stack) =>
                          Center(child: Text('Gagal memuat statistik: $err')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
