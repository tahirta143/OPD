// lib/widgets/opd_tabs_with_content.dart
import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../../filters row/filter_row.dart';
import '../../utils/utils.dart';

class OPDTabsWithContent extends StatefulWidget {
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

  const OPDTabsWithContent({
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
  State<OPDTabsWithContent> createState() => _OPDTabsWithContentState();
}

class _OPDTabsWithContentState extends State<OPDTabsWithContent> {
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

        // Show content based on selected tab
        if (widget.opdContentIndex >= 0)
          _buildContentSection(),
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
        crossAxisCount: widget.isTablet ? 4 : 2,
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

  Widget _buildContentSection() {
    switch (widget.opdContentIndex) {
      case 0: // Names
        return _buildNamesContent();
      case 1: // Consultants
        return _buildConsultantsContent();
      case 2: // OPD
        return _buildOPDDetailsContent();
      case 3: // IPD
        return _buildIPDContent();
      case 4: // Laboratory
        return _buildLaboratoryContent();
      default:
        return Container();
    }
  }

  Widget _buildNamesContent() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
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
          Text(
            'Patient Names - ${AppUtils.formatDate(widget.selectedDate)} (${widget.selectedShift})',
            style: TextStyle(
              fontSize: widget.isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: widget.isTablet ? 16 : 12),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Total Patients', '145', Icons.group, AppColors.infoColor),
              _buildStatCard('New Today', '23', Icons.today, AppColors.successColor),
              _buildStatCard('Appointments', '89', Icons.event_available, AppColors.warningColor),
            ],
          ),

          SizedBox(height: widget.isTablet ? 24 : 16),

          // Recent Patients
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Patients',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.lightIndigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.primaryColor),
                        SizedBox(width: 4),
                        Text(
                          widget.selectedShift,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...List.generate(3, (index) => _buildPatientItem(index)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultantsContent() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consultants',
                style: TextStyle(
                  fontSize: widget.isTablet ? 20 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppUtils.getShiftColor(widget.selectedShift).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(AppUtils.getShiftIcon(widget.selectedShift),
                        size: 14,
                        color: AppUtils.getShiftColor(widget.selectedShift)),
                    SizedBox(width: 4),
                    Text(
                      widget.selectedShift,
                      style: TextStyle(
                        color: AppUtils.getShiftColor(widget.selectedShift),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: widget.isTablet ? 16 : 12),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildConsultantStatCard(
                value: '${widget.consultantsData.length}',
                label: 'Total Consultants',
                color: AppColors.accentColor,
              ),
              _buildConsultantStatCard(
                value: '${widget.consultantsData.length - 2}',
                label: 'Available',
                color: AppColors.successColor,
              ),
              _buildConsultantStatCard(
                value: '2',
                label: 'On Leave',
                color: AppColors.warningColor,
              ),
              _buildConsultantStatCard(
                value: '₹1.25L',
                label: 'Collection',
                color: AppColors.primaryColor,
              ),
            ],
          ),

          SizedBox(height: widget.isTablet ? 24 : 16),

          // Consultants List
          Text(
            'Available Consultants - ${AppUtils.formatDate(widget.selectedDate)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 12),

          // Consultants Grid/List
          widget.isTablet
              ? _buildConsultantsTabletGrid()
              : _buildConsultantsMobileList(),
        ],
      ),
    );
  }

