import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/home/data/datasources/dashboard_remote_datasource.dart';
import 'package:midi_location/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:midi_location/features/home/domain/entities/dashboard.dart';
import 'package:midi_location/features/home/domain/repositories/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.watch(supabaseClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

// Provider untuk mengelola state time range (Month/Year)
final timeRangeProvider = StateProvider<String>((ref) => 'month');

// Provider utama untuk mengambil data statistik
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final timeRange = ref.watch(timeRangeProvider);
  return ref.watch(dashboardRepositoryProvider).getDashboardStats(timeRange: timeRange);
});
