import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';
import 'package:midi_location/features/statistik/presentation/providers/statistic_provider.dart';
import 'package:midi_location/features/statistik/presentation/widgets/statistic_toggle.dart';

class UlokStatusCard extends ConsumerWidget {
  final StatisticData data;
  const UlokStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(statisticDateProvider);
    final String formattedDate = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(selectedDate);
    final chartType = ref.watch(monthlyChartTypeProvider);
    final double total;
    final double approvedPerc;
    final double inProgressPerc;
    final double rejectedPerc;
    final double waitingForumPerc;
    final String title;
    final int approvedCount;
    final int inProgressCount;
    final int rejectedCount;
    final int waitingForumCount;

    if (chartType == ChartType.ulok) {
      total = data.statusUlokTotal.toDouble();
      approvedCount = data.statusUlokApproved;
      inProgressCount = data.statusUlokInprogress;
      rejectedCount = data.statusUlokRejected;
      waitingForumCount = 0;
      title = "Status ULOK";
    } else {
      total = data.statusKpltTotal.toDouble();
      approvedCount = data.statusKpltApproved;
      inProgressCount = data.statusKpltInprogress;
      rejectedCount = data.statusKpltRejected;
      waitingForumCount = data.statusKpltWaitingForum;
      title = "Status KPLT";
    }

    approvedPerc = total > 0 ? (approvedCount / total) * 100 : 0;
    inProgressPerc = total > 0 ? (inProgressCount / total) * 100 : 0;
    rejectedPerc = total > 0 ? (rejectedCount / total) * 100 : 0;
    waitingForumPerc = total > 0 ? (waitingForumCount / total) * 100 : 0;

    final double totalPerc =
        approvedPerc + inProgressPerc + rejectedPerc + waitingForumPerc;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        color: AppColors.successColor,
        value:
            totalPerc > 100 ? (approvedPerc / totalPerc) * 100 : approvedPerc,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.blue,
        value:
            totalPerc > 100
                ? (inProgressPerc / totalPerc) * 100
                : inProgressPerc,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.warningColor,
        value:
            totalPerc > 100
                ? (waitingForumPerc / totalPerc) * 100
                : waitingForumPerc,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.errorColor,
        value:
            totalPerc > 100 ? (rejectedPerc / totalPerc) * 100 : rejectedPerc,
        title: '',
        radius: 20,
      ),
    ];

    if (total == 0) {
      sections = [
        PieChartSectionData(
          color: Colors.grey[300],
          value: 100,
          title: '',
          radius: 20,
        ),
      ];
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatisticToggle(
                  currentType: chartType,
                  onUlokPressed:
                      (type) =>
                          ref.read(monthlyChartTypeProvider.notifier).state =
                              type,
                  onKpltPressed:
                      (type) =>
                          ref.read(monthlyChartTypeProvider.notifier).state =
                              type,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(enabled: false),
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${total.toInt()} Total Diajukan",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        AppColors.successColor,
                        "Approved",
                        "$approvedCount Usulan Disetujui",
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        AppColors.blue,
                        "In Progress",
                        "$inProgressCount Usulan Diproses",
                      ),
                      const SizedBox(height: 8),
                      if (chartType == ChartType.kplt)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildLegendItem(
                            AppColors.warningColor,
                            "Waiting for Forum",
                            "$waitingForumCount Usulan Menunggu",
                          ),
                        ),
                      _buildLegendItem(
                        AppColors.errorColor,
                        "Rejected",
                        "$rejectedCount Usulan Ditolak",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
