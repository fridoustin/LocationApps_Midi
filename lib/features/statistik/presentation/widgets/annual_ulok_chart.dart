import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';
import 'package:midi_location/features/statistik/presentation/providers/statistic_provider.dart';
import 'package:midi_location/features/statistik/presentation/widgets/statistic_toggle.dart';

class AnnualUlokChart extends ConsumerWidget {
  final StatisticData data;
  const AnnualUlokChart({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(statisticDateProvider).year;
    final chartType = ref.watch(annualChartTypeProvider);
    final List<AnnualChartData> chartData;
    final String mainTitle;
    if (chartType == ChartType.ulok) {
      chartData = data.chartAnnualData;
      mainTitle = "Total ULOK";
    } else {
      chartData = data.chartAnnualKpltData;
      mainTitle = "Total KPLT";
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainTitle,
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
                            selectedYear.toString(),
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
                          ref.read(annualChartTypeProvider.notifier).state =
                              type,
                  onKpltPressed:
                      (type) =>
                          ref.read(annualChartTypeProvider.notifier).state =
                              type,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(chartData),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (val, meta) => _bottomTitles(val, meta, chartData),
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: _getBarGroups(chartData, chartType),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _buildLegend(AppColors.successColor, "Approved"),
                ),
                const SizedBox(width: 4),
                Flexible(child: _buildLegend(AppColors.errorColor, "Rejected")),
                const SizedBox(width: 4),
                Flexible(child: _buildLegend(AppColors.blue, "In Progress")),
                if (chartType == ChartType.kplt) const SizedBox(width: 4),
                if (chartType == ChartType.kplt)
                  Flexible(
                    child: _buildLegend(
                      AppColors.warningColor,
                      "Waiting Forum",
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<AnnualChartData> chartData) {
    double maxVal = 0;
    for (var data in chartData) {
      if (data.totalUlok.toDouble() > maxVal) {
        maxVal = data.totalUlok.toDouble();
      }
    }
    if (maxVal == 0) return 10;
    return (maxVal * 1.2);
  }

  Widget _bottomTitles(
    double value,
    TitleMeta meta,
    List<AnnualChartData> chartData,
  ) {
    final titles = chartData.map((d) => d.month).toList();
    final Widget text = Text(
      titles.length > value.toInt() ? titles[value.toInt()] : '',
      style: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
    return SideTitleWidget(meta: meta, space: 16, child: text);
  }

  List<BarChartGroupData> _getBarGroups(
    List<AnnualChartData> chartData,
    ChartType chartType,
  ) {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];
      final double approved = data.totalApproved.toDouble();
      final double rejected = data.totalRejected.toDouble();
      final double inProgress = data.totalInprogress.toDouble();
      final double waitingForum =
          (chartType == ChartType.kplt)
              ? data.totalWaitingForum.toDouble()
              : 0.0;
      final double totalStack = approved + rejected + inProgress + waitingForum;

      List<BarChartRodStackItem> stackItems = [
        BarChartRodStackItem(0, approved, AppColors.successColor),
        BarChartRodStackItem(
          approved,
          approved + rejected,
          AppColors.errorColor,
        ),
        BarChartRodStackItem(
          approved + rejected,
          approved + rejected + inProgress,
          AppColors.blue,
        ),
      ];

      if (chartType == ChartType.kplt) {
        stackItems.add(
          BarChartRodStackItem(
            approved + rejected + inProgress,
            totalStack,
            AppColors.warningColor,
          ),
        );
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalStack,
            width: 12,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: stackItems,
          ),
        ],
      );
    });
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
