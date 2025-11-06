import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/statistik/domain/entities/statistic_data.dart';

class SummaryGrid extends StatelessWidget {
  final StatisticData data;
  const SummaryGrid({super.key, required this.data});

  double _calculatePercentage(int current, int lastMonth) {
    if (lastMonth == 0) {
      if (current > 0) return 100.0;
      return 0.0;
    }
    return ((current - lastMonth) / lastMonth) * 100;
  }

  @override
  Widget build(BuildContext context) {
    double ulokDiajukanPerc = _calculatePercentage(
      data.ringkasanUlokDiajukan,
      data.ringkasanUlokDiajukanVsLastMonth,
    );
    double ulokApprovedPerc = _calculatePercentage(
      data.ringkasanUlokApproved,
      data.ringkasanUlokApprovedVsLastMonth,
    );
    double kpltAktifPerc = _calculatePercentage(
      data.ringkasanKpltAktif,
      data.ringkasanKpltAktifVsLastMonth,
    );
    double tugasSelesaiPerc = _calculatePercentage(
      data.ringkasanTugasSelesai,
      data.ringkasanTugasSelesaiVsLastMonth,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        children: [
          _RingkasanCard(
            title: 'ULOK Diajukan',
            count: data.ringkasanUlokDiajukan.toString(),
            iconPath: 'assets/icons/loc.svg',
            backgroundColor: AppColors.cardBlue,
            percentage: ulokDiajukanPerc,
            lastMonthValue: data.ringkasanUlokDiajukanVsLastMonth,
          ),
          _RingkasanCard(
            title: 'ULOK Approved',
            count: data.ringkasanUlokApproved.toString(),
            iconPath: 'assets/icons/loc.svg',
            backgroundColor: AppColors.successColor,
            percentage: ulokApprovedPerc,
            lastMonthValue: data.ringkasanUlokApprovedVsLastMonth,
          ),
          _RingkasanCard(
            title: 'KPLT Aktif',
            count: data.ringkasanKpltAktif.toString(),
            iconPath: 'assets/icons/kplt.svg',
            backgroundColor: AppColors.cardOrange,
            percentage: kpltAktifPerc,
            lastMonthValue: data.ringkasanKpltAktifVsLastMonth,
          ),
          _RingkasanCard(
            title: 'Tugas Selesai',
            count: data.ringkasanTugasSelesai.toString(),
            iconPath: 'assets/icons/penugasan.svg',
            backgroundColor: AppColors.primaryColor,
            percentage: tugasSelesaiPerc,
            lastMonthValue: data.ringkasanTugasSelesaiVsLastMonth,
          ),
        ],
      ),
    );
  }
}

class _RingkasanCard extends StatelessWidget {
  final String title;
  final String count;
  final String iconPath;
  final Color backgroundColor;
  final double percentage;
  final int lastMonthValue;

  const _RingkasanCard({
    required this.title,
    required this.count,
    required this.iconPath,
    required this.backgroundColor,
    required this.percentage,
    required this.lastMonthValue,
  });

  @override
  Widget build(BuildContext context) {
    const double outerRadius = 14.0;
    const double innerRadius = 12.0;
    const double highlightWidth = 5.0;
    const double iconBackgroundSize = 40.0;
    const double iconSize = 24.0;

    final bool isIncrease = percentage >= 0;
    final Color percColor =
        isIncrease ? AppColors.successColor : AppColors.errorColor;
    final int currentValue = int.tryParse(count) ?? 0;
    String percText;
    bool showArrow;

    if (lastMonthValue == 0 && currentValue > 0) {
      percText = "+$currentValue dari bulan lalu";
      showArrow = true;
    } else if (lastMonthValue == 0 && currentValue == 0) {
      percText = "0 dari bulan lalu";
      showArrow = false;
    } else {
      percText = "${percentage.toStringAsFixed(0)}% dari bulan lalu";
      showArrow = true;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(outerRadius),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.only(left: highlightWidth),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(innerRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          count,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (showArrow)
                          Icon(
                            isIncrease
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: percColor,
                            size: 14,
                          ),
                        if (showArrow) const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            percText,
                            style: TextStyle(fontSize: 11, color: percColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: iconBackgroundSize,
                height: iconBackgroundSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
