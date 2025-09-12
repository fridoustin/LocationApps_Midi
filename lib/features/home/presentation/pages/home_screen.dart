import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/home/presentation/widgets/skeletons/dashboard_skeleton.dart';
import 'package:midi_location/features/home/presentation/widgets/donut_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/skeletons/homepage_skeleton.dart';
import 'package:midi_location/features/home/presentation/widgets/line_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/summary_card.dart';
import 'package:midi_location/features/home/presentation/widgets/timerange_button.dart';
import 'package:midi_location/features/home/presentation/widgets/skeletons/toggleswitch_skeleton.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String route = '/home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermissionAndGetToken();
  }

  Future<void> _refreshData() async {
  // Tunggu kedua proses refresh selesai secara bersamaan
  await Future.wait([
    ref.refresh(userProfileProvider.future),
    ref.refresh(dashboardStatsProvider.future)
  ]);
}

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final timeRange = ref.watch(timeRangeProvider);

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsync.when(
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konten Halo yang asli
                Text(
                  "Halo,\n${profile?.name ?? 'User'}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const Text(
                  "Berikut Ringkasan Pekerjaan Anda",
                  style: TextStyle(fontSize: 14, color: AppColors.black),
                ),
                const SizedBox(height: 16),
                // Toggle yang asli sekarang ada di dalam 'data'
                AnimatedToggleSwitch(
                  isMonthSelected: timeRange == 'month',
                  onMonthTap: () => ref.read(timeRangeProvider.notifier).state = 'month',
                  onYearTap: () => ref.read(timeRangeProvider.notifier).state = 'year',
                ),
              ],
            ),
            loading: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton Halo
                const HaloTextSkeleton(),
                const SizedBox(height: 16),
                // Skeleton Toggle sekarang ada di dalam 'loading'
                const ToggleSwitchSkeleton(),
              ],
            ),
            error: (err, stack) => const Text("Gagal memuat nama pengguna.", style: TextStyle(color: Colors.red)),
          ),
            const SizedBox(height: 16),
            
            statsAsync.when(
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: SummaryCard(title: 'Total Ulok', value: stats.totalUlok.toString())),
                      const SizedBox(width: 16),
                      Expanded(child: SummaryCard(title: 'Ulok Approved', value: stats.ulokApproved.toString())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LineChartCard(data: stats.monthlyApprovedData),
                  const SizedBox(height: 16),
                  DonutChartCard(data: stats.statusCounts),
                ],
              ),
              loading: () => const DashboardContentSkeleton(), // Gunakan skeleton kecil
              error: (err, stack) => Center(child: Text('Gagal memuat statistik: $err')),
            ),
          ],
        )
      ),
    );
  }
}

