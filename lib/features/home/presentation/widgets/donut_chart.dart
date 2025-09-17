import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class DonutChartCard extends StatelessWidget {
  final Map<String, int> data;
  const DonutChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final okCount = data['OK'] ?? 0;
    final nokCount = data['NOK'] ?? 0;
    final pendingCount = data['In Progress'] ?? 0;
    final total = okCount + nokCount + pendingCount;

    PieChartSectionData makeSection(
        double value, Color color, String status) {
      final percentage = total == 0 ? 0 : (value / total * 100);
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }

    return Card(
      color: AppColors.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ulok Statistics",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2, // Memberi porsi ruang 2/3 untuk PieChart
                  child: SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          makeSection(pendingCount.toDouble(),
                              const Color(0xFFD9D9D9), 'Pending'),
                          makeSection(nokCount.toDouble(),
                              AppColors.primaryColor, 'NOK'),
                          makeSection(okCount.toDouble(),
                              AppColors.successColor, 'OK'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Indicator(
                          color: Colors.grey, text: 'Pending ($pendingCount)'),
                      const SizedBox(height: 8),
                      _Indicator(
                          color: AppColors.primaryColor,
                          text: 'Ulok NOK ($nokCount)'),
                      const SizedBox(height: 8),
                      _Indicator(
                          color: AppColors.successColor,
                          text: 'Ulok OK ($okCount)'),
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
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}