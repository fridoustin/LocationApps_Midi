import 'package:midi_location/features/home/domain/entities/dashboard.dart';

abstract class DashboardRepository {
  // Ambil semua data statistik berdasarkan rentang waktu (bulan/tahun)
  Future<DashboardStats> getDashboardStats({required String timeRange});
}