// lib/widgets/opd_tabs.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../filters row/filter_row.dart';

class OPDTabs extends StatefulWidget {
  final bool isTablet;
  final int opdContentIndex;
  final DateTime selectedDate;
  final String selectedShift;
  final List<String> shifts;
  final Function(int) onTabSelected;
  final Function() onClose;
  final Function(DateTime) onDateChanged;
  final Function(String) onShiftChanged;
  final List<Map<String, dynamic>> consultantsData;

  const OPDTabs({
    Key? key,
    required this.isTablet,
    required this.opdContentIndex,
    required this.selectedDate,
    required this.selectedShift,
    required this.shifts,
    required this.onTabSelected,
    required this.onClose,
    required this.onDateChanged,
    required this.onShiftChanged,
    required this.consultantsData,
  }) : super(key: key);

  @override
  State<OPDTabs> createState() => _OPDTabsState();
}

class _OPDTabsState extends State<OPDTabs> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Filter
        Padding(
          padding: EdgeInsets.only(bottom: widget.isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OPD Summary',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),

              SizedBox(height: widget.isTablet ? 16 : 12),

              // Filter Row
              FilterRow(
                isTablet: widget.isTablet,
                selectedDate: widget.selectedDate,
                selectedShift: widget.selectedShift,
                shifts: widget.shifts,
                onDateChanged: widget.onDateChanged,
                onShiftChanged: widget.onShiftChanged,
              ),
            ],
          ),
        ),

        // Summary Cards Grid
        _buildSummaryCardsGrid(),

        SizedBox(height: widget.isTablet ? 24 : 16),
      ],
    );
  }

  Widget _buildSummaryCardsGrid() {
    final summaryCards = [

      {
        'title': 'Consultants',
        'icon': Icons.medical_services,
        'bgColor': const Color(0xFFFCE7F3),
        'iconColor': AppColors.accentColor,
        'contentType': 'consultants',
      },
      {
        'title': 'OPD',
        'icon': Icons.local_hospital,
        'bgColor': const Color(0xFFCCFBF1),
        'iconColor': AppColors.successColor,
        'contentType': 'opd',
      },
      {
        'title': 'IPD',
        'icon': Icons.night_shelter,
        'bgColor': AppColors.lightIndigo,
        'iconColor': AppColors.warningColor,
        'contentType': 'ipd',
      },
      {
        'title': 'Laboratory',
        'icon': Icons.science,
        'bgColor': const Color(0xFFFCE7F3),
        'iconColor': AppColors.dangerColor,
        'contentType': 'laboratory',
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.isTablet ? 5 : 2,
        crossAxisSpacing: widget.isTablet ? 16 : 12,
        mainAxisSpacing: widget.isTablet ? 16 : 12,
        childAspectRatio: 1.0,
      ),
      itemCount: summaryCards.length,
      itemBuilder: (context, index) {
        return _buildOPDSummaryCard(
          title: summaryCards[index]['title'] as String,
          icon: summaryCards[index]['icon'] as IconData,
          bgColor: summaryCards[index]['bgColor'] as Color,
          iconColor: summaryCards[index]['iconColor'] as Color,
          contentType: summaryCards[index]['contentType'] as String,
        );
      },
    );
  }

  Widget _buildOPDSummaryCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String contentType,
  }) {
    final int index = _getIndexForContentType(contentType);
    final isSelected = widget.opdContentIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? iconColor.withOpacity(0.1) : bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: isSelected ? Border.all(color: iconColor, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => widget.onTabSelected(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: widget.isTablet ? 48 : 40,
                  height: widget.isTablet ? 48 : 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: widget.isTablet ? 24 : 20,
                    color: iconColor,
                  ),
                ),

                SizedBox(height: widget.isTablet ? 12 : 8),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? iconColor : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getIndexForContentType(String contentType) {
    switch (contentType) {
      case 'names': return 0;
      case 'consultants': return 1;
      case 'opd': return 2;
      case 'ipd': return 3;
      case 'laboratory': return 4;
      default: return -1;
    }
  }
}