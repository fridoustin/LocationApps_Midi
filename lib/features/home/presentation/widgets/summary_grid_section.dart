import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'summary_card.dart';
import 'skeletons/summary_grid_skeleton.dart';

class SummaryGridSection extends ConsumerWidget {
  const SummaryGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final String totalUlok = stats.totalUlok.toString();
        final String totalKPLT = stats.totalKplt.toString();
        const String tugasAktif = "0";
        const String perpanjangan = "0";

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.7,
          children: [
            SummaryCard(
              title: 'Total Ulok',
              count: totalUlok,
              iconPath: 'assets/icons/loc.svg',
              backgroundColor: AppColors.cardBlue,
            ),
            SummaryCard(
              title: 'Total KPLT',
              count: totalKPLT,
              iconPath: 'assets/icons/kplt.svg',
              backgroundColor: AppColors.successColor,
            ),
            SummaryCard(
              title: 'Tugas Aktif',
              count: tugasAktif,
              iconPath: 'assets/icons/penugasan.svg',
              backgroundColor: AppColors.primaryColor,
            ),
            SummaryCard(
              title: 'Perpanjangan',
              count: perpanjangan,
              iconPath: 'assets/icons/perpanjangan.svg',
              backgroundColor: AppColors.warningColor,
            ),
          ],
        );
      },
      loading: () => const SummaryGridSkeleton(),
      error:
          (err, stack) => Center(child: Text('Gagal memuat statistik: $err')),
    );
  }
}
