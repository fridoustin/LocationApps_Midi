// ignore: file_names
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/home/domain/entities/dashboard.dart';

class LineChartCard extends StatelessWidget {
  final List<MonthlyApproved> data;
  const LineChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Siapkan data untuk 12 bulan, isi 0 jika tidak ada data
    final spots = List.generate(12, (index) {
      final monthData = data.where((d) => d.month == index + 1).firstOrNull;
      return FlSpot((index + 1).toDouble(), monthData?.count.toDouble() ?? 0);
    });

    return Card(
      color: AppColors.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Ulok Approved", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(fontSize: 12);
                          switch (value.toInt()) {
                            case 1: return const Text('Jan', style: style);
                            case 2: return const Text('Feb', style: style);
                            case 3: return const Text('Mar', style: style);
                            case 4: return const Text('Apr', style: style);
                            case 5: return const Text('Mei', style: style);
                            case 6: return const Text('Jun', style: style);
                            case 7: return const Text('Jul', style: style);
                            case 8: return const Text('Agu', style: style);
                            case 9: return const Text('Sep', style: style);
                            case 10: return const Text('Okt', style: style);
                            case 11: return const Text('Nov', style: style);
                            case 12: return const Text('Des', style: style);
                            default: return const Text('', style: style);
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: AppColors.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
