import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';
import 'package:midi_location/features/statistik/presentation/providers/statistic_provider.dart';

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
    final chartType = ref.watch(chartTypeProvider);
    final double total;
    final double approvedPerc;
    final double inProgressPerc;
    final double rejectedPerc;
    final String title;
    final int approvedCount;
    final int inProgressCount;
    final int rejectedCount;

    if (chartType == ChartType.ulok) {
      total = data.statusUlokTotal.toDouble();
      approvedCount = data.statusUlokApproved;
      inProgressCount = data.statusUlokInprogress;
      rejectedCount = data.statusUlokRejected;
      title = "Status ULOK";
    } else {
      total = data.statusKpltTotal.toDouble();
      approvedCount = data.statusKpltApproved;
      inProgressCount = data.statusKpltInprogress;
      rejectedCount = data.statusKpltRejected;
      title = "Status KPLT Saya";
    }

    approvedPerc = total > 0 ? (approvedCount / total) * 100 : 0;
    inProgressPerc = total > 0 ? (inProgressCount / total) * 100 : 0;
    rejectedPerc = total > 0 ? (rejectedCount / total) * 100 : 0;

    final double totalPerc = approvedPerc + inProgressPerc + rejectedPerc;

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                CupertinoSegmentedControl<ChartType>(
                  children: const {
                    ChartType.ulok: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("ULOK"),
                    ),
                    ChartType.kplt: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("KPLT"),
                    ),
                  },
                  groupValue: chartType,
                  onValueChanged: (ChartType newValue) {
                    ref.read(chartTypeProvider.notifier).state = newValue;
                  },
                  selectedColor: AppColors.primaryColor,
                  unselectedColor: Colors.grey[200],
                  borderColor: Colors.grey[400],
                  pressedColor: AppColors.primaryColor.withOpacity(0.2),
                  padding: EdgeInsets.zero,
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
