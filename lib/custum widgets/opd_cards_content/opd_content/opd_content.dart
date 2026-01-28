import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/shift_model/shift_model.dart';
import '../../../provider/shift_provider/shift_provider.dart';
import '../../colors/colors.dart';

final NumberFormat _numberFormat = NumberFormat("#,##0", "en_US");

String _formatAmount(double amount) => _numberFormat.format(amount);
String _formatNumber(int number) => _numberFormat.format(number);

class OPDTabsWithContent extends StatefulWidget {
  final int opdContentIndex;
  final DateTime selectedDate;
  final String selectedShift;
  final String selectedTimeFilter;
  final List<String> shifts;
  final List<String> timeFilters;
  final Function(int) onTabSelected;
  final Function() onClose;
  final Function(DateTime) onDateChanged;
  final Function(String) onShiftChanged;
  final Function(String) onTimeFilterChanged;
  final List<Map<String, dynamic>> consultantsData;
  final ShiftProvider shiftProvider;
  final bool isTablet;

  // Add new properties for date range filters
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(DateTime?) onFromDateChanged;
  final Function(DateTime?) onToDateChanged;

  const OPDTabsWithContent({
    Key? key,
    required this.opdContentIndex,
    required this.selectedDate,
    required this.selectedShift,
    required this.selectedTimeFilter,
    required this.shifts,
    required this.timeFilters,
    required this.onTabSelected,
    required this.onClose,
    required this.onDateChanged,
    required this.onShiftChanged,
    required this.onTimeFilterChanged,
    required this.consultantsData,
    required this.shiftProvider,
    required this.isTablet,
    this.fromDate,
    this.toDate,
    required this.onFromDateChanged,
    required this.onToDateChanged,
  }) : super(key: key);

  @override
  State<OPDTabsWithContent> createState() => _OPDTabsWithContentState();
}

class _OPDTabsWithContentState extends State<OPDTabsWithContent> {
  String _selectedCategory = 'OPD';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.shiftProvider.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = widget.isTablet ? 20.0 : 16.0;

