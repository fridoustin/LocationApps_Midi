import 'package:midi_location/features/home/data/datasources/dashboard_remote_datasource.dart';
import 'package:midi_location/features/home/domain/entities/dashboard.dart';
import 'package:midi_location/features/home/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _dataSource;
  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<DashboardStats> getDashboardStats({required String timeRange}) async {
    final data = await _dataSource.getDashboardStats(timeRange: timeRange);
    
    // Parsing data JSON dari Supabase menjadi objek Dart
    return DashboardStats(
      totalUlok: data['total_ulok'] ?? 0,
      ulokApproved: data['ulok_approved'] ?? 0,
      monthlyApprovedData: (data['monthly_data'] as List<dynamic>?)
          ?.map((e) => MonthlyApproved(month: e['month'], count: e['count']))
          .toList() ?? [],
      statusCounts: Map<String, int>.from(data['status_counts'] ?? {}),
    );
  }
}
