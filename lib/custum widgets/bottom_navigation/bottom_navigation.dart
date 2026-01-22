// lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final bool isTablet;
  final Function(int) onIndexChanged;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.isTablet,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isTablet ? 80 : 70,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Home', 0),
          _buildNavItem(Icons.health_and_safety_rounded, 'Health', 1),
          _buildFloatingActionButton(),
          _buildNavItem(Icons.calendar_today_rounded, 'Calendar', 2),
          _buildNavItem(Icons.person_rounded, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isTablet ? 26 : 22,
            color: isActive ? AppColors.primaryColor : AppColors.textSecondary,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primaryColor : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: isTablet ? 60 : 50,
      height: isTablet ? 60 : 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: isTablet ? 28 : 24,
      ),
    );
  }
}