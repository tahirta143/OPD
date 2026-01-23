// lib/widgets/shared/utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../colors/colors.dart';

class AppUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yy').format(date);
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
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get end of week
  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