  Widget _buildConsultantStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: widget.isTablet ? 20 : 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultantsTabletGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: widget.consultantsData.length,
      itemBuilder: (context, index) {
        return _buildConsultantCard(widget.consultantsData[index]);
      },
    );
  }

  Widget _buildConsultantsMobileList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.consultantsData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildConsultantCard(widget.consultantsData[index]),
        );
      },
    );
  }

  Widget _buildConsultantCard(Map<String, dynamic> consultant) {
    final shiftFee = _getShiftFeeForDoctor(consultant, widget.selectedShift);
    final isAvailable = (consultant['status'] as String? ?? 'Available') == 'Available';

    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: widget.isTablet ? 50 : 40,
            height: widget.isTablet ? 50 : 40,
            decoration: BoxDecoration(
              color: (consultant['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              color: consultant['color'] as Color,
              size: widget.isTablet ? 28 : 24,
            ),
          ),

          SizedBox(width: widget.isTablet ? 16 : 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consultant['name'] as String,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 16 : 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  consultant['specialization'] as String,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 14 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.successColor.withOpacity(0.1)
                            : AppColors.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'On Leave',
                        style: TextStyle(
                          fontSize: 10,
                          color: isAvailable
                              ? AppColors.successColor
                              : AppColors.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      AppUtils.getShiftTiming(widget.selectedShift),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fee
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ' Fee',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$shiftFee',
                style: TextStyle(
                  fontSize: widget.isTablet ? 18 : 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOPDDetailsContent() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OPD Details',
                style: TextStyle(
                  fontSize: widget.isTablet ? 20 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppUtils.getShiftColor(widget.selectedShift).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppUtils.getShiftIcon(widget.selectedShift),
                      size: 12,
                      color: AppUtils.getShiftColor(widget.selectedShift),
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.selectedShift,
                      style: TextStyle(
                        color: AppUtils.getShiftColor(widget.selectedShift),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          Text(
            AppUtils.formatDate(widget.selectedDate),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: widget.isTablet ? 20 : 16),

          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOPDStatCard(
                title: 'Total Patients',
                value: '145',
                color: AppColors.primaryColor,
              ),
              _buildOPDStatCard(
                title: 'New Today',
                value: '23',
                color: AppColors.successColor,
              ),
              _buildOPDStatCard(
                title: 'Follow-up',
                value: '87',
                color: AppColors.warningColor,
              ),
              if (widget.isTablet)
                _buildOPDStatCard(
                  title: 'Revenue',
                  value: '₹1.25L',
                  color: AppColors.accentColor,
                ),
            ],
          ),

          SizedBox(height: widget.isTablet ? 24 : 20),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consultants on Duty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${widget.consultantsData.length} consultants',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Doctors Grid/List
          if (widget.consultantsData.isNotEmpty) ...[
            widget.isTablet
                ? _buildDoctorsTabletGrid()
                : _buildDoctorsMobileList(),
          ] else ...[
            Container(
              padding: EdgeInsets.all(widget.isTablet ? 40 : 32),
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No consultants available for ${widget.selectedShift} shift',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOPDStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: widget.isTablet ? 20 : 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: widget.isTablet ? 12 : 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsTabletGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.2,
      ),
      itemCount: widget.consultantsData.length,
      itemBuilder: (context, index) {
        return _buildOPDDoctorCard(widget.consultantsData[index], index);
      },
    );
  }

  Widget _buildDoctorsMobileList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.consultantsData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOPDDoctorCard(widget.consultantsData[index], index),
        );
      },
    );
  }

  Widget _buildOPDDoctorCard(Map<String, dynamic> doctor, int index) {
    final shiftFee = _getShiftFeeForDoctor(doctor, widget.selectedShift);
    final status = doctor['status'] as String?;
    final isAvailable = (status ?? 'Available') == 'Available';

    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Number Indicator
          Container(
            width: widget.isTablet ? 32 : 28,
            height: widget.isTablet ? 32 : 28,
            decoration: BoxDecoration(
              color: (doctor['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: widget.isTablet ? 14 : 12,
                  fontWeight: FontWeight.w700,
                  color: doctor['color'] as Color,
                ),
              ),
            ),
          ),

          SizedBox(width: widget.isTablet ? 16 : 12),

          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'] as String,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 16 : 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  doctor['specialization'] as String,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 14 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.successColor.withOpacity(0.1)
                            : AppColors.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAvailable ? Icons.check_circle : Icons.pause_circle,
                            size: 10,
                            color: isAvailable
                                ? AppColors.successColor
                                : AppColors.warningColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            isAvailable ? 'Available' : 'Busy',
                            style: TextStyle(
                              fontSize: 10,
                              color: isAvailable
                                  ? AppColors.successColor
                                  : AppColors.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.schedule, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      AppUtils.getShiftTiming(widget.selectedShift),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fee and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$shiftFee',
                style: TextStyle(
                  fontSize: widget.isTablet ? 18 : 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Consultation',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'View Schedule',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIPDContent() {
    final stats = [
      {'label': 'Occupied Beds', 'value': '85', 'color': AppColors.warningColor},
      {'label': 'Available Beds', 'value': '15', 'color': AppColors.successColor},
      {'label': 'Total Beds', 'value': '100', 'color': AppColors.infoColor},
      {'label': 'ICU Patients', 'value': '12', 'color': AppColors.dangerColor},
      {'label': 'Discharge Today', 'value': '8', 'color': AppColors.tealColor},
      {'label': 'Admissions', 'value': '10', 'color': AppColors.primaryColor},
    ];

    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
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
          Text(
            'IPD - ${AppUtils.formatDate(widget.selectedDate)} (${widget.selectedShift})',
            style: TextStyle(
              fontSize: widget.isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: widget.isTablet ? 16 : 12),

          // IPD Stats Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.isTablet ? 3 : 2,
              crossAxisSpacing: widget.isTablet ? 16 : 12,
              mainAxisSpacing: widget.isTablet ? 16 : 12,
              childAspectRatio: 1.2,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              return _buildIPDStatCard(stats[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLaboratoryContent() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
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
          Text(
            'Laboratory - ${AppUtils.formatDate(widget.selectedDate)} (${widget.selectedShift})',
            style: TextStyle(
              fontSize: widget.isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: widget.isTablet ? 16 : 12),

          // Lab Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Tests Today', '56', Icons.science, AppColors.dangerColor),
              _buildStatCard('Pending', '12', Icons.pending, AppColors.warningColor),
              _buildStatCard('Completed', '44', Icons.check_circle, AppColors.successColor),
            ],
          ),

          SizedBox(height: widget.isTablet ? 24 : 16),

          // Test Categories
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Test Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.lightIndigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.selectedShift,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...List.generate(3, (index) => _buildTestCategoryItem(index)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: widget.isTablet ? 24 : 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.lightIndigo,
            child: Text(
              'P${index + 1}',
              style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient ${1000 + index}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cardiology • ${widget.selectedShift} Shift',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ' ${500 + (index * 100)}',
              style: TextStyle(
                color: AppColors.successColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, int index) {
    final shiftFee = _getShiftFeeForDoctor(doctor, widget.selectedShift);

    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: (doctor['color'] as Color).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (doctor['color'] as Color).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: (doctor['color'] as Color).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: doctor['color'] as Color,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Row(
                  spacing: 120,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['name'] as String,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          doctor['specialization'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      widget.selectedShift,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppUtils.getShiftColor(widget.selectedShift),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Timing:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      AppUtils.getShiftTiming(widget.selectedShift),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Text(
                    'Fee',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    ' $shiftFee',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

            ],
          ),
          SizedBox(height: 12),

        ],
      ),
    );
  }

  int _getShiftFeeForDoctor(Map<String, dynamic> doctor, String shift) {
    switch (shift) {
      case 'Morning':
        return doctor['morning'] as int;
      case 'Evening':
        return doctor['evening'] as int;
      case 'Night':
        return doctor['night'] as int;
      default:
        return doctor['morning'] as int;
    }
  }

  Widget _buildIPDStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: (stat['color'] as Color).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (stat['color'] as Color).withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: widget.isTablet ? 32 : 28,
              fontWeight: FontWeight.w800,
              color: stat['color'] as Color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            stat['label'] as String,
            style: TextStyle(
              fontSize: widget.isTablet ? 14 : 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCategoryItem(int index) {
    final categories = [
      {'name': 'Blood Tests', 'revenue': 8400},
      {'name': 'Urine Tests', 'revenue': 3200},
      {'name': 'X-Ray', 'revenue': 15600},
    ];

    final category = categories[index % categories.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.lightIndigo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getTestIcon(index), color: AppColors.primaryColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '15 tests completed • 2 pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '₹ ${category['revenue']}',
              style: TextStyle(
                color: AppColors.successColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTestIcon(int index) {
    switch (index % 3) {
      case 0: return Icons.bloodtype;
      case 1: return Icons.water_drop;
      case 2: return Icons.visibility;
      default: return Icons.science;
    }
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