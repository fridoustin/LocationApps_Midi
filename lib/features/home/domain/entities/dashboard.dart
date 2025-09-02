class DashboardStats {
  final int totalUlok;
  final int ulokApproved;
  final List<MonthlyApproved> monthlyApprovedData;
  final Map<String, int> statusCounts;

  DashboardStats({
    required this.totalUlok,
    required this.ulokApproved,
    required this.monthlyApprovedData,
    required this.statusCounts,
  });
}

class MonthlyApproved {
  final int month;
  final int count;

  MonthlyApproved({required this.month, required this.count});
}
