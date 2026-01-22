// lib/widgets/quick_stats.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class QuickStats extends StatelessWidget {
  final bool isTablet;

  const QuickStats({Key? key, required this.isTablet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Water', 'value': '2.5L', 'icon': Icons.water_drop, 'color': AppColors.tealColor},
      {'label': 'Calories', 'value': '1,850', 'icon': Icons.local_fire_department, 'color': const Color(0xFFF97316)},
      {'label': 'Medication', 'value': 'Taken', 'icon': Icons.medical_services, 'color': AppColors.successColor},
      {'label': 'Stress', 'value': 'Low', 'icon': Icons.self_improvement, 'color': AppColors.primaryColor},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: isTablet ? 16 : 12,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _buildQuickStatCard(stats[index]);
      },
    );
  }

  Widget _buildQuickStatCard(Map<String, dynamic> stat) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 20,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}