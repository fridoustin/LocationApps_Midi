import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';
import 'package:midi_location/features/statistik/presentation/providers/statistic_provider.dart';

class AnnualUlokChart extends ConsumerWidget {
  final StatisticData data;
  const AnnualUlokChart({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(statisticDateProvider).year;
    final chartType = ref.watch(chartTypeProvider);
    final List<AnnualChartData> chartData;
    final String title;
    if (chartType == ChartType.ulok) {
      chartData = data.chartAnnualData;
      title = "Total ULOK Tahun $selectedYear";
    } else {
      chartData = data.chartAnnualKpltData;
      title = "Total KPLT Tahun $selectedYear";
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
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
                            (val, meta) => _bottomTitles(
                              val,
                              meta,
                              chartData,
                            ),
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
                  barGroups: _getBarGroups(chartData),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(AppColors.successColor, "Approved"),
                _buildLegend(AppColors.errorColor, "Rejected"),
                _buildLegend(AppColors.blue, "In Progress"),
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
      if (data.totalUlok.toDouble() > maxVal)
        maxVal = data.totalUlok.toDouble();
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

  List<BarChartGroupData> _getBarGroups(List<AnnualChartData> chartData) {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];

      final double approved = data.totalApproved.toDouble();
      final double rejected = data.totalRejected.toDouble();
      final double inProgress = data.totalInprogress.toDouble();
      final double totalStack = approved + rejected + inProgress;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalStack,
            width: 12,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: [
              BarChartRodStackItem(0, approved, AppColors.successColor),
              BarChartRodStackItem(
                approved,
                approved + rejected,
                AppColors.errorColor,
              ),
              BarChartRodStackItem(
                approved + rejected,
                totalStack,
                AppColors.blue,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
