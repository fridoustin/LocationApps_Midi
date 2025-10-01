import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class CustomMonthPicker {
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    Color primaryColor = Colors.red,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final defaultFirstDate = firstDate ?? DateTime(now.year - 10, 1);
    final defaultLastDate = lastDate ?? DateTime(now.year + 1, 12);
    
    return await showMonthPicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: defaultFirstDate,
      lastDate: defaultLastDate,
      monthStylePredicate: (date) {
        if (date.month == now.month && date.year == now.year) {
          return TextButton.styleFrom(
            backgroundColor: primaryColor.withOpacity(0.15),
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(70, 70),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        
        return TextButton.styleFrom(
          minimumSize: const Size(70, 70),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      },
      yearStylePredicate: (year) {
        if (year == now.year) {
          return TextButton.styleFrom(
            backgroundColor: primaryColor.withOpacity(0.1),
            foregroundColor: primaryColor,
            minimumSize: const Size(80, 60),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          );
        }
        
        return TextButton.styleFrom(
          minimumSize: const Size(80, 60),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        );
      },
      
      monthPickerDialogSettings: MonthPickerDialogSettings(
        headerSettings: PickerHeaderSettings(
          headerBackgroundColor: primaryColor,
          headerSelectedIntervalTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headerCurrentPageTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        dateButtonsSettings: PickerDateButtonsSettings(
          selectedMonthBackgroundColor: primaryColor,
          selectedMonthTextColor: Colors.white,
          unselectedMonthsTextColor: Colors.black87,
          currentMonthTextColor: primaryColor,
          selectedYearTextColor: Colors.white,
          unselectedYearsTextColor: Colors.black87,
          currentYearTextColor: primaryColor,
          selectedDateRadius: 12.0,
          buttonBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          monthTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          yearTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
        ),
        
        dialogSettings: PickerDialogSettings(
          dialogRoundedCornersRadius: 16.0,
          dialogBackgroundColor: Colors.white,
        ),
        
        actionBarSettings: PickerActionBarSettings(
          actionBarPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 16,
          ),
          confirmWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          cancelWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}