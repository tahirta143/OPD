// lib/widgets/metric_cards.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';


class MetricCards extends StatelessWidget {
  const MetricCards({Key? key, required bool isTablet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final metrics = [
      {
        'title': 'Heart Rate',
        'value': '72',
        'unit': 'BPM',
        'icon': Icons.favorite_border,
        'color': AppColors.coral,
        'trend': Icons.trending_flat,
        'status': 'Normal',
        'trendValue': '+0.5',
        'description': 'Resting heart rate',
      },
      {
        'title': 'Blood Pressure',
        'value': '120',
        'unit': '/80 mmHg',
        'icon': Icons.monitor_heart_outlined,
        'color': AppColors.amber,
        'trend': Icons.trending_down,
        'status': 'Ideal',
        'trendValue': '-2.3',
        'description': 'Systolic / Diastolic',
      },
      {
        'title': 'Blood Sugar',
        'value': '98',
        'unit': 'mg/dL',
        'icon': Icons.water_drop_outlined,
        'color': AppColors.teal,
        'trend': Icons.trending_up,
        'status': 'Normal',
        'trendValue': '+1.2',
        'description': 'Fasting glucose',
      },
      {
        'title': 'Oxygen Level',
        'value': '98',
        'unit': '% SpO2',
        'icon': Icons.air_outlined,
        'color': AppColors.modernBlue,
        'trend': Icons.trending_flat,
        'status': 'Excellent',
        'trendValue': '+0.2',
        'description': 'Oxygen saturation',
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
        crossAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
        mainAxisSpacing: isDesktop ? 24 : (isTablet ? 20 : 16),
        childAspectRatio: isDesktop ? 1.0 : 1.2,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _buildModernMetricCard(metrics[index], isTablet, isDesktop);
      },
    );
  }

  Widget _buildModernMetricCard(Map<String, dynamic> metric, bool isTablet, bool isDesktop) {
    final Color metricColor = metric['color'] as Color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: HospitalColors.getModernCardShadow(elevation: 4),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            hoverColor: metricColor.withOpacity(0.05),
            splashColor: metricColor.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header with icon and trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Modern icon with gradient
                      Container(
                        width: isDesktop ? 52 : (isTablet ? 48 : 44),
                        height: isDesktop ? 52 : (isTablet ? 48 : 44),
                        decoration: BoxDecoration(
                          gradient: HospitalColors.getModernGradient(metricColor),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: metricColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          metric['icon'] as IconData,
                          color: Colors.white,
                          size: isDesktop ? 26 : (isTablet ? 24 : 22),
                        ),
                      ),

                      // Trend indicator with value
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: metricColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: metricColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              metric['trend'] as IconData,
                              size: 14,
                              color: metricColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              metric['trendValue'] as String,
                              style: HospitalColors.getModernTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: metricColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Metric value and unit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main value
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            metric['value'] as String,
                            style: TextStyle(
                              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -1,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            metric['unit'] as String,
                            style: HospitalColors.getModernTextStyle(
                              fontSize: isDesktop ? 15 : (isTablet ? 14 : 13),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Footer with title and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          metric['title'] as String,
                          style: HospitalColors.getModernTextStyle(
                            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: metricColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: metricColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              metric['status'] as String,
                              style: HospitalColors.getModernTextStyle(
                                fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
                                fontWeight: FontWeight.w600,
                                color: metricColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}