import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class ProgressStatusHelper {
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Grand Opening':
        return AppColors.successColor;
      case 'Mou':
      case 'Izin Tetangga':
      case 'Perizinan':
      case 'Notaris':
      case 'Renovasi':
        return Colors.orange;
      case 'Not Started':
        return Colors.grey;
      default:
        return AppColors.primaryColor;
    }
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case 'Grand Opening':
        return 'Grand Opening';
      case 'Mou':
        return 'Tahap MOU';
      case 'Izin Tetangga':
      case 'Perizinan':
        return 'Tahap Perizinan';
      case 'Notaris':
        return 'Tahap Notaris';
      case 'Renovasi':
        return 'Tahap Renovasi';
      case 'Not Started':
        return 'Belum Dimulai';
      default:
        return status;
    }
  }

  static bool isActiveStep(String stepKey, String currentStatus) {
    if (currentStatus == 'Perizinan' || currentStatus == 'Izin Tetangga') {
      if (stepKey == 'izin_tetangga' || stepKey == 'perizinan') {
        return true;
      }
    }
    final currentStepKey = getCurrentActiveStep(currentStatus);
    return stepKey == currentStepKey;
  }

  static String getCurrentActiveStep(String status) {
    switch (status) {
      case 'Mou':
        return 'mou';
      case 'Izin Tetangga':
        return 'izin_tetangga';
      case 'Perizinan':
        return 'perizinan';
      case 'Notaris':
        return 'notaris';
      case 'Renovasi':
        return 'renovasi';
      case 'Grand Opening':
        return 'grand_opening';
      case 'Not Started':
      default:
        return 'mou';
    }
  }
}