// lib/features/statistik/domain/entities/statistic_data.dart

class StatisticData {
  final int performaApproved;
  final int performaTarget;
  final int ringkasanUlokDiajukan;
  final int ringkasanUlokDiajukanVsLastMonth;
  final int ringkasanUlokApproved;
  final int ringkasanUlokApprovedVsLastMonth;
  final int ringkasanKpltAktif;
  final int ringkasanKpltAktifVsLastMonth;
  final int ringkasanTugasSelesai;
  final int ringkasanTugasSelesaiVsLastMonth;
  final List<AnnualChartData> chartAnnualData;
  final List<AnnualChartData> chartAnnualKpltData;
  final int statusUlokTotal;
  final int statusUlokApproved;
  final int statusUlokInprogress;
  final int statusUlokRejected;
  final int statusKpltTotal;
  final int statusKpltApproved;
  final int statusKpltInprogress;
  final int statusKpltRejected;
  final int penugasanSelesai;
  final int penugasanBerjalan;

  StatisticData({
    required this.performaApproved,
    required this.performaTarget,
    required this.ringkasanUlokDiajukan,
    required this.ringkasanUlokDiajukanVsLastMonth,
    required this.ringkasanUlokApproved,
    required this.ringkasanUlokApprovedVsLastMonth,
    required this.ringkasanKpltAktif,
    required this.ringkasanKpltAktifVsLastMonth,
    required this.ringkasanTugasSelesai,
    required this.ringkasanTugasSelesaiVsLastMonth,
    required this.chartAnnualData,
    required this.chartAnnualKpltData,
    required this.statusUlokTotal,
    required this.statusUlokApproved,
    required this.statusUlokInprogress,
    required this.statusUlokRejected,
    required this.statusKpltTotal,
    required this.statusKpltApproved,
    required this.statusKpltInprogress,
    required this.statusKpltRejected,
    required this.penugasanSelesai,
    required this.penugasanBerjalan,
  });

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    var chartDataList =
        (json['chart_annual_data'] as List? ?? [])
            .map((i) => AnnualChartData.fromJson(i))
            .toList();

    var kpltChartDataList =
        (json['chart_annual_kplt_data'] as List? ?? [])
            .map((i) => AnnualChartData.fromJson(i))
            .toList();

    return StatisticData(
      performaApproved: json['performa_approved'] ?? 0,
      performaTarget: json['performa_target'] ?? 0,
      ringkasanUlokDiajukan: json['ringkasan_ulok_diajukan'] ?? 0,
      ringkasanUlokDiajukanVsLastMonth:
          json['ringkasan_ulok_diajukan_vs_last_month'] ?? 0,
      ringkasanUlokApproved: json['ringkasan_ulok_approved'] ?? 0,
      ringkasanUlokApprovedVsLastMonth:
          json['ringkasan_ulok_approved_vs_last_month'] ?? 0,
      ringkasanKpltAktif: json['ringkasan_kplt_aktif'] ?? 0,
      ringkasanKpltAktifVsLastMonth:
          json['ringkasan_kplt_aktif_vs_last_month'] ?? 0,
      ringkasanTugasSelesai: json['ringkasan_tugas_selesai'] ?? 0,
      ringkasanTugasSelesaiVsLastMonth:
          json['ringkasan_tugas_selesai_vs_last_month'] ?? 0,
      chartAnnualData: chartDataList,
      chartAnnualKpltData: kpltChartDataList,
      statusUlokTotal: json['status_ulok_total'] ?? 0,
      statusUlokInprogress: json['status_ulok_inprogress'] ?? 0,
      statusUlokApproved: json['status_ulok_approved'] ?? 0,
      statusUlokRejected: json['status_ulok_rejected'] ?? 0,
      statusKpltTotal: json['status_kplt_total'] ?? 0,
      statusKpltApproved: json['status_kplt_approved'] ?? 0,
      statusKpltInprogress: json['status_kplt_inprogress'] ?? 0,
      statusKpltRejected: json['status_kplt_rejected'] ?? 0,
      penugasanSelesai: json['penugasan_selesai'] ?? 0,
      penugasanBerjalan: json['penugasan_berjalan'] ?? 0,
    );
  }
}

class AnnualChartData {
  final String month;
  final int totalUlok;
  final int totalApproved;
  final int totalRejected;
  final int totalInprogress;

  AnnualChartData({
    required this.month,
    required this.totalUlok,
    required this.totalApproved,
    required this.totalRejected,
    required this.totalInprogress,
  });

  factory AnnualChartData.fromJson(Map<String, dynamic> json) {
    return AnnualChartData(
      month: json['month'] ?? '',
      totalUlok: json['total_ulok'] ?? 0,
      totalApproved: json['total_approved'] ?? 0,
      totalRejected: json['total_rejected'] ?? 0,
      totalInprogress: json['total_inprogress'] ?? 0,
    );
  }
}