    return Consumer<ShiftProvider>(
      builder: (context, shiftProvider, child) {
        return Column(
          children: [
            // Modern Header with Filter
            Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_getCategoryTitle()} Summary',
                        style: HospitalColors.getModernTextStyle(
                          fontSize: widget.isTablet ? 22 : 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          if (shiftProvider.isLoading)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.modernBlue,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: Icon(Icons.close, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: widget.isTablet ? 16 : 12),

                  // Modern Filter Grid
                  _buildModernFilterGrid(shiftProvider),
                ],
              ),
            ),

            // Loading/Error States
            if (shiftProvider.isLoading && shiftProvider.shifts.isEmpty)
              _buildLoadingState()
            else if (shiftProvider.error != null && shiftProvider.shifts.isEmpty)
              _buildErrorState(shiftProvider)
            else
              Column(
                children: [
                  // Modern Summary Cards Grid
                  _buildModernSummaryCardsGrid(shiftProvider),

                  SizedBox(height: widget.isTablet ? 24 : 16),

                  // Show content based on selected card
                  if (widget.opdContentIndex >= 0)
                    _buildModernContentSection(shiftProvider),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.modernBlue,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading shifts data...',
            style: HospitalColors.getModernTextStyle(
              color: AppColors.textSecondary,
              fontSize: widget.isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ShiftProvider shiftProvider) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 40 : 20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.coral,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            shiftProvider.error ?? 'Error loading data',
            style: HospitalColors.getModernTextStyle(
              color: AppColors.coral,
              fontSize: widget.isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => shiftProvider.fetchData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.modernBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: HospitalColors.getModernTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterGrid(ShiftProvider shiftProvider) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HospitalColors.getModernCardShadow(elevation: 2),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          // First row with 3 filters
          Row(
            children: [
              // Date Filter
              Expanded(
                child: _buildModernDateFilter(shiftProvider),
              ),
              SizedBox(width: widget.isTablet ? 20 : 12),

              // Shift Filter
              Expanded(
                child: _buildModernShiftFilter(shiftProvider),
              ),
              SizedBox(width: widget.isTablet ? 20 : 12),

              // Time Range Filter
              Expanded(
                child: _buildModernTimeFilter(shiftProvider),
              ),
            ],
          ),

          SizedBox(height: widget.isTablet ? 16 : 12),
          //
          // // Second row with 2 filters (From Date and To Date)
          // Row(
          //   children: [
          //     // From Date Filter
          //     Expanded(
          //       child: _buildModernDateRangeFilter(
          //         label: 'From Date',
          //         date: widget.fromDate,
          //         onDateChanged: widget.onFromDateChanged,
          //         shiftProvider: shiftProvider,
          //       ),
          //     ),
          //     SizedBox(width: widget.isTablet ? 20 : 12),
          //
          //     // To Date Filter
          //     Expanded(
          //       child: _buildModernDateRangeFilter(
          //         label: 'To Date',
          //         date: widget.toDate,
          //         onDateChanged: widget.onToDateChanged,
          //         shiftProvider: shiftProvider,
          //       ),
          //     ),
          //
          //     // Clear Filters Button
          //     Expanded(
          //       child: _buildClearFiltersButton(shiftProvider),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildClearFiltersButton(ShiftProvider shiftProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                // Clear all filters
                shiftProvider.clearAllFilters();
                widget.onTimeFilterChanged('All');
                widget.onFromDateChanged(null);
                widget.onToDateChanged(null);
                widget.onShiftChanged('All');
                widget.onDateChanged(DateTime.now());

                // Fetch fresh data
                shiftProvider.fetchData();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.clear_all,
                      size: 16,
                      color: AppColors.coral,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Clear Filters',
                      style: HospitalColors.getModernTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildModernDateFilter(ShiftProvider shiftProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: HospitalColors.getModernTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectDate(context, shiftProvider),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatDate(widget.selectedDate),
                        style: HospitalColors.getModernTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Clear button if date range or time filter is active
                    if (shiftProvider.isDateRangeActive || shiftProvider.isTimeFilterActive)
                      IconButton(
                        icon: Icon(Icons.clear, size: 16, color: AppColors.coral),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          // Clear other filters and reset to single date
                          widget.onTimeFilterChanged('All');
                          widget.onFromDateChanged(null);
                          widget.onToDateChanged(null);
                          shiftProvider.fetchData();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDateRangeFilter({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onDateChanged,
    required ShiftProvider shiftProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HospitalColors.getModernTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectDateRange(context, label, date, onDateChanged, shiftProvider),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        date != null
                            ? _formatDate(date)
                            : 'Select $label',
                        style: HospitalColors.getModernTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (date != null)
                      IconButton(
                        icon: Icon(Icons.clear, size: 16, color: AppColors.coral),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          onDateChanged(null);
                          // If clearing one date, clear both and switch to single date mode
                          if (label == 'From Date') {
                            widget.onToDateChanged(null);
                          } else if (label == 'To Date') {
                            widget.onFromDateChanged(null);
                          }
                          shiftProvider.fetchData();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernShiftFilter(ShiftProvider shiftProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift',
          style: HospitalColors.getModernTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedShift,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                items: widget.shifts.map((String shift) {
                  return DropdownMenuItem<String>(
                    value: shift,
                    child: Row(
                      children: [
                        Icon(
                          HospitalColors.getShiftIcon(shift),
                          size: 14,
                          color: HospitalColors.getShiftColor(shift),
                        ),
                        SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            shift,
                            style: HospitalColors.getModernTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.shiftProvider.setSelectedShift(newValue);
                    widget.onShiftChanged(newValue);

                    // If shift is changed, fetch new data
                    shiftProvider.fetchData();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTimeFilter(ShiftProvider shiftProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range',
          style: HospitalColors.getModernTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedTimeFilter,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                items: widget.timeFilters.map((String filter) {
                  IconData icon;
                  Color color = AppColors.primaryColor;

                  switch (filter) {
                    case 'All':
                      icon = Icons.all_inclusive;
                      color = AppColors.infoColor;
                      break;
                    case 'Month':
                      icon = Icons.calendar_month;
                      color = AppColors.successColor;
                      break;
                    case 'Week':
                      icon = Icons.calendar_view_week;
                      color = AppColors.warningColor;
                      break;
                    default:
                      icon = Icons.filter_alt;
                  }

                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: color,
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            filter,
                            style: HospitalColors.getModernTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // Clear date range when selecting time filter
                    widget.onFromDateChanged(null);
                    widget.onToDateChanged(null);

                    widget.shiftProvider.setSelectedTimeFilter(newValue);
                    widget.onTimeFilterChanged(newValue);

                    // Fetch data with time filter
                    shiftProvider.fetchData();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSummaryCardsGrid(ShiftProvider shiftProvider) {
    final summary = shiftProvider.getShiftSummary();
    final opdTotal = summary['opdTotal'] as double;
    final expensesTotal = summary['expensesTotal'] as double;
    final opdPaid = summary['opdPaid'] as double;
    final opdBalance = summary['opdBalance'] as double;

    final summaryCards = [
      {
        'title': 'OPD',
        'icon': Icons.local_hospital_outlined,
        'color': AppColors.modernBlue,
        'contentType': 'opd',
        'figure': 'PKR ${_formatAmount(opdTotal)}',
        'description': shiftProvider.isDateRangeActive || shiftProvider.isTimeFilterActive
            ? 'Total OPD'
            : 'OPD Total',
      },
      {
        'title': 'Consultation',
        'icon': Icons.medical_services_outlined,
        'color': AppColors.teal,
        'contentType': 'consultation',
        'figure': 'PKR ${_formatAmount(opdPaid)}',
        'description': shiftProvider.isDateRangeActive || shiftProvider.isTimeFilterActive
            ? 'Total Paid'
            : 'OPD Paid',
      },
      {
        'title': 'Admissions',
        'icon': Icons.night_shelter_outlined,
        'color': AppColors.amber,
        'contentType': 'admissions',
        'figure': 'PKR ${_formatAmount(opdBalance)}',
        'description': shiftProvider.isDateRangeActive || shiftProvider.isTimeFilterActive
            ? 'Total Balance'
            : 'OPD Balance',
      },
      {
        'title': 'Expenses',
        'icon': Icons.monetization_on_outlined,
        'color': AppColors.coral,
        'contentType': 'expenses',
        'figure': 'PKR ${_formatAmount(expensesTotal)}',
        'description': shiftProvider.isDateRangeActive || shiftProvider.isTimeFilterActive
            ? 'Total Expenses'
            : 'Total Expenses',
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.isTablet ? 4 : 2,
        crossAxisSpacing: widget.isTablet ? 16 : 12,
        mainAxisSpacing: widget.isTablet ? 16 : 12,
        childAspectRatio: widget.isTablet ? 1.4 : 1.3,
      ),
      itemCount: summaryCards.length,
      itemBuilder: (context, index) {
        return _buildModernOPDSummaryCard(
          title: summaryCards[index]['title'] as String,
          icon: summaryCards[index]['icon'] as IconData,
          color: summaryCards[index]['color'] as Color,
          figure: summaryCards[index]['figure'] as String,
          description: summaryCards[index]['description'] as String,
          contentType: summaryCards[index]['contentType'] as String,
        );
      },
    );
  }

  Widget _buildModernOPDSummaryCard({
    required String title,
    required IconData icon,
    required Color color,
    required String figure,
    required String description,
    required String contentType,
  }) {
    final int index = _getIndexForContentType(contentType);
    final isSelected = widget.opdContentIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: HospitalColors.getModernCardShadow(elevation: isSelected ? 6 : 4),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = title;
              });
              widget.onTabSelected(index);
            },
            borderRadius: BorderRadius.circular(16),
            hoverColor: color.withOpacity(0.05),
            child: Container(
              padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: widget.isTablet ? 52 : 44,
                        height: widget.isTablet ? 52 : 44,
                        decoration: BoxDecoration(
                          gradient: HospitalColors.getModernGradient(color),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: widget.isTablet ? 26 : 22,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          child: Text(
                            figure,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.isTablet ? 14 : 10),
                  Text(
                    title,
                    style: HospitalColors.getModernTextStyle(
                      fontSize: widget.isTablet ? 15 : 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: widget.isTablet ? 6 : 4),
                  Text(
                    description,
                    style: HospitalColors.getModernTextStyle(
                      fontSize: widget.isTablet ? 11 : 9,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernContentSection(ShiftProvider shiftProvider) {
    switch (_selectedCategory) {
      case 'OPD':
        return _buildModernOPDContent(shiftProvider);
      case 'Consultation':
        return _buildModernConsultationContent(shiftProvider);
      case 'Admissions':
        return _buildModernAdmissionsContent(shiftProvider);
      case 'Expenses':
        return _buildModernExpensesContent(shiftProvider);
      default:
        return _buildModernOPDContent(shiftProvider);
    }
  }

  Widget _buildModernOPDContent(ShiftProvider shiftProvider) {
    final summary = shiftProvider.getShiftSummary();
    final opdRows = summary['opdRows'] as List<ShiftRow>;
    final opdTotal = summary['opdTotal'] as double;
    final opdPaid = summary['opdPaid'] as double;
    final opdBalance = summary['opdBalance'] as double;
    final stats = summary['stats'] as Map<String, dynamic>;
    final totalPatients = stats['totalPatients'] as int;

    if (shiftProvider.filteredShifts.isEmpty) return _buildEmptyState('No OPD data available');

    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: HospitalColors.getModernCardShadow(elevation: 6),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPD Summary',
                      style: HospitalColors.getModernTextStyle(
                        fontSize: widget.isTablet ? 20 : 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      _getDisplayDateRange(shiftProvider),
                      style: HospitalColors.getModernTextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: HospitalColors.getShiftColor(widget.selectedShift).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HospitalColors.getShiftColor(widget.selectedShift).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      HospitalColors.getShiftIcon(widget.selectedShift),
                      size: 16,
                      color: HospitalColors.getShiftColor(widget.selectedShift),
                    ),
                    SizedBox(width: 6),
                    Text(
                      widget.selectedShift,
                      style: HospitalColors.getModernTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HospitalColors.getShiftColor(widget.selectedShift),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 24 : 20),

          // Show shift count when date range is active
          if (shiftProvider.isDateRangeActive || shiftProvider.isTimeFilterActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.modernBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${shiftProvider.filteredShifts.length} Shifts',
                      style: TextStyle(
                        color: AppColors.modernBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // OPD Statistics
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModernStatCard('Total Patients', _formatNumber(totalPatients),
                    Icons.group_outlined, AppColors.modernBlue),
                _buildModernStatCard('OPD Total', 'PKR ${_formatAmount(opdTotal)}',
                    Icons.attach_money_outlined, AppColors.teal),
                _buildModernStatCard('OPD Paid', 'PKR ${_formatAmount(opdPaid)}',
                    Icons.payment_outlined, Colors.green),
                if (widget.isTablet)
                  _buildModernStatCard('OPD Balance', 'PKR ${_formatAmount(opdBalance)}',
                      Icons.account_balance_wallet_outlined, Colors.orange),
              ],
            ),
          ),
          SizedBox(height: widget.isTablet ? 28 : 20),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'OPD Services Breakdown',
                    style: HospitalColors.getModernTextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (!shiftProvider.isDateRangeActive && !shiftProvider.isTimeFilterActive && shiftProvider.filteredShifts.isNotEmpty)
                  Text(
                    'Receipts: ${shiftProvider.filteredShifts.first.receiptFrom}-${shiftProvider.filteredShifts.first.receiptTo}',
                    style: HospitalColors.getModernTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.modernBlue,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 14),

          if (opdRows.isEmpty)
            _buildEmptyState('No OPD services found')
          else
            _buildOPDDataTable(opdRows),
        ],
      ),
    );
  }

  Widget _buildModernExpensesContent(ShiftProvider shiftProvider) {
    final summary = shiftProvider.getShiftSummary();
    final expenseRows = summary['expenseRows'] as List<ShiftRow>;
    final expensesTotal = summary['expensesTotal'] as double;

    if (shiftProvider.filteredShifts.isEmpty) return _buildEmptyState('No expense data available');

    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: HospitalColors.getModernCardShadow(elevation: 6),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expenses Summary',
                    style: HospitalColors.getModernTextStyle(
                      fontSize: widget.isTablet ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _getDisplayDateRange(shiftProvider),
                    style: HospitalColors.getModernTextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.coral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.coral.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_outlined, size: 16, color: AppColors.coral),
                    SizedBox(width: 6),
                    Text(
                      'PKR ${_formatAmount(expensesTotal)}',
                      style: HospitalColors.getModernTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 24 : 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildModernStatCard('Total Expenses', 'PKR ${_formatAmount(expensesTotal)}',
                  Icons.monetization_on_outlined, AppColors.coral),
              _buildModernStatCard('No. of Expenses', _formatNumber(expenseRows.length),
                  Icons.list_outlined, AppColors.amber),
              if (widget.isTablet)
                _buildModernStatCard('Shift Count', '${shiftProvider.filteredShifts.length}',
                    Icons.attach_money_outlined, AppColors.infoColor),
            ],
          ),
          SizedBox(height: widget.isTablet ? 28 : 20),

          Text(
            'Expenses Breakdown',
            style: HospitalColors.getModernTextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14),

          if (expenseRows.isEmpty)
            _buildEmptyState('No expenses found')
          else
            _buildExpensesTable(expenseRows),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      constraints: BoxConstraints(
        minWidth: widget.isTablet ? 140 : 120,
        maxWidth: widget.isTablet ? 180 : 150,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: widget.isTablet ? 26 : 22, color: color),
          SizedBox(height: widget.isTablet ? 10 : 8),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: widget.isTablet ? 20 : 16,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: widget.isTablet ? 6 : 4),
          Text(
            label,
            style: HospitalColors.getModernTextStyle(
              fontSize: widget.isTablet ? 12 : 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOPDDataTable(List<ShiftRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: [
            DataColumn(label: _buildTableHeader('Sr#')),
            DataColumn(label: _buildTableHeader('Service')),
            DataColumn(label: _buildTableHeader('Qty')),
            DataColumn(label: _buildTableHeader('Total')),
            DataColumn(label: _buildTableHeader('Paid')),
            DataColumn(label: _buildTableHeader('Balance')),
          ],
          rows: rows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row.sr.toString())),
              DataCell(Text(row.service)),
              DataCell(Text(_formatNumber(row.qty))),
              DataCell(Text('PKR ${_formatAmount(row.total)}')),
              DataCell(Text('PKR ${_formatAmount(row.paid)}')),
              DataCell(Text('PKR ${_formatAmount(row.balance)}')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpensesTable(List<ShiftRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: [
            DataColumn(label: _buildTableHeader('Sr#')),
            DataColumn(label: _buildTableHeader('Expense Description')),
            DataColumn(label: _buildTableHeader('Amount')),
            DataColumn(label: _buildTableHeader('Status')),
          ],
          rows: rows.map((row) {
            final isPaid = row.paid == row.total;
            return DataRow(cells: [
              DataCell(Text(row.sr.toString())),
              DataCell(Text(row.service)),
              DataCell(Text('PKR ${_formatAmount(row.total)}')),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPaid ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Pending',
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: HospitalColors.getModernTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textSecondary, size: 48),
          SizedBox(height: 12),
          Text(
            message,
            style: HospitalColors.getModernTextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  String _formatDate(DateTime date) {
    final day = date.day;
    final month = _getMonthAbbreviation(date.month);
    final year = date.year.toString().substring(2);
    return '$day $month $year';
  }

  String _getMonthAbbreviation(int month) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _selectDate(BuildContext context, ShiftProvider shiftProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.modernBlue,
            colorScheme: ColorScheme.light(primary: AppColors.modernBlue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedDate) {
      // Clear date range and time filter when selecting single date
      widget.onTimeFilterChanged('All');
      widget.onFromDateChanged(null);
      widget.onToDateChanged(null);

      widget.shiftProvider.setSelectedDate(picked);
      widget.onDateChanged(picked);

      // Fetch data with new date
      shiftProvider.fetchData();
    }
  }

  Future<void> _selectDateRange(
      BuildContext context,
      String label,
      DateTime? currentDate,
      Function(DateTime?) onDateChanged,
      ShiftProvider shiftProvider,
      ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.modernBlue,
            colorScheme: ColorScheme.light(primary: AppColors.modernBlue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);

      // Manually fetch data when both dates are set
      if (label == 'From Date' && widget.toDate != null) {
        shiftProvider.fetchData();
      } else if (label == 'To Date' && widget.fromDate != null) {
        shiftProvider.fetchData();
      }
    }
  }

  int _getIndexForContentType(String contentType) {
    switch (contentType) {
      case 'opd':
        return 0;
      case 'consultation':
        return 1;
      case 'admissions':
        return 2;
      case 'expenses':
        return 3;
      default:
        return 0;
    }
  }

  String _getDisplayDateRange(ShiftProvider shiftProvider) {
    String dateInfo;
    String shiftInfo = widget.selectedShift == 'All' ? 'All Shifts' : '${widget.selectedShift} Shift';

    if (shiftProvider.isDateRangeActive) {
      dateInfo = '${_formatDate(shiftProvider.fromDate!)} - ${_formatDate(shiftProvider.toDate!)}';
    } else if (shiftProvider.isTimeFilterActive) {
      dateInfo = '${widget.selectedTimeFilter} (${_formatDate(shiftProvider.fromDate!)} - ${_formatDate(shiftProvider.toDate!)})';
    } else {
      dateInfo = _formatDate(widget.selectedDate);
    }

    return '$dateInfo • $shiftInfo';
  }

  String _getCategoryTitle() {
    if (widget.opdContentIndex >= 0) {
      switch (widget.opdContentIndex) {
        case 0: return 'OPD';
        case 1: return 'Consultation';
        case 2: return 'Admissions';
        case 3: return 'Expenses';
        default: return 'OPD';
      }
    }
    return 'OPD';
  }

  // These methods remain the same as in your original code
  Widget _buildModernConsultationContent(ShiftProvider shiftProvider) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: HospitalColors.getModernCardShadow(elevation: 6),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Summary',
                    style: HospitalColors.getModernTextStyle(
                      fontSize: widget.isTablet ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _getDisplayDateRange(shiftProvider),
                    style: HospitalColors.getModernTextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.teal.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medical_services_outlined, size: 16, color: AppColors.teal),
                    SizedBox(width: 6),
                    Text(
                      'Consultation',
                      style: HospitalColors.getModernTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 24 : 20),
          _buildNoDataAvailableSection(
            title: 'Consultation Data Not Available',
            subtitle: 'Consultation data is currently not available for this shift',
            icon: Icons.medical_services_outlined,
            color: AppColors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildModernAdmissionsContent(ShiftProvider shiftProvider) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: HospitalColors.getModernCardShadow(elevation: 6),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admissions Summary',
                    style: HospitalColors.getModernTextStyle(
                      fontSize: widget.isTablet ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _getDisplayDateRange(shiftProvider),
                    style: HospitalColors.getModernTextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.amber.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 16, color: AppColors.amber),
                    SizedBox(width: 6),
                    Text(
                      'Admissions',
                      style: HospitalColors.getModernTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 24 : 20),
          _buildNoDataAvailableSection(
            title: 'Admissions Data Not Available',
            subtitle: 'Admissions data is currently not available for this shift',
            icon: Icons.night_shelter_outlined,
            color: AppColors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataAvailableSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 40 : 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: widget.isTablet ? 80 : 60,
            height: widget.isTablet ? 80 : 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: widget.isTablet ? 40 : 32,
              color: color,
            ),
          ),
          SizedBox(height: widget.isTablet ? 24 : 16),
          Text(
            title,
            style: HospitalColors.getModernTextStyle(
              fontSize: widget.isTablet ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: widget.isTablet ? 12 : 8),
          Text(
            subtitle,
            style: HospitalColors.getModernTextStyle(
              fontSize: widget.isTablet ? 14 : 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: widget.isTablet ? 24 : 16),
          Container(
            padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.infoColor),
                SizedBox(width: 8),
                Text(
                  'This feature is currently under development',
                  style: HospitalColors.getModernTextStyle(
                    fontSize: widget.isTablet ? 12 : 10,
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