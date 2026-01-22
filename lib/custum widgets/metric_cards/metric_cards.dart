// lib/widgets/metric_cards.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class MetricCards extends StatelessWidget {
  final bool isTablet;

  const MetricCards({Key? key, required this.isTablet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {
        'title': 'Heart Rate',
        'value': '72',
        'unit': 'BPM',
        'icon': Icons.favorite,
        'color': AppColors.dangerColor,
        'trend': Icons.arrow_upward,
        'status': 'Normal',
        'bgColor': AppColors.lightIndigo,
      },
      {
        'title': 'Blood Pressure',
        'value': '120/80',
        'unit': 'mmHg',
        'icon': Icons.monitor_heart,
        'color': AppColors.warningColor,
        'trend': Icons.trending_flat,
        'status': 'Ideal',
        'bgColor': const Color(0xFFFCE7F3),
      },
      {
        'title': 'Blood Sugar',
        'value': '98',
        'unit': 'mg/dL',
        'icon': Icons.water_drop,
        'color': AppColors.successColor,
        'trend': Icons.arrow_downward,
        'status': 'Normal',
        'bgColor': const Color(0xFFCCFBF1),
      },
      {
        'title': 'Oxygen',
        'value': '98%',
        'unit': 'SpO2',
        'icon': Icons.air,
        'color': AppColors.infoColor,
        'trend': Icons.arrow_upward,
        'status': 'Excellent',
        'bgColor': AppColors.lightIndigo,
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: isTablet ? 20 : 16,
        mainAxisSpacing: isTablet ? 20 : 16,
        childAspectRatio: 1.0,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _buildMetricCard(metrics[index]);
      },
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      decoration: BoxDecoration(
        color: metric['bgColor'] as Color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: isTablet ? 44 : 40,
                      height: isTablet ? 44 : 40,
                      decoration: BoxDecoration(
                        color: (metric['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        metric['icon'] as IconData,
                        color: metric['color'] as Color,
                        size: isTablet ? 22 : 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        metric['trend'] as IconData,
                        size: 16,
                        color: metric['color'] as Color,
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric['value'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      metric['unit'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      metric['title'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        metric['status'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.w700,
                          color: metric['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}