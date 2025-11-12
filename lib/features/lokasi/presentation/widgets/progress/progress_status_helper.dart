import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class ProgressStatusHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'grand_opening':
        return AppColors.successColor;
      case 'in_progress':
      case 'mou':
      case 'perizinan':
      case 'notaris':
      case 'renovasi':
        return Colors.orange;
      case 'not_started':
        return Colors.grey;
      default:
        return AppColors.primaryColor;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return 'Selesai';
      case 'in_progress':
        return 'Dalam Progress';
      case 'mou':
        return 'Tahap MOU';
      case 'perizinan':
        return 'Tahap Perizinan';
      case 'notaris':
        return 'Tahap Notaris';
      case 'renovasi':
        return 'Tahap Renovasi';
      case 'grand_opening':
        return 'Grand Opening';
      case 'not_started':
        return 'Belum Dimulai';
      default:
        return status;
    }
  }

  static bool isActiveStep(String stepKey, String currentStatus) {
    if (currentStatus == 'not_started') return stepKey == 'mou';
    if (currentStatus == 'mou') return stepKey == 'izin_tetangga' || stepKey == 'perizinan';
    if (currentStatus == 'perizinan') return stepKey == 'notaris';
    if (currentStatus == 'notaris') return stepKey == 'renovasi';
    if (currentStatus == 'renovasi') return stepKey == 'grand_opening';
    return false;
  }

  static String getCurrentActiveStep(String status) {
    if (status == 'mou') return 'mou';
    if (status == 'perizinan' || status == 'izin_tetangga') return 'perizinan';
    if (status == 'notaris') return 'notaris';
    if (status == 'renovasi') return 'renovasi';
    if (status == 'grand_opening') return 'grand_opening';
    return 'mou';
  }
}