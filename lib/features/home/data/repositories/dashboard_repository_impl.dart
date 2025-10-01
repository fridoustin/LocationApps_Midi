import 'package:midi_location/features/home/data/datasources/dashboard_remote_datasource.dart';
import 'package:midi_location/features/home/domain/entities/dashboard.dart';
import 'package:midi_location/features/home/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _dataSource;
  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<DashboardStats> getDashboardStats({
    required int year,
    int? month,
  }) async {
    try {
      final data = await _dataSource.getDashboardStats(
        year: year,
        month: month,
      );

      List<MonthlyData> parseMonthlyData(List<dynamic>? rawData) {
        if (rawData == null) return [];
        return rawData
            .map((item) => MonthlyData.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      final monthlyUlokData = parseMonthlyData(data['monthly_ulok_data']);
      final monthlyKpltData = parseMonthlyData(data['monthly_kplt_data']);

      return DashboardStats(
        totalUlok: (data['total_ulok'] as num?)?.toInt() ?? 0,
        totalKplt: (data['total_kplt'] as num?)?.toInt() ?? 0,

        ulokStatusCounts: Map<String, int>.from(
          data['ulok_status_counts'] ?? {},
        ),
        kpltStatusCounts: Map<String, int>.from(
          data['kplt_status_counts'] ?? {},
        ),
        monthlyUlokData: monthlyUlokData,
        monthlyKpltData: monthlyKpltData,
      );
    } catch (e) {
      print('Error parsing dashboard stats: $e');
      rethrow;
    }
  }
}
