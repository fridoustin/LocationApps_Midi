import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/home/presentation/widgets/donut_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/line_chart.dart';
import 'package:midi_location/features/home/presentation/widgets/summary_card.dart';
import 'package:midi_location/features/home/presentation/widgets/timerange_button.dart';
// 1. IMPORT PROVIDER PROFIL
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  static const String route = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final timeRange = ref.watch(timeRangeProvider);
    // 2. PANTAU PROVIDER PROFIL DI SINI
    final profileAsync = ref.watch(profileDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Agar toggle rata kiri
        children: [
          // 3. GUNAKAN .when UNTUK MENAMPILKAN NAMA SECARA DINAMIS
          profileAsync.when(
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo,\n${profile.name}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const Text(
                  "Berikut Ringkasan Pekerjaan Anda",
                  style: TextStyle(fontSize: 14, color: AppColors.black),
                ),
              ],
            ),
            loading: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo,\nMemuat...",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const Text(
                  "Berikut Ringkasan Pekerjaan Anda",
                  style: TextStyle(fontSize: 14, color: AppColors.black),
                ),
              ],
            ),
            error: (err, stack) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo,\nUser",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const Text(
                  "Berikut Ringkasan Pekerjaan Anda",
                  style: TextStyle(fontSize: 14, color: AppColors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gunakan widget AnimatedToggleSwitch yang baru
          AnimatedToggleSwitch(
            isMonthSelected: timeRange == 'month',
            onMonthTap: () => ref.read(timeRangeProvider.notifier).state = 'month',
            onYearTap: () => ref.read(timeRangeProvider.notifier).state = 'year',
          ),
          const SizedBox(height: 16),
          
          statsAsync.when(
            data: (stats) => Column(
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                        child: SummaryCard(
                            title: 'Total Ulok',
                            value: stats.totalUlok.toString())),
                    const SizedBox(width: 16),
                    Expanded(
                        child: SummaryCard(
                            title: 'Ulok Approved',
                            value: stats.ulokApproved.toString())),
                  ],
                ),
                const SizedBox(height: 16),

                // Line Chart Card
                LineChartCard(data: stats.monthlyApprovedData),
                const SizedBox(height: 16),

                // Donut Chart Card
                DonutChartCard(data: stats.statusCounts),
              ],
            ),
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor)),
            error: (err, stack) =>
                Center(child: Text('Gagal memuat statistik: $err')),
          ),
        ],
      ),
    );
  }
}

