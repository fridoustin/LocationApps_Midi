// lib/features/home/presentation/provider/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/home/data/datasources/dashboard_remote_datasource.dart';
import 'package:midi_location/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:midi_location/features/home/domain/entities/dashboard.dart';
import 'package:midi_location/features/home/domain/repositories/dashboard_repository.dart';

enum DashboardView { ulok, kplt }

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource(ref.watch(supabaseClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final selectedYearProvider = StateProvider<int?>((ref) => DateTime.now().year);
final selectedMonthProvider = StateProvider<int?>(
  (ref) => DateTime.now().month,
);

final selectedDashboardViewProvider = StateProvider<DashboardView>(
  (ref) => DashboardView.ulok,
);

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final selectedYear = ref.watch(selectedYearProvider);
  final yearToFetch = selectedYear ?? DateTime.now().year;
  ref.watch(selectedYearProvider);

  return ref
      .watch(dashboardRepositoryProvider)
      .getDashboardStats(year: yearToFetch, month: null);
});

final filteredDashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((
  ref,
) {
  final asyncStats = ref.watch(dashboardStatsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final selectedYear = ref.watch(selectedYearProvider);

  return asyncStats.when(
    data: (stats) {
      List<MonthlyData> createEmptyMonthlyData() {
        const List<String> monthNames = [
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
        return monthNames.map((monthName) {
          return MonthlyData(
            month: monthName,
            total: 0,
            approved: 0,
            ok: 0,
            nok: 0,
            inProgress: 0,
          );
        }).toList();
      }

      if (selectedMonth == null && selectedYear == null) {
        final emptyMonthlyData = createEmptyMonthlyData();
        return AsyncValue.data(
          DashboardStats(
            totalUlok: 0,
            totalKplt: 0,
            ulokStatusCounts: {'OK': 0, 'NOK': 0, 'In Progress': 0},
            kpltStatusCounts: {'OK': 0, 'NOK': 0, 'In Progress': 0},
            monthlyUlokData: emptyMonthlyData,
            monthlyKpltData: emptyMonthlyData,
          ),
        );
      }

      if (selectedMonth != null) {
        final monthIndex = selectedMonth - 1;
        if (monthIndex >= 0 && monthIndex < stats.monthlyUlokData.length) {
          final ulokDataForMonth = stats.monthlyUlokData[monthIndex];
          final kpltDataForMonth = stats.monthlyKpltData[monthIndex];

          return AsyncValue.data(
            DashboardStats(
              totalUlok: ulokDataForMonth.total,
              totalKplt: kpltDataForMonth.total,
              ulokStatusCounts: {
                'OK': ulokDataForMonth.ok,
                'NOK': ulokDataForMonth.nok,
                'In Progress': ulokDataForMonth.inProgress,
              },
              kpltStatusCounts: {
                'OK': kpltDataForMonth.approved,
                'NOK': 0,
                'In Progress': 0,
              },

              monthlyUlokData:
                  selectedYear != null
                      ? stats.monthlyUlokData
                      : createEmptyMonthlyData(),
              monthlyKpltData:
                  selectedYear != null
                      ? stats.monthlyKpltData
                      : createEmptyMonthlyData(),
            ),
          );
        }
      }

      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
