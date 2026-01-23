// lib/widgets/shared/colors.dart
import 'package:flutter/material.dart';

// Modern Hospital Color Scheme - Sleek & Professional
class AppColors {
  // Modern Primary Palette (Healthcare Blue)
  static const Color modernBlue = Color(0xFF2563EB);      // Vibrant healthcare blue
  static const Color softBlue = Color(0xFF60A5FA);        // Light blue for accents
  static const Color darkBlue = Color(0xFF1D4ED8);        // Dark blue for text/icons

  // Modern Accent Palette
  static const Color teal = Color(0xFF0D9488);            // Modern teal for success
  static const Color coral = Color(0xFFFF6B6B);           // Coral for alerts/emergency
  static const Color amber = Color(0xFFF59E0B);           // Amber for warnings
  static const Color purple = Color(0xFF8B5CF6);          // Modern purple for specialty

  // Modern Neutral Palette
  static const Color neutral900 = Color(0xFF0F172A);      // Darkest neutral
  static const Color neutral800 = Color(0xFF1E293B);      // Dark neutral
  static const Color neutral600 = Color(0xFF475569);      // Medium neutral
  static const Color neutral400 = Color(0xFF94A3B8);      // Light neutral
  static const Color neutral200 = Color(0xFFE2E8F0);      // Lighter neutral
  static const Color neutral100 = Color(0xFFF1F5F9);      // Lightest neutral
  static const Color neutral50 = Color(0xFFF8FAFC);       // Background neutral

  // Modern UI Colors
  static const Color bgColor = neutral50;                 // Background
  static const Color cardColor = Color(0xFFFFFFFF);       // Cards/surfaces
  static const Color textPrimary = neutral900;            // Primary text
  static const Color textSecondary = neutral600;          // Secondary text
  static const Color borderColor = neutral200;            // Borders
  static const Color surfaceColor = Color(0xFFF8FAFC);    // Surface colors

  // Modern Medical Status Colors
  static const Color successColor = teal;                 // Success/Complete
  static const Color warningColor = amber;                // Warning/Pending
  static const Color dangerColor = coral;                 // Danger/Emergency
  static const Color infoColor = modernBlue;              // Information

  // Modern Specialty Colors
  static const Color cardiologyColor = Color(0xFFEF4444); // Bright red
  static const Color neurologyColor = Color(0xFF8B5CF6);  // Modern purple
  static const Color pediatricsColor = Color(0xFFEC4899); // Modern pink
  static const Color orthopedicsColor = Color(0xFF10B981); // Modern green
  static const Color surgeryColor = Color(0xFF06B6D4);    // Cyan

  // For backward compatibility (aliases)
  static const Color primaryColor = modernBlue;
  static const Color secondaryColor = softBlue;
  static const Color accentColor = teal;
  static const Color tealColor = teal;
  static const Color lightIndigo = Color(0xFFE0E7FF);
}

// Modern Hospital Color Utilities
class HospitalColors {
  // Modern department colors with gradient support
  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'opd':
      case 'outpatient':
        return AppColors.modernBlue;
      case 'indoor':
      case 'admissions':
        return AppColors.darkBlue;
      case 'laboratory':
      case 'lab':
        return AppColors.teal;
      case 'pharmacy':
        return AppColors.successColor;
      case 'store':
      case 'inventory':
        return AppColors.amber;
      case 'staff':
      case 'hr':
        return AppColors.purple;
      case 'finance':
      case 'account':
        return const Color(0xFF06B6D4);
      case 'emergency':
        return AppColors.coral;
      case 'cardiology':
        return AppColors.cardiologyColor;
      case 'neurology':
        return AppColors.neurologyColor;
      case 'pediatrics':
        return AppColors.pediatricsColor;
      case 'orthopedics':
        return AppColors.orthopedicsColor;
      case 'surgery':
        return AppColors.surgeryColor;
      case 'radiology':
        return const Color(0xFF8B5CF6);
      case 'icu':
        return const Color(0xFFEC4899);
      default:
        return AppColors.modernBlue;
    }
  }

  // Modern gradient for cards and backgrounds
  static LinearGradient getModernGradient(Color color, [bool isReversed = false]) {
    return LinearGradient(
      begin: isReversed ? Alignment.bottomRight : Alignment.topLeft,
      end: isReversed ? Alignment.topLeft : Alignment.bottomRight,
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        color.withOpacity(0.5),
      ],
    );
  }

  // Sleek glass morphism effect
  static LinearGradient getGlassEffect([Color? baseColor]) {
    final color = baseColor ?? AppColors.modernBlue;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.15),
        color.withOpacity(0.05),
        Colors.white.withOpacity(0.1),
      ],
    );
  }

  // Modern card shadows
  static List<BoxShadow> getModernCardShadow({double elevation = 4}) {
    return [
      BoxShadow(
        color: AppColors.neutral900.withOpacity(0.05),
        blurRadius: 20 * elevation,
        spreadRadius: 1,
        offset: Offset(0, 4 * elevation),
      ),
      BoxShadow(
        color: AppColors.neutral900.withOpacity(0.02),
        blurRadius: 10 * elevation,
        spreadRadius: 0.5,
        offset: Offset(0, 2 * elevation),
      ),
    ];
  }

  // Modern soft shadow
  static List<BoxShadow> getSoftShadow({Color? color, double blur = 12}) {
    return [
      BoxShadow(
        color: (color ?? AppColors.neutral900).withOpacity(0.08),
        blurRadius: blur,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Shift colors with modern palette
  static Color getShiftColor(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return const Color(0xFF10B981); // Fresh green
      case 'afternoon':
        return const Color(0xFFF59E0B); // Warm amber
      case 'evening':
        return const Color(0xFF8B5CF6); // Soft purple
      case 'night':
        return const Color(0xFF2563EB); // Night blue
      default:
        return AppColors.modernBlue;
    }
  }

  static IconData getShiftIcon(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return Icons.wb_twilight;
      case 'afternoon':
        return Icons.light_mode;
      case 'evening':
        return Icons.nightlight;
      case 'night':
        return Icons.dark_mode;
      default:
        return Icons.access_time_filled;
    }
  }

  // Modern border decoration
  static BoxDecoration getModernBorder({Color? color, double radius = 12}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: color ?? AppColors.borderColor,
        width: 1.5,
      ),
    );
  }

  // Modern button style
  static ButtonStyle getModernButtonStyle(Color color) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(color),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.all(0),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  // Get color intensity for data visualization
  static Color getIntensityColor(double value) {
    if (value >= 0.8) return AppColors.coral;
    if (value >= 0.6) return AppColors.amber;
    if (value >= 0.4) return AppColors.teal;
    return AppColors.modernBlue;
  }

  // Modern text style helper
  static TextStyle getModernTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double height = 1.4,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: -0.2,
    );
  }
}