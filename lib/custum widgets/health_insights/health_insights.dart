// lib/widgets/health_insights.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class HealthInsights extends StatelessWidget {
  final bool isTablet;

  const HealthInsights({Key? key, required this.isTablet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Health Insights',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Icons.insights_rounded, color: AppColors.primaryColor),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),

          Column(
            children: [
              _buildInsightItem(
                'Your heart rate is improving!',
                'Consistent exercise shows positive effects.',
                Icons.favorite,
                AppColors.dangerColor,
              ),
              SizedBox(height: 12),
              _buildInsightItem(
                'Sleep quality increased by 15%',
                'Keep your regular sleep schedule.',
                Icons.bedtime,
                AppColors.infoColor,
              ),
              SizedBox(height: 12),
              _buildInsightItem(
                'Stay hydrated',
                'Drink more water for better performance.',
                Icons.water_drop,
                AppColors.tealColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}