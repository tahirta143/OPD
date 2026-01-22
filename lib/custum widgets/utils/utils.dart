// lib/widgets/shared/utils.dart
import 'package:flutter/material.dart';

import '../colors/colors.dart';

class AppUtils {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static IconData getShiftIcon(String shift) {
    switch (shift) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Evening':
        return Icons.nights_stay;
      case 'Night':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }

  static Color getShiftColor(String shift) {
    switch (shift) {
      case 'Morning':
        return AppColors.warningColor;
      case 'Evening':
        return AppColors.primaryColor;
      case 'Night':
        return AppColors.infoColor;
      default:
        return AppColors.textPrimary;
    }
  }

  static String getShiftTiming(String shift) {
    switch (shift) {
      case 'Morning':
        return '9:00 AM - 12:00 PM';
      case 'Evening':
        return '4:00 PM - 8:00 PM';
      case 'Night':
        return '10:00 PM - 6:00 AM';
      default:
        return '9:00 AM - 12:00 PM';
    }
  }
}