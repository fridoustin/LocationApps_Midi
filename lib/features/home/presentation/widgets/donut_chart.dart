import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class DonutChartCard extends StatefulWidget {
  final String title;
  final Map<String, int> data;

  const DonutChartCard({super.key, required this.title, required this.data});

  @override
  State<DonutChartCard> createState() => _DonutChartCardState();
}

class _DonutChartCardState extends State<DonutChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final okCount = widget.data['OK'] ?? 0;
    final nokCount = widget.data['NOK'] ?? 0;
    final inProgressCount = widget.data['In Progress'] ?? 0;
    final total = okCount + nokCount + inProgressCount;

    List<PieChartSectionData> _buildChartSections() {
      if (total == 0) {
        return [
          PieChartSectionData(
            color: Colors.grey.shade300,
            value: 1,
            title: '',
            radius: 30,
          ),
        ];
      }

      final sectionsData = [
        {'value': okCount, 'color': AppColors.successColor},
        {'value': nokCount, 'color': AppColors.primaryColor},
        {'value': inProgressCount, 'color': AppColors.warningColor},
      ];

      return List.generate(sectionsData.length, (i) {
        final isTouched = i == _touchedIndex;
        final value = (sectionsData[i]['value'] as int).toDouble();
        final color = sectionsData[i]['color'] as Color;

        final double radius = isTouched ? 40 : 30;
        final double fontSize = isTouched ? 16 : 12;
        final String titleText =
            isTouched
                ? value.toInt().toString()
                : '${(value / total * 100).toStringAsFixed(0)}%';

        return PieChartSectionData(
          color: color,
          value: value,
          title: titleText,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        );
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.secondaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: total == 0 ? 0 : 2,
                  centerSpaceRadius: 35,
                  startDegreeOffset: -90,
                  sections: _buildChartSections(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
