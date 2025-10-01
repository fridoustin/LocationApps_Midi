class DashboardStats {
  final int totalUlok;
  final int totalKplt;
  final Map<String, int> ulokStatusCounts;
  final Map<String, int> kpltStatusCounts;
  final List<MonthlyData> monthlyUlokData;
  final List<MonthlyData> monthlyKpltData;

  DashboardStats({
    required this.totalUlok,
    required this.totalKplt,
    required this.ulokStatusCounts,
    required this.kpltStatusCounts,
    required this.monthlyUlokData,
    required this.monthlyKpltData,
  });
}

class MonthlyData {
  final String month;
  final int total;
  final int approved;
  final int ok;
  final int nok;
  final int inProgress;

  MonthlyData({
    required this.month,
    required this.total,
    required this.approved,
    required this.ok,
    required this.nok,
    required this.inProgress,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      approved: (json['approved'] as num?)?.toInt() ?? 0,
      ok: (json['ok'] as num?)?.toInt() ?? 0,
      nok: (json['nok'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
    );
  }
}
