import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/home/presentation/widgets/donut_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/homepage_skeleton.dart';
import 'package:midi_location/features/home/presentation/widgets/line_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/summary_card.dart';
import 'package:midi_location/features/home/presentation/widgets/timerange_button.dart';

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
    final profileAsync = ref.watch(userProfileProvider); // Ganti ke userProfileProvider
    final timeRange = ref.watch(timeRangeProvider);

    // Gabungkan state loading untuk tampilan yang lebih bersih
    if (profileAsync.isLoading || statsAsync.isLoading) {
      return const HomePageSkeleton(); // Tampilkan skeleton jika salah satu sedang loading
    }

    // 2. BUNGKUS DENGAN REFRESH INDICATOR
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        // pastikan bisa di-scroll bahkan jika konten sedikit
        physics: const AlwaysScrollableScrollPhysics(), 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gunakan `profileAsync.value` karena kita sudah handle loading di atas
            if (profileAsync.hasValue)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo,\n${profileAsync.value!.name}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
                  ),
                  const Text(
                    "Berikut Ringkasan Pekerjaan Anda",
                    style: TextStyle(fontSize: 14, color: AppColors.black),
                  ),
                ],
              ),
            // Handle jika ada error pada profile
            if (profileAsync.hasError)
              const Text("Gagal memuat nama pengguna.", style: TextStyle(color: Colors.red)),

            const SizedBox(height: 16),
            AnimatedToggleSwitch(
              isMonthSelected: timeRange == 'month',
              onMonthTap: () => ref.read(timeRangeProvider.notifier).state = 'month',
              onYearTap: () => ref.read(timeRangeProvider.notifier).state = 'year',
            ),
            const SizedBox(height: 16),
            
            // Gunakan `statsAsync.value` karena loading sudah di-handle
            if (statsAsync.hasValue)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: SummaryCard(title: 'Total Ulok', value: statsAsync.value!.totalUlok.toString())),
                      const SizedBox(width: 16),
                      Expanded(child: SummaryCard(title: 'Ulok Approved', value: statsAsync.value!.ulokApproved.toString())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LineChartCard(data: statsAsync.value!.monthlyApprovedData),
                  const SizedBox(height: 16),
                  DonutChartCard(data: statsAsync.value!.statusCounts),
                ],
              ),
            // Handle jika ada error pada statistik
            if (statsAsync.hasError)
              Center(child: Text('Gagal memuat statistik: ${statsAsync.error}')),
          ],
        ),
      ),
    );
  }
}

