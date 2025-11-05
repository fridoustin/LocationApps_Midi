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

final selectedYearProvider = StateProvider<int?>((ref) => null);
final selectedMonthProvider = StateProvider<int?>((ref) => null);

final dataFilterYearProvider = StateProvider<int>((ref) => DateTime.now().year);
final dataFilterMonthProvider = StateProvider<int?>(
  (ref) => DateTime.now().month,
);

final selectedDashboardViewProvider = StateProvider<DashboardView>(
  (ref) => DashboardView.ulok,
);

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final yearToFetch = ref.watch(dataFilterYearProvider);

  return ref
      .watch(dashboardRepositoryProvider)
      .getDashboardStats(year: yearToFetch, month: null);
});

final filteredDashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((
  ref,
) {
  final asyncStats = ref.watch(dashboardStatsProvider);
  final monthToFilter = ref.watch(dataFilterMonthProvider);

  return asyncStats.when(
    data: (stats) {
      if (monthToFilter == null) {
        return AsyncValue.data(stats);
      }

      final monthIndex = monthToFilter - 1;

      if (monthIndex >= 0 &&
          monthIndex < stats.monthlyUlokData.length &&
          monthIndex < stats.monthlyKpltData.length &&
          monthIndex < stats.monthlyTugasData.length && 
          monthIndex < stats.monthlyGoData.length) {   
        
        final ulokDataForMonth = stats.monthlyUlokData[monthIndex];
        final kpltDataForMonth = stats.monthlyKpltData[monthIndex];
        final tugasDataForMonth = stats.monthlyTugasData[monthIndex]; 
        final goDataForMonth = stats.monthlyGoData[monthIndex];       

        return AsyncValue.data(
          DashboardStats(
            totalUlok: ulokDataForMonth.total,
            totalKplt: kpltDataForMonth.total,
            totalTugas: tugasDataForMonth.total, 
            totalGo: goDataForMonth.total,     
            ulokStatusCounts: {
              'OK': ulokDataForMonth.ok,
              'NOK': ulokDataForMonth.nok,
              'In Progress': ulokDataForMonth.inProgress,
            },
            kpltStatusCounts: {
              'OK': kpltDataForMonth.approved,
              'NOK': kpltDataForMonth.total - kpltDataForMonth.approved,
              'In Progress': 0,
            },
            tugasStatusCounts: {
              'OK': tugasDataForMonth.ok,
              'NOK': tugasDataForMonth.nok,
              'In Progress': tugasDataForMonth.inProgress,
            },
            goStatusCounts: {
              'OK': goDataForMonth.ok,
              'NOK': goDataForMonth.nok,
              'In Progress': goDataForMonth.inProgress,
            },

            monthlyUlokData: stats.monthlyUlokData,
            monthlyKpltData: stats.monthlyKpltData,
            monthlyTugasData: stats.monthlyTugasData,
            monthlyGoData: stats.monthlyGoData,
          ),
        );
      }

      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});