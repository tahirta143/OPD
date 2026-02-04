// lib/custum widgets/activity_todays/fl_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FlChartGraphWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;
  final ChartType chartType;
  final bool showLegend;
  final List<ChartData> data;
  final bool isTablet;
  final bool isMonthly;
  final bool showPKR; // NEW: Flag to show PKR format

  const FlChartGraphWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueColor,
    required this.chartType,
    required this.data,
    required this.isTablet,
    this.showLegend = true,
    this.isMonthly = false,
    this.showPKR = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Header with title and value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  showPKR ? 'PKR $value' : value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Graph Container
          Container(
            height: isTablet ? 220 : 180,
            child: _buildChart(),
          ),

          // Legend (if enabled)
          if (showLegend && chartType != ChartType.pie) ...[
            SizedBox(height: isTablet ? 16 : 12),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getYInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Color(0xFFE5E7EB),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final label = data[index].x;
                  final displayLabel = isMonthly ? _getMonthAbbreviation(label) : label;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        fontSize: isMonthly ? 10 : 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getYInterval(),
              reservedSize: 48, // Increased from 40 to 48
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    _formatNumber(value),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY() * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) {
              return FlSpot(index.toDouble(), data[index].y);
            }),
            isCurved: true,
            color: valueColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: valueColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  valueColor.withOpacity(0.3),
                  valueColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: valueColor,
            // tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${data[spot.x.toInt()].x}\n${_formatNumber(spot.y, withSymbol: true)}',
                  TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: valueColor,
            // tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final monthName = data[group.x.toInt()].x;
              final displayMonth = isMonthly ? _getMonthAbbreviation(monthName) : monthName;

              return BarTooltipItem(
                '$displayMonth\n${_formatNumber(rod.toY, withSymbol: true)}',
                TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: isMonthly && data.length > 6 ? 2 : 1, // Show every other month if many months
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  if (isMonthly && data.length > 6 && index % 2 != 0) {
                    return Text(''); // Skip every other month label
                  }
                  final monthName = data[index].x;
                  final displayMonth = isMonthly ? _getMonthAbbreviation(monthName) : monthName;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      displayMonth,
                      style: TextStyle(
                        fontSize: isMonthly ? 10 : 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getYInterval(),
              reservedSize: 50, // Increased for better visibility
              getTitlesWidget: (value, meta) {
                return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      _formatNumber(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    )
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getYInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Color(0xFFE5E7EB),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].y,
                width: isTablet ? (isMonthly ? 14 : 18) : (isMonthly ? 10 : 14), // Reduced width
                borderRadius: BorderRadius.circular(4),
                color: valueColor,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _getMaxY() * 1.1,
                  color: Color(0xFFF3F4F6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: isTablet ? 60 : 50,
        sections: List.generate(data.length, (index) {
          final item = data[index];
          final percentage = (item.y / _getTotalY() * 100).toStringAsFixed(1);

          return PieChartSectionData(
            color: item.color ?? valueColor,
            value: item.y,
            title: '$percentage%',
            radius: 20,
            titleStyle: TextStyle(
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.map((item) {
        final percentage = (item.y / _getTotalY() * 100).toStringAsFixed(1);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (item.color ?? valueColor).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: (item.color ?? valueColor).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color ?? valueColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.x,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_formatNumber(item.y, withSymbol: true)} ($percentage%)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper methods
  double _getMaxY() {
    if (data.isEmpty) return 100;
    double max = data[0].y;
    for (var item in data) {
      if (item.y > max) max = item.y;
    }
    return max;
  }

  double _getTotalY() {
    double total = 0;
    for (var item in data) {
      total += item.y;
    }
    return total;
  }

  double _getYInterval() {
    double max = _getMaxY();
    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    if (max <= 5000) return 1000;
    if (max <= 10000) return 2000;
    if (max <= 50000) return 10000;
    if (max <= 100000) return 20000;
    if (max <= 500000) return 100000;
    return 200000;
  }

  String _getMonthAbbreviation(String monthName) {
    final monthMap = {
      'January': 'Jan',
      'February': 'Feb',
      'March': 'Mar',
      'April': 'Apr',
      'May': 'May',
      'June': 'Jun',
      'July': 'Jul',
      'August': 'Aug',
      'September': 'Sep',
      'October': 'Oct',
      'November': 'Nov',
      'December': 'Dec',
    };

    return monthMap[monthName] ?? monthName.substring(0, 3);
  }

  String _formatNumber(double value, {bool withSymbol = false}) {
    String symbol = showPKR ? 'PKR ' : '';

    if (value >= 1000000) {
      return '${withSymbol ? symbol : ''}${(value/1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${withSymbol ? symbol : ''}${(value/1000).toStringAsFixed(1)}K';
    } else {
      return '${withSymbol ? symbol : ''}${value.toInt()}';
    }
  }
}

class ChartData {
  final String x;
  final double y;
  final Color? color;

  ChartData(this.x, this.y, [this.color]);
}

enum ChartType {
  line,
  bar,
  pie,
}