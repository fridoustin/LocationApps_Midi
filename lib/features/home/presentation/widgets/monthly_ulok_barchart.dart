// lib/features/home/presentation/widgets/monthly_ulok_barchart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/home/domain/entities/dashboard.dart';

class MonthlyUlokBarChart extends StatelessWidget {
  final List<MonthlyData> data;
  final int? year;

  const MonthlyUlokBarChart({super.key, required this.data, this.year});

  @override
  Widget build(BuildContext context) {
    final maxYValue = _calculateMaxY(data);

    String chartTitle = "Total ULok";
    if (year != null) {
      chartTitle = "Total ULok - Tahun $year";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chartTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxYValue,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.9),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthData = data[group.x];
                      final displayYear = year ?? DateTime.now().year;
                      return BarTooltipItem(
                        '${monthData.month.substring(0, 3)} $displayYear\n',
                        const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        children: <TextSpan>[
                          _buildTooltipTextSpan(
                            'OK: ',
                            '${monthData.ok}',
                            AppColors.successColor,
                          ),
                          _buildTooltipTextSpan(
                            'NOK: ',
                            '${monthData.nok}',
                            AppColors.primaryColor,
                          ),
                          _buildTooltipTextSpan(
                            'In Progress: ',
                            '${monthData.inProgress}',
                            AppColors.warningColor,
                            isLast: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 != 0) return const SizedBox.shrink();
                        if (value >= meta.max) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[index].month.substring(0, 3),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  checkToShowHorizontalLine: (value) => value % 20 == 0,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    top: const BorderSide(color: Colors.transparent),
                    left: const BorderSide(color: Colors.transparent),
                    right: const BorderSide(color: Colors.transparent),
                  ),
                ),
                barGroups: _generateBarGroups(data),
                alignment: BarChartAlignment.spaceBetween,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  TextSpan _buildTooltipTextSpan(
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return TextSpan(
      style: const TextStyle(fontSize: 12, height: 1.5),
      children: [
        TextSpan(text: label, style: TextStyle(color: color)),
        TextSpan(
          text: value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!isLast) const TextSpan(text: '\n'),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<MonthlyData> displayData) {
    return List.generate(displayData.length, (index) {
      final item = displayData[index];
      final double inProgressEnd = item.inProgress.toDouble();
      final double nokEnd = inProgressEnd + item.nok.toDouble();
      final double okEnd = nokEnd + item.ok.toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: okEnd,
            width: 12,
            borderRadius: BorderRadius.zero,
            rodStackItems: [
              BarChartRodStackItem(0, inProgressEnd, AppColors.warningColor),
              BarChartRodStackItem(
                inProgressEnd,
                nokEnd,
                AppColors.primaryColor,
              ),
              BarChartRodStackItem(nokEnd, okEnd, AppColors.successColor),
            ],
          ),
        ],
      );
    });
  }

  double _calculateMaxY(List<MonthlyData> chartData) {
    if (chartData.isEmpty) return 101.0;
    double maxVal = 0;
    for (var item in chartData) {
      final currentTotal = item.ok + item.nok + item.inProgress;
      if (currentTotal > maxVal) {
        maxVal = currentTotal.toDouble();
      }
    }
    double calculatedMax = (maxVal / 20).ceil() * 20.0;
    if (calculatedMax < 100) calculatedMax = 100.0;
    return calculatedMax + 1;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Indicator(color: AppColors.successColor, text: 'OK'),
        _Indicator(color: AppColors.primaryColor, text: 'NOK'),
        _Indicator(color: AppColors.warningColor, text: 'In Progress'),
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const _Indicator({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
