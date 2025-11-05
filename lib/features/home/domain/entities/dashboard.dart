class DashboardStats {
  final int totalUlok;
  final int totalKplt;
  final int totalTugas;
  final int totalGo;
  final Map<String, int> ulokStatusCounts;
  final Map<String, int> kpltStatusCounts;
  final Map<String, int> tugasStatusCounts;
  final Map<String, int> goStatusCounts;
  final List<MonthlyData> monthlyUlokData;
  final List<MonthlyData> monthlyKpltData;
  final List<MonthlyData> monthlyTugasData;
  final List<MonthlyData> monthlyGoData;

  DashboardStats({
    required this.totalUlok,
    required this.totalKplt,
    required this.ulokStatusCounts,
    required this.kpltStatusCounts,
    required this.monthlyUlokData,
    required this.monthlyKpltData,
    required this.totalTugas,
    required this.totalGo,
    required this.tugasStatusCounts,
    required this.goStatusCounts,
    required this.monthlyTugasData,
    required this.monthlyGoData,
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
