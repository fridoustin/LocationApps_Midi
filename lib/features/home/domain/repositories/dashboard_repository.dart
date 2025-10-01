// lib/features/home/domain/repositories/dashboard_repository.dart

import 'package:midi_location/features/home/domain/entities/dashboard.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats({required int year, int? month});
}
