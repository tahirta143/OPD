// lib/custom_widgets/shift_report/shift_report_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../provider/shift_provider/shift_provider.dart';

class ShiftReportWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(DateTime)? onDateChanged;

  const ShiftReportWidget({
    Key? key,
    this.onClose,
    this.onDateChanged,
  }) : super(key: key);

  @override
  State<ShiftReportWidget> createState() => _ShiftReportWidgetState();
}

class _ShiftReportWidgetState extends State<ShiftReportWidget> {
  final NumberFormat _numberFormat = NumberFormat("#,##0", "en_US");
  int _selectedTabIndex = -1; // -1 means no tab selected
  FilterType _selectedFilterType = FilterType.daily;
  int? _selectedYear;
  int? _selectedMonth;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  String _formatAmount(double amount) => _numberFormat.format(amount);

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShiftReportProvider>();
      provider.fetchAvailableShifts().then((_) {
        provider.fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Container(
      color: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        // padding: EdgeInsets.all(isTablet ? 20 : 12),
        child: Consumer<ShiftReportProvider>(
          builder: (context, provider, child) {
            // Also get the enhanced provider for monthly/date range data
            final enhancedProvider = context.watch<EnhancedShiftReportProvider?>();

            if (provider.isLoading && provider.opdRecords.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF037389)),
                  ),
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error: ${provider.error}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.refresh(),
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF109A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Filters with Filter Type Selection
                _buildEnhancedFiltersCard(provider, enhancedProvider, isTablet),
                SizedBox(height: isTablet ? 20 : 16),

                // Summary Cards (Tabs) - Only show for daily reports
                if (_selectedFilterType == FilterType.daily)
                  _buildSummaryCardsTabs(provider, isTablet),

                // Show different views based on filter type
                if (_selectedFilterType == FilterType.daily && _selectedTabIndex >= 0)
                  _buildTabContent(provider, _selectedTabIndex, isTablet),

                if (_selectedFilterType == FilterType.monthly)
                  _buildMonthlyView(enhancedProvider, isTablet),

                if (_selectedFilterType == FilterType.dateRange)
                  _buildDateRangeView(enhancedProvider, isTablet),

                if (_selectedFilterType == FilterType.yearly)
                  _buildYearlyView(enhancedProvider, isTablet),

                SizedBox(height: isTablet ? 24 : 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedFiltersCard(
      ShiftReportProvider provider,
      EnhancedShiftReportProvider? enhancedProvider,
      bool isTablet
      ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Type Selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterTypeChip('Daily', FilterType.daily, isTablet),
                SizedBox(width: isTablet ? 12 : 8),
                _buildFilterTypeChip('Monthly', FilterType.monthly, isTablet),
                SizedBox(width: isTablet ? 12 : 8),
                _buildFilterTypeChip('Date Range', FilterType.dateRange, isTablet),
                SizedBox(width: isTablet ? 12 : 8),
                _buildFilterTypeChip('Yearly', FilterType.yearly, isTablet),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Dynamic Filters based on selected type
          _buildDynamicFilters(provider, enhancedProvider, isTablet),
          SizedBox(height: isTablet ? 16 : 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Reset Button
              OutlinedButton.icon(
                onPressed: () {
                  _resetFilters();
                  provider.setSelectedDate(DateTime.now());
                  provider.setSelectedShiftId('All');
                  if (enhancedProvider != null) {
                    enhancedProvider.resetNewFilters();
                  }
                  _selectedTabIndex = -1;
                },
                icon: Icon(Icons.refresh, size: isTablet ? 18 : 16),
                label: Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  side: BorderSide(color: const Color(0xFFE5E7EB)),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),

              // Refresh Button
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () => _refreshData(provider, enhancedProvider),
                icon: provider.isLoading
                    ? SizedBox(
                  width: isTablet ? 18 : 16,
                  height: isTablet ? 18 : 16,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(Icons.refresh, size: isTablet ? 18 : 16),
                label: Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF109A8A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTypeChip(
      String label,
      FilterType type,
      bool isTablet,
      ) {
    final isSelected = _selectedFilterType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilterType = type;
          _selectedTabIndex = -1;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF037389) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF037389) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFilters(
      ShiftReportProvider provider,
      EnhancedShiftReportProvider? enhancedProvider,
      bool isTablet
      ) {
    switch (_selectedFilterType) {
      case FilterType.daily:
        return Row(
          children: [
            Expanded(
              child: _buildDateFilter(provider, isTablet),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: _buildShiftFilter(provider, isTablet),
            ),
          ],
        );
      case FilterType.monthly:
        return Row(
          children: [
            Expanded(
              child: _buildYearFilter(isTablet),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: _buildMonthFilter(isTablet),
            ),
          ],
        );
      case FilterType.dateRange:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStartDateFilter(isTablet),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: _buildEndDateFilter(isTablet),
                ),
              ],
            ),
          ],
        );
      case FilterType.yearly:
        return Row(
          children: [
            Expanded(
              child: _buildYearFilter(isTablet),
            ),
          ],
        );
    }
  }

  Widget _buildDateFilter(ShiftReportProvider provider, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context, provider),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 12 : 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isTablet ? 18 : 16,
                  color: const Color(0xFF109A8A),
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(provider.selectedDate),
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartDateFilter(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectStartDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 12 : 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isTablet ? 18 : 16,
                  color: const Color(0xFF109A8A),
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Expanded(
                  child: Text(
                    _selectedStartDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedStartDate!)
                        : 'Select Date',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedStartDate != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateFilter(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'End Date',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectEndDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 12 : 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isTablet ? 18 : 16,
                  color: const Color(0xFF109A8A),
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Expanded(
                  child: Text(
                    _selectedEndDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!)
                        : 'Select Date',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedEndDate != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearFilter(bool isTablet) {
    // Get available years
    final availableYears = List.generate(5, (index) => DateTime.now().year - 2 + index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear ?? DateTime.now().year,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                size: isTablet ? 24 : 20,
                color: const Color(0xFF109A8A),
              ),
              items: availableYears.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedYear = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthFilter(bool isTablet) {
    final availableMonths = [
      {'id': 1, 'name': 'January'},
      {'id': 2, 'name': 'February'},
      {'id': 3, 'name': 'March'},
      {'id': 4, 'name': 'April'},
      {'id': 5, 'name': 'May'},
      {'id': 6, 'name': 'June'},
      {'id': 7, 'name': 'July'},
      {'id': 8, 'name': 'August'},
      {'id': 9, 'name': 'September'},
      {'id': 10, 'name': 'October'},
      {'id': 11, 'name': 'November'},
      {'id': 12, 'name': 'December'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Month',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedMonth ?? DateTime.now().month,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                size: isTablet ? 24 : 20,
                color: const Color(0xFF109A8A),
              ),
              items: availableMonths.map((month) {
                return DropdownMenuItem(
                  value: month['id'] as int,
                  child: Text(
                    month['name'] as String,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMonth = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftFilter(ShiftReportProvider provider, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedShiftId ?? 'All',
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                size: isTablet ? 24 : 20,
                color: const Color(0xFF109A8A),
              ),
              items: [
                DropdownMenuItem(
                  value: 'All',
                  child: Text(
                    'All Shifts',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                ),
                ...provider.availableShifts.map((shift) {
                  return DropdownMenuItem(
                    value: shift.shiftId.toString(),
                    child: Text(
                      '${shift.shiftType} (ID: ${shift.shiftId})',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.setSelectedShiftId(value);
                  if (_selectedFilterType == FilterType.daily) {
                    provider.fetchData();
                  }
                }
              },
            ),
          ),
        ),
        if (provider.availableShifts.isEmpty && !provider.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'No shifts found',
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildMonthlyView(EnhancedShiftReportProvider? provider, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF109A8A), size: 24),
              SizedBox(width: 12),
              Text(
                'Monthly Report: ${_getMonthName(_selectedMonth ?? DateTime.now().month)} ${_selectedYear ?? DateTime.now().year}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Loading State
          if (provider != null && provider.isLoadingNew)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF109A8A)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading monthly report...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )

          // Error State
          else if (provider != null && provider.errorMessageNew.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessageNew}',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchMonthlyReport(),
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF109A8A),
                      ),
                    ),
                  ],
                ),
              ),
            )

          // Data Display
          else if (provider != null && provider.monthlySummary != null)
              Column(
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Revenue',
                          provider.monthlySummary!.totalRevenue,
                          Icons.trending_up,
                          Color(0xFF109A8A),
                          isTablet,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Expense',
                          provider.monthlySummary!.totalExpenses,
                          Icons.trending_down,
                          Color(0xFFD97706),
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Net Amount',
                          provider.monthlySummary!.netAmount,
                          Icons.account_balance,
                          provider.monthlySummary!.netAmount >= 0
                              ? Color(0xFF10B981)
                              : Colors.red,
                          isTablet,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          'Avg Daily',
                          provider.monthlySummary!.totalRevenue / provider.dailySummaries.length,
                          Icons.analytics,
                          Color(0xFF8B5CF6),
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // First Table: Daily Shift-wise Totals
                  Text(
                    'Daily Shift-wise Summary',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDailyShiftSummaryTable(provider, isTablet),
                  SizedBox(height: 32),

                  // Second Table: Service-wise Detailed Breakdown
                  Text(
                    'Service-wise Detailed Breakdown',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildServiceBreakdownTable(provider, isTablet),
                ],
              )

            // Empty State
            else if (provider != null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'No monthly data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchMonthlyReport(),
                          child: Text('Load Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF109A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // Provider Null State
              else
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.orange, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Report provider not available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

// Helper method for first table: Daily Shift-wise Totals
  Widget _buildDailyShiftSummaryTable(EnhancedShiftReportProvider provider, bool isTablet) {
    // Process data to create shift-wise totals
    List<Map<String, dynamic>> dailyData = [];

    for (var i = 0; i < provider.dailySummaries.length; i++) {
      final daily = provider.dailySummaries[i];
      final detailedReport = provider.dailyReports.length > i ? provider.dailyReports[i] : DailyReport(
        date: daily.date,
        morningRevenue: 0,
        morningExpenses: 0,
        eveningRevenue: 0,
        eveningExpenses: 0,
        nightRevenue: 0,
        nightExpenses: 0,
        morningRows: [],
        eveningRows: [],
        nightRows: [],
      );

      dailyData.add({
        'date': daily.date,
        // OPD Revenue
        'morning_opd': detailedReport.morningRevenue,
        'evening_opd': detailedReport.eveningRevenue,
        'night_opd': detailedReport.nightRevenue,
        'opd_total': detailedReport.morningRevenue + detailedReport.eveningRevenue + detailedReport.nightRevenue,
        // Expenses
        'morning_expenses': detailedReport.morningExpenses,
        'evening_expenses': detailedReport.eveningExpenses,
        'night_expenses': detailedReport.nightExpenses,
        'expenses_total': detailedReport.morningExpenses + detailedReport.eveningExpenses + detailedReport.nightExpenses,
        // Totals
        'morning_total': detailedReport.morningRevenue + detailedReport.morningExpenses,
        'evening_total': detailedReport.eveningRevenue + detailedReport.eveningExpenses,
        'night_total': detailedReport.nightRevenue + detailedReport.nightExpenses,
        'daily_total': detailedReport.totalRevenue + detailedReport.totalExpenses,
      });
    }

    // Calculate column totals
    Map<String, double> columnTotals = {
      'morning_opd': 0,
      'evening_opd': 0,
      'night_opd': 0,
      'opd_total': 0,
      'morning_expenses': 0,
      'evening_expenses': 0,
      'night_expenses': 0,
      'expenses_total': 0,
    };

    for (var data in dailyData) {
      // OPD Revenue totals
      columnTotals['morning_opd'] = columnTotals['morning_opd']! + (data['morning_opd'] as double);
      columnTotals['evening_opd'] = columnTotals['evening_opd']! + (data['evening_opd'] as double);
      columnTotals['night_opd'] = columnTotals['night_opd']! + (data['night_opd'] as double);
      columnTotals['opd_total'] = columnTotals['opd_total']! + (data['opd_total'] as double);

      // Expenses totals
      columnTotals['morning_expenses'] = columnTotals['morning_expenses']! + (data['morning_expenses'] as double);
      columnTotals['evening_expenses'] = columnTotals['evening_expenses']! + (data['evening_expenses'] as double);
      columnTotals['night_expenses'] = columnTotals['night_expenses']! + (data['night_expenses'] as double);
      columnTotals['expenses_total'] = columnTotals['expenses_total']! + (data['expenses_total'] as double);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          headingRowHeight: 60,
          dataRowHeight: 45,
          headingRowColor: MaterialStateProperty.all(Color(0xFFF9FAFB)),
          columns: [
            // Date Column
            DataColumn(
              label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // Separator Column (OPD vs Expenses)
            DataColumn(
              label: Container(
                width: 1,
                color: Colors.grey[300],
                child: SizedBox(width: 1),
              ),
            ),

            // OPD Revenue Section (Left side)
            DataColumn(
              label: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE6F7FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: Center(
                  child: Text(
                    'OPD REVENUE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF109A8A),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text('Morning\nOPD',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Evening\nOPD',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Night\nOPD',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('OPD\nTotal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),

            // Separator Column
            DataColumn(
              label: Container(
                width: 1,
                color: Colors.grey[300],
                child: SizedBox(width: 1),
              ),
            ),

            // Expenses Section (Right side)
            DataColumn(
              label: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: Center(
                  child: Text(
                    'EXPENSES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text('Morning\nExpenses',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Evening\nExpenses',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Night\nExpenses',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Expenses\nTotal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),

            // Separator Column
            DataColumn(
              label: Container(
                width: 1,
                color: Colors.grey[300],
                child: SizedBox(width: 1),
              ),
            ),

            // Daily Total Column
            DataColumn(
              label: Text('Daily\nTotal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          rows: [
            // Data rows
            for (var data in dailyData)
              DataRow(
                cells: [
                  // Date
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        DateFormat('d').format(data['date'] as DateTime),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Separator
                  DataCell(Container(width: 1, color: Colors.grey[300])),

                  // OPD Revenue Section Header (empty cell for alignment)
                  DataCell(SizedBox()),

                  // Morning OPD
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['morning_opd'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Evening OPD
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['evening_opd'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Night OPD
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['night_opd'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // OPD Total
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['opd_total'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Separator
                  DataCell(Container(width: 1, color: Colors.grey[300])),

                  // Expenses Section Header (empty cell for alignment)
                  DataCell(SizedBox()),

                  // Morning Expenses
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['morning_expenses'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Evening Expenses
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['evening_expenses'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Night Expenses
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['night_expenses'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Expenses Total
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['expenses_total'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Separator
                  DataCell(Container(width: 1, color: Colors.grey[300])),

                  // Daily Total
                  DataCell(
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Rs ${_formatAmount(data['daily_total'] as double)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF109A8A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Totals row
            DataRow(
              color: MaterialStateProperty.all(Color(0xFFF8F9FA)),
              cells: [
                // Date cell for "TOTAL"
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Separator
                DataCell(Container(width: 1, color: Colors.grey[300])),

                // OPD Revenue Section Header (empty)
                DataCell(SizedBox()),

                // Morning OPD Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['morning_opd']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF109A8A),
                        ),
                      ),
                    ),
                  ),
                ),

                // Evening OPD Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['evening_opd']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF109A8A),
                        ),
                      ),
                    ),
                  ),
                ),

                // Night OPD Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['night_opd']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF109A8A),
                        ),
                      ),
                    ),
                  ),
                ),

                // OPD Grand Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF109A8A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['opd_total']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Separator
                DataCell(Container(width: 1, color: Colors.grey[300])),

                // Expenses Section Header (empty)
                DataCell(SizedBox()),

                // Morning Expenses Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['morning_expenses']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ),

                // Evening Expenses Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['evening_expenses']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ),

                // Night Expenses Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['night_expenses']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ),

                // Expenses Grand Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['expenses_total']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Separator
                DataCell(Container(width: 1, color: Colors.grey[300])),

                // Monthly Total
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(provider.monthlySummary!.totalRevenue + provider.monthlySummary!.totalExpenses)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
// Helper method for second table: Service-wise Breakdown
  Widget _buildServiceBreakdownTable(EnhancedShiftReportProvider provider, bool isTablet) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Helper function for safe double conversion
        double _safeDouble(dynamic value) {
          if (value == null) return 0.0;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }

        // Local refresh function
        void refreshData() {
          setState(() {});
          print('🔄 Manually refreshing table data...');
        }

        if (provider.isLoadingNew) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.errorMessageNew.isNotEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.orange, size: 48),
                SizedBox(height: 8),
                Text(
                  'Error loading detailed breakdown',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  provider.errorMessageNew,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => provider.fetchDetailedBreakdown(),
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF109A8A),
                      ),
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: refreshData,
                      child: Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF109A8A),
                        side: BorderSide(color: Color(0xFF109A8A)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (provider.combinedServiceBreakdown.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Text(
                  'No Detailed Breakdown Available',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Detailed breakdown data has not been loaded yet.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => provider.fetchDetailedBreakdown(),
                      child: Text('Load Detailed Breakdown'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF109A8A),
                      ),
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: refreshData,
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 16),
                          SizedBox(width: 4),
                          Text('Refresh'),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF109A8A),
                        side: BorderSide(color: Color(0xFF109A8A)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Separate OPD and Expenses
        final opdServices = provider.combinedServiceBreakdown
            .where((item) => item['type'] == 'OPD')
            .toList();

        final expenses = provider.combinedServiceBreakdown
            .where((item) => item['type'] == 'EXPENSE')
            .toList();

        // Calculate totals using safe conversion
        double opdMorningTotal = 0;
        double opdEveningTotal = 0;
        double opdNightTotal = 0;
        double opdGrandTotal = 0;

        double expMorningTotal = 0;
        double expEveningTotal = 0;
        double expNightTotal = 0;
        double expGrandTotal = 0;

        for (var service in opdServices) {
          opdMorningTotal += _safeDouble(service['morning']);
          opdEveningTotal += _safeDouble(service['evening']);
          opdNightTotal += _safeDouble(service['night']);
          opdGrandTotal += _safeDouble(service['total']);
        }

        for (var expense in expenses) {
          expMorningTotal += _safeDouble(expense['morning']);
          expEveningTotal += _safeDouble(expense['evening']);
          expNightTotal += _safeDouble(expense['night']);
          expGrandTotal += _safeDouble(expense['total']);
        }

        print('📊 Table Data: ${opdServices.length} OPD, ${expenses.length} Expenses');
        print('📊 OPD Totals: M=${opdMorningTotal}, E=${opdEveningTotal}, N=${opdNightTotal}, T=${opdGrandTotal}');
        print('📊 Expense Totals: M=${expMorningTotal}, E=${expEveningTotal}, N=${expNightTotal}, T=${expGrandTotal}');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Text(
                    'Service Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {
                      refreshData();
                      provider.fetchDetailedBreakdown();
                    },
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF109A8A),
                      side: BorderSide(color: Color(0xFF109A8A)),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // OPD Services Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OPD Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE6F7FF),
                      border: Border(bottom: BorderSide(color: Color(0xFF109A8A))),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_hospital, color: Color(0xFF109A8A), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'OPD SERVICES BREAKDOWN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF109A8A),
                            fontSize: isTablet ? 15 : 14,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),

                  // OPD Table
                  Container(
                    constraints: BoxConstraints(maxHeight: 300), // Limit height with scroll
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowHeight: 50,
                          dataRowHeight: 40,
                          headingRowColor: MaterialStateProperty.all(Color(0xFFF9FAFB)),
                          columns: [
                            DataColumn(
                              label: Container(
                                width: 250,
                                child: Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Text('Morning', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Evening', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Night', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                          ],
                          rows: [
                            // OPD service rows
                            for (var service in opdServices)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 250,
                                      child: Text(
                                        (service['service_name'] as String?) ?? 'Unknown Service',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        'Rs ${_formatAmount(_safeDouble(service['morning']))}',
                                        style: TextStyle(
                                          color: Color(0xFF109A8A),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        'Rs ${_formatAmount(_safeDouble(service['evening']))}',
                                        style: TextStyle(
                                          color: Color(0xFF109A8A),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        'Rs ${_formatAmount(_safeDouble(service['night']))}',
                                        style: TextStyle(
                                          color: Color(0xFF109A8A),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE6F7FF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(_safeDouble(service['total']))}',
                                          style: TextStyle(
                                            color: Color(0xFF109A8A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // OPD totals row
                            if (opdServices.isNotEmpty)
                              DataRow(
                                color: MaterialStateProperty.all(Color(0xFFF0F9FF)),
                                cells: [
                                  DataCell(
                                    Text(
                                      'OPD TOTAL',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF109A8A),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(opdMorningTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF109A8A),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(opdEveningTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF109A8A),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(opdNightTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF109A8A),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(opdGrandTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
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
                ],
              ),
            ),

            SizedBox(height: 24),

            // Expenses Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expenses Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF4E6),
                      border: Border(bottom: BorderSide(color: Color(0xFFD97706))),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.money_off, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'EXPENSES BREAKDOWN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                            fontSize: isTablet ? 15 : 14,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),

                  // Expenses Table
                  Container(
                    constraints: BoxConstraints(maxHeight: 300), // Limit height with scroll
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowHeight: 50,
                          dataRowHeight: 40,
                          headingRowColor: MaterialStateProperty.all(Color(0xFFF9FAFB)),
                          columns: [
                            DataColumn(
                              label: Container(
                                width: 250,
                                child: Text('Expense Item', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataColumn(
                              label: Text('Morning', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Evening', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Night', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              numeric: true,
                            ),
                          ],
                          rows: [
                            // Expense rows
                            for (var expense in expenses)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 250,
                                      child: Text(
                                        (expense['service_name'] as String?) ?? 'Unknown Expense',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        'Rs ${_formatAmount(_safeDouble(expense['morning']))}',
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        'Rs ${_formatAmount(_safeDouble(expense['evening']))}',
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        'Rs ${_formatAmount(_safeDouble(expense['night']))}',
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFF4E6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(_safeDouble(expense['total']))}',
                                          style: TextStyle(
                                            color: Color(0xFFD97706),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // Expenses totals row
                            if (expenses.isNotEmpty)
                              DataRow(
                                color: MaterialStateProperty.all(Color(0xFFFEF3C7)),
                                cells: [
                                  DataCell(
                                    Text(
                                      'EXPENSES TOTAL',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD97706),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(expMorningTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD97706),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(expEveningTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD97706),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(expNightTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD97706),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs ${_formatAmount(expGrandTotal)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
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
                ],
              ),
            ),

            SizedBox(height: 16),
          ],
        );
      },
    );
  }
// get month
  String _getMonthName(int month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildDailySummaryCard(DailyReport report) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Summary',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Morning:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Revenue: Rs ${_formatAmount(report.morningRevenue)}'),
                    Text('Expenses: Rs ${_formatAmount(report.morningExpenses)}'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evening:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Revenue: Rs ${_formatAmount(report.eveningRevenue)}'),
                    Text('Expenses: Rs ${_formatAmount(report.eveningExpenses)}'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Night:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Revenue: Rs ${_formatAmount(report.nightRevenue)}'),
                    Text('Expenses: Rs ${_formatAmount(report.nightExpenses)}'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Revenue:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Rs ${_formatAmount(report.totalRevenue)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF037389),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expenses:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Rs ${_formatAmount(report.totalExpenses)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Amount:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Rs ${_formatAmount(report.netAmount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: report.netAmount >= 0 ? Color(0xFF10B981) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSection(String title, List<Map<String, dynamic>> rows) {
    // Separate OPD and Expenses
    final opdRows = rows.where((row) => row['section'] == 'opd').toList();
    final expenseRows = rows.where((row) => row['section'] == 'expenses').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),

        // OPD Services
        if (opdRows.isNotEmpty) ...[
          Text(
            'OPD Services:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          ...opdRows.map((row) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(row['service']?.toString() ?? 'Unknown'),
                  ),
                  SizedBox(width: 8),
                  Text('Count: ${row['count'] ?? 0}'),
                  SizedBox(width: 8),
                  Text('Rs ${_formatAmount((row['total'] ?? 0).toDouble())}'),
                ],
              ),
            );
          }).toList(),
        ],

        // Expenses
        if (expenseRows.isNotEmpty) ...[
          SizedBox(height: 8),
          Text(
            'Expenses:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          ...expenseRows.map((row) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(row['service']?.toString() ?? 'Unknown'),
                  ),
                  SizedBox(width: 8),
                  Text('Count: ${row['count'] ?? 0}'),
                  SizedBox(width: 8),
                  Text('Rs ${_formatAmount((row['total'] ?? 0).toDouble())}'),
                ],
              ),
            );
          }).toList(),
        ],

        SizedBox(height: 12),
      ],
    );
  }

  // date range
  Widget _buildDateRangeView(EnhancedShiftReportProvider? provider, bool isTablet) {
    print('🔄 Building date range view...');
    print('   Provider: ${provider != null ? "Available" : "NULL"}');
    if (provider != null) {
      print('   Loading state: ${provider.isLoadingNew}');
      print('   Error: ${provider.errorMessageNew}');
      print('   Daily reports: ${provider.dailyReports.length}');
      print('   Daily summaries: ${provider.dailySummaries.length}');
      if (provider.dateRangeData != null) {
        print('   Date Range Data: ${provider.dateRangeData!.startDate} to ${provider.dateRangeData!.endDate}');
      }
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: Color(0xFF109A8A), size: 24),
              SizedBox(width: 12),
              Text(
                'Date Range Report',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Show loading state
          if (provider != null && provider.isLoadingNew)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF109A8A)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading date range report...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Show error state
          else if (provider != null && provider.errorMessageNew.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessageNew}',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchDateRangeReport(),
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF109A8A),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Show data when available
          else if (provider != null &&
                (provider.dateRangeData != null || provider.dailySummaries.isNotEmpty) &&
                _selectedStartDate != null && _selectedEndDate != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date range info
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Color(0xFF109A8A)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Period: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '${provider.dailySummaries.length} days',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF109A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Summary cards
                  if (provider.monthlySummary != null || provider.dateRangeData != null)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Revenue',
                                provider.monthlySummary?.totalRevenue ??
                                    provider.dateRangeData?.totalRevenue ?? 0,
                                Icons.trending_up,
                                Color(0xFF109A8A),
                                isTablet,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Expenses',
                                provider.monthlySummary?.totalExpenses ??
                                    provider.dateRangeData?.totalExpenses ?? 0,
                                Icons.trending_down,
                                Color(0xFFD97706),
                                isTablet,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Net Amount',
                                (provider.monthlySummary?.netAmount ??
                                    ((provider.dateRangeData?.totalRevenue ?? 0) -
                                        (provider.dateRangeData?.totalExpenses ?? 0))),
                                Icons.account_balance,
                                ((provider.monthlySummary?.netAmount ??
                                    ((provider.dateRangeData?.totalRevenue ?? 0) -
                                        (provider.dateRangeData?.totalExpenses ?? 0))) >= 0
                                    ? Color(0xFF10B981)
                                    : Colors.red),
                                isTablet,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: _buildSummaryCard(
                                'Avg Daily',
                                provider.dailySummaries.isNotEmpty
                                    ? (provider.monthlySummary?.totalRevenue ??
                                    provider.dateRangeData?.totalRevenue ?? 0) /
                                    provider.dailySummaries.length
                                    : 0,
                                Icons.analytics,
                                Color(0xFF8B5CF6),
                                isTablet,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // First Table: Daily Shift-wise Totals (PRICES, not counts)
                  SizedBox(height: 24),
                  Text(
                    'Daily Shift-wise Summary (Prices)',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDateRangeDailyShiftTable(provider, isTablet),

                  // Second Table: Service-wise Detailed Breakdown
                  SizedBox(height: 32),
                  Text(
                    'Service-wise Detailed Breakdown',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildServiceBreakdownTable(provider, isTablet),
                ],
              )
            // Show empty state (no data but also no error)
            else if (provider != null && _selectedStartDate != null && _selectedEndDate != null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.date_range, color: Colors.grey, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'No data available for selected date range',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchDateRangeReport(),
                          child: Text('Load Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF109A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Show prompt to select dates
              else if (provider != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, color: Color(0xFF109A8A), size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Select start and end dates to view report',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF109A8A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                // Provider is null
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.orange, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Report provider not available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

// New method for Date Range Daily Shift Table (PRICES)
  Widget _buildDateRangeDailyShiftTable(EnhancedShiftReportProvider provider, bool isTablet) {
    // Process data to create shift-wise price totals
    List<Map<String, dynamic>> dailyData = [];

    for (var i = 0; i < provider.dailyReports.length; i++) {
      final dailyReport = provider.dailyReports[i];

      dailyData.add({
        'date': dailyReport.date,
        // OPD Revenue PRICES
        'morning_opd': dailyReport.morningRevenue,
        'evening_opd': dailyReport.eveningRevenue,
        'night_opd': dailyReport.nightRevenue,
        'opd_total': dailyReport.morningRevenue + dailyReport.eveningRevenue + dailyReport.nightRevenue,
        // Expenses PRICES
        'morning_expenses': dailyReport.morningExpenses,
        'evening_expenses': dailyReport.eveningExpenses,
        'night_expenses': dailyReport.nightExpenses,
        'expenses_total': dailyReport.morningExpenses + dailyReport.eveningExpenses + dailyReport.nightExpenses,
        // Totals
        'morning_total': dailyReport.morningRevenue + dailyReport.morningExpenses,
        'evening_total': dailyReport.eveningRevenue + dailyReport.eveningExpenses,
        'night_total': dailyReport.nightRevenue + dailyReport.nightExpenses,
        'daily_total': dailyReport.totalRevenue + dailyReport.totalExpenses,
      });
    }

    // Calculate column totals
    Map<String, double> columnTotals = {
      'morning_opd': 0,
      'evening_opd': 0,
      'night_opd': 0,
      'opd_total': 0,
      'morning_expenses': 0,
      'evening_expenses': 0,
      'night_expenses': 0,
      'expenses_total': 0,
    };

    for (var data in dailyData) {
      // OPD Revenue totals
      columnTotals['morning_opd'] = columnTotals['morning_opd']! + (data['morning_opd'] as double);
      columnTotals['evening_opd'] = columnTotals['evening_opd']! + (data['evening_opd'] as double);
      columnTotals['night_opd'] = columnTotals['night_opd']! + (data['night_opd'] as double);
      columnTotals['opd_total'] = columnTotals['opd_total']! + (data['opd_total'] as double);

      // Expenses totals
      columnTotals['morning_expenses'] = columnTotals['morning_expenses']! + (data['morning_expenses'] as double);
      columnTotals['evening_expenses'] = columnTotals['evening_expenses']! + (data['evening_expenses'] as double);
      columnTotals['night_expenses'] = columnTotals['night_expenses']! + (data['night_expenses'] as double);
      columnTotals['expenses_total'] = columnTotals['expenses_total']! + (data['expenses_total'] as double);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowHeight: 60,
          dataRowHeight: 45,
          headingRowColor: MaterialStateProperty.all(Color(0xFFF9FAFB)),
          columns: [
            // Date Column
            DataColumn(
              label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // Separator Column (OPD vs Expenses)
            DataColumn(
              label: Container(
                width: 1,
                color: Colors.grey[300],
                child: SizedBox(width: 1),
              ),
            ),

            // OPD Revenue Section (Left side) - PRICES
            DataColumn(
              label: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE6F7FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text('Morning\nOPD',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Evening\nOPD',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Night\nOPD',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('OPD\nTotal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF109A8A)),
                textAlign: TextAlign.center,
              ),
            ),

            // Separator Column
            DataColumn(
              label: Container(
                width: 1,
                color: Colors.grey[300],
                child: SizedBox(width: 1),
              ),
            ),

            // Expenses Section (Right side) - PRICES
            DataColumn(
              label: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),

              ),
            ),
            DataColumn(
              label: Text('Morning\nExpenses',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Evening\nExpenses',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Night\nExpenses',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text('Expenses\nTotal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                textAlign: TextAlign.center,
              ),
            ),

            // Separator Column
            DataColumn(
              label: Container(
                width: 1,
                color: Colors.grey[300],
                child: SizedBox(width: 1),
              ),
            ),

            // Daily Total Column
            DataColumn(
              label: Text('Daily\nTotal',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          rows: [
            // Data rows
            for (var data in dailyData)
              DataRow(
                cells: [
                  // Date
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        DateFormat('d').format(data['date'] as DateTime),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Separator
                  DataCell(Container(width: 1, color: Colors.grey[300])),

                  // OPD Revenue Section Header (empty cell for alignment)
                  DataCell(SizedBox()),

                  // Morning OPD PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['morning_opd'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Evening OPD PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['evening_opd'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Night OPD PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['night_opd'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // OPD Total PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['opd_total'] as double)}',
                        style: TextStyle(
                          color: Color(0xFF109A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Separator
                  DataCell(Container(width: 1, color: Colors.grey[300])),

                  // Expenses Section Header (empty cell for alignment)
                  DataCell(SizedBox()),

                  // Morning Expenses PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['morning_expenses'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Evening Expenses PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['evening_expenses'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Night Expenses PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['night_expenses'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Expenses Total PRICE
                  DataCell(
                    Center(
                      child: Text(
                        'Rs ${_formatAmount(data['expenses_total'] as double)}',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Separator
                  DataCell(Container(width: 1, color: Colors.grey[300])),

                  // Daily Total PRICE
                  DataCell(
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Rs ${_formatAmount(data['daily_total'] as double)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF109A8A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Totals row
            DataRow(
              color: MaterialStateProperty.all(Color(0xFFF8F9FA)),
              cells: [
                // Date cell for "TOTAL"
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Separator
                DataCell(Container(width: 1, color: Colors.grey[300])),

                // OPD Revenue Section Header (empty)
                DataCell(SizedBox()),

                // Morning OPD Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['morning_opd']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF109A8A),
                        ),
                      ),
                    ),
                  ),
                ),

                // Evening OPD Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['evening_opd']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF109A8A),
                        ),
                      ),
                    ),
                  ),
                ),

                // Night OPD Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['night_opd']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF109A8A),
                        ),
                      ),
                    ),
                  ),
                ),

                // OPD Grand Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF109A8A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['opd_total']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Separator
                DataCell(Container(width: 1, color: Colors.grey[300])),

                // Expenses Section Header (empty)
                DataCell(SizedBox()),

                // Morning Expenses Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['morning_expenses']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ),

                // Evening Expenses Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['evening_expenses']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ),

                // Night Expenses Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['night_expenses']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ),

                // Expenses Grand Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['expenses_total']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Separator
                DataCell(Container(width: 1, color: Colors.grey[300])),

                // Date Range Total PRICE
                DataCell(
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${_formatAmount(columnTotals['opd_total']! + columnTotals['expenses_total']!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // yearly get data
  Widget _buildYearlyView(EnhancedShiftReportProvider? provider, bool isTablet) {
    print('🔄 Building yearly view...');
    print('   Provider: ${provider != null ? "Available" : "NULL"}');
    if (provider != null) {
      print('   Loading state: ${provider.isLoadingNew}');
      print('   Error: ${provider.errorMessageNew}');
      print('   Yearly summary: ${provider.yearlySummary != null ? "Available" : "NULL"}');

      // NEW: Check which method loaded the data
      if (provider.yearlySummary != null) {
        print('📊 Yearly Summary Keys: ${provider.yearlySummary!.keys}');

        if (provider.yearlySummary!.containsKey('monthly_breakdown')) {
          final breakdown = provider.yearlySummary!['monthly_breakdown'] as List;
          print('📅 Monthly breakdown length: ${breakdown.length}');

          // Check if data has service_data
          if (breakdown.isNotEmpty) {
            final firstMonth = breakdown[0];
            if (firstMonth is Map) {
              print('📊 First month data keys: ${firstMonth.keys}');
              if (firstMonth.containsKey('service_data')) {
                final serviceData = firstMonth['service_data'] as Map<String, dynamic>;
                print('📈 First month has service_data with ${serviceData.length} services');
              }
            }
          }
        }

        // Check combinedServiceBreakdown
        print('🔍 Combined services count: ${provider.combinedServiceBreakdown.length}');
        if (provider.combinedServiceBreakdown.isNotEmpty) {
          final firstService = provider.combinedServiceBreakdown[0];
          print('📊 First service: ${firstService['service_name']} - Rs ${firstService['total']}');
        }
      }
    }

    // Calculate total consultations for the year
    // Calculate totals
    double totalConsultationAmount = 0.0;
    int totalConsultationCount = 0;
    double totalExpensesAmount = 0.0;
    double totalOpdAmount = 0.0;

    if (provider != null && provider.yearlySummary != null) {
      // Calculate OPD total from ALL services (not filtered)
      for (var service in provider.combinedServiceBreakdown) {
        if (service['type'] == 'OPD') {
          totalOpdAmount += (service['total'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // Calculate consultation amount from ALL services
      for (var service in provider.combinedServiceBreakdown) {
        if (service['type'] == 'CONSULTATION') {
          totalConsultationAmount += (service['total'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // Calculate expenses amount from ALL services
      for (var service in provider.combinedServiceBreakdown) {
        if (service['type'] == 'EXPENSE') {
          totalExpensesAmount += (service['total'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // Calculate consultation count from monthly breakdown
      final monthlyBreakdown = provider.yearlySummary!['monthly_breakdown'] as List<dynamic>?;
      if (monthlyBreakdown != null) {
        for (var monthData in monthlyBreakdown) {
          totalConsultationCount += (monthData['total_opd_count'] as int? ?? 0);
        }
      }
    }
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF109A8A), size: 24),
              SizedBox(width: 12),
              Text(
                'Yearly Summary: ${_selectedYear ?? DateTime.now().year}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              // Refresh button
              IconButton(
                onPressed: () => provider?.fetchYearlySummary(),
                icon: Icon(Icons.refresh, color: Color(0xFF109A8A)),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          SizedBox(height: 20),

          // Show loading state
          if (provider != null && provider.isLoadingNew)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF109A8A)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading yearly summary...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Show error state
          else if (provider != null && provider.errorMessageNew.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessageNew}',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchYearlySummary(),
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF109A8A),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Show data when available
          else if (provider != null && provider.yearlySummary != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yearly summary cards - Updated with OPD Total (replaced Net Amount)
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Revenue',
                          (provider.yearlySummary!['total_revenue'] ?? 0).toDouble(),
                          Icons.trending_up,
                          Color(0xFF109A8A),
                          isTablet,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Expenses',
                          (provider.yearlySummary!['total_expenses'] ?? 0).toDouble(),
                          Icons.trending_down,
                          Color(0xFFD97706),
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'OPD Total', // REPLACED: Changed from "Net Amount" to "OPD Total"
                          totalOpdAmount, // REPLACED: Changed from net amount to OPD total
                          Icons.medical_services, // REPLACED: Changed icon
                          Color(0xFF10B981), // Changed color to green for OPD
                          isTablet,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Consultation',
                          totalConsultationAmount,
                          Icons.monetization_on,
                          Color(0xFF8B5CF6),
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Filter Controls
                  _buildYearlyFilters(provider, isTablet),

                  SizedBox(height: 24),

                  // Show appropriate table based on selected view
                  if (provider.selectedYearlyView == 'All' || provider.selectedYearlyView == 'OPD') ...[
                    // OPD Service-wise Monthly Pivot Table
                    Text(
                      'OPD Revenue ${provider.selectedShiftFilter != 'All' ? '(${provider.selectedShiftFilter} Shift)' : ''}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF43A047),
                      ),
                    ),
                    SizedBox(height: 8),

                    SizedBox(height: 16),

                    // OPD Pivot Table
                    _buildOpdServiceMonthPivotTable(provider, isTablet),

                    SizedBox(height: 32),
                  ],

                  if (provider.selectedYearlyView == 'All' || provider.selectedYearlyView == 'CONSULTATION') ...[
                    // Consultation Monthly Pivot Table
                    Text(
                      'Consultations ${provider.selectedShiftFilter != 'All' ? '(${provider.selectedShiftFilter} Shift)' : ''}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    SizedBox(height: 8),


                    SizedBox(height: 16),

                    // Consultation Pivot Table
                    _buildConsultationMonthPivotTable(provider, isTablet),

                    SizedBox(height: 32),
                  ],

                  if (provider.selectedYearlyView == 'All' || provider.selectedYearlyView == 'EXPENSE') ...[
                    // Expenses Monthly Pivot Table
                    Text(
                      'Expenses  ${provider.selectedShiftFilter != 'All' ? '(${provider.selectedShiftFilter} Shift)' : ''}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),

                    SizedBox(height: 16),

                    // Expenses Pivot Table
                    _buildExpensesMonthPivotTable(provider, isTablet),

                    SizedBox(height: 10),
                  ],
                ],
              )
            // Show empty state
            else if (provider != null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.analytics, color: Colors.grey, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'No yearly data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchYearlyReport(),
                          child: Text('Load Yearly Summary'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF109A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Provider is null
              else
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.orange, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Report provider not available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildYearlyFilters(EnhancedShiftReportProvider provider, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              if (provider.selectedYearlyView != 'All' || provider.selectedShiftFilter != 'All')
                GestureDetector(
                  onTap: () => provider.resetYearlyFilters(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.close, size: 14, color: Color(0xFFDC2626)),
                        SizedBox(width: 4),
                        Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Filter dropdowns in a row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'View Type',
                  value: provider.selectedYearlyView,
                  items: [
                    DropdownMenuItem(
                      value: 'All',
                      child: Row(
                        children: [
                          // Icon(Icons.dashboard, size: 18, color: Color(0xFF037389)),
                          SizedBox(width: 8),
                          Text('All'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'OPD',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.medical_services, size: 18, color: Color(0xFF10B981)),
                          ),
                          SizedBox(width: 8),
                          Text('OPD'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'CONSULTATION',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.person, size: 18, color: Color(0xFF8B5CF6)),
                          ),
                          SizedBox(width: 4),
                          Text('Consultations'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'EXPENSE',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.money_off, size: 18, color: Color(0xFFD97706)),
                          ),
                          SizedBox(width: 8),
                          Text('Expenses'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => provider.setSelectedYearlyView(value.toString()),
                  isTablet: isTablet,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: _buildFilterDropdown(
                  label: 'Shift',
                  value: provider.selectedShiftFilter,
                  items: [
                    DropdownMenuItem(
                      value: 'All',
                      child: Row(
                        children: [
                          Icon(Icons.all_inclusive, size: 18, color: Color(0xFF6B7280)),
                          SizedBox(width: 8),
                          Text('All Shifts'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Morning',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(Icons.wb_sunny, size: 18, color: Color(0xFFF59E0B)),
                          ),
                          SizedBox(width: 8),
                          Text('Morning'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Evening',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(Icons.nights_stay, size: 18, color: Color(0xFF8B5CF6)),
                          ),
                          SizedBox(width: 8),
                          Text('Evening'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Night',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(Icons.dark_mode, size: 18, color: Color(0xFF1F2937)),
                          ),
                          SizedBox(width: 8),
                          Text('Night Shift'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => provider.setSelectedShiftFilter(value.toString()),
                  isTablet: isTablet,
                ),
              ),
            ],
          ),

          // Active filters summary
          SizedBox(height: 12),
          if (provider.selectedYearlyView != 'All' || provider.selectedShiftFilter != 'All')
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing: ${_getViewTypeLabel(provider.selectedYearlyView)} ${provider.selectedShiftFilter != 'All' ? '(${provider.selectedShiftFilter} Shift)' : ''}',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getViewTypeLabel(String viewType) {
    switch (viewType) {
      case 'All':
        return 'All Data';
      case 'OPD':
        return 'OPD Services Only';
      case 'CONSULTATION':
        return 'Consultations Only';
      case 'EXPENSE':
        return 'Expenses Only';
      default:
        return 'All Data';
    }
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesMonthPivotTable(EnhancedShiftReportProvider provider, bool isTablet) {
    final yearlySummary = provider.yearlySummary!;
    final monthlyBreakdown = (yearlySummary['monthly_breakdown'] as List<dynamic>);

    // Use filteredServices instead of combinedServiceBreakdown to respect shift filters
    final expenseServices = provider.filteredServices
        .where((service) => service['type'] == 'EXPENSE')
        .toList();

    // Get month names for header
    final monthNames = monthlyBreakdown
        .map<String>((m) => m['month_name'] as String)
        .toList();

    // Add "Expense Head" column and month columns
    final List<String> columns = ['Expense Head', ...monthNames, 'Year Total'];

    // Calculate totals for each month
    Map<int, double> monthlyTotals = {};
    Map<String, double> rowTotals = {};

    // Initialize totals
    for (int i = 1; i <= 12; i++) {
      monthlyTotals[i] = 0.0;
    }

    // Calculate monthly totals and row totals for expenses
    for (var service in expenseServices) {
      final expenseName = service['service_name'].toString();

      // Use appropriate total based on shift filter
      double serviceTotal = 0.0;

      if (provider.selectedShiftFilter != 'All') {
        // Use shift-filtered total
        serviceTotal = (service['shift_filtered_total'] as num?)?.toDouble() ?? 0.0;

        // If not found, try to calculate from shift-specific monthly amounts
        if (serviceTotal == 0.0 && service.containsKey('filtered_monthly_amounts')) {
          final filteredAmounts = service['filtered_monthly_amounts'] as Map<String, dynamic>?;
          if (filteredAmounts != null) {
            filteredAmounts.forEach((key, value) {
              if (value is num) {
                serviceTotal += value.toDouble();
              }
            });
          }
        }
      } else {
        // Use regular total
        serviceTotal = (service['total'] as num?)?.toDouble() ?? 0.0;
      }

      rowTotals[expenseName] = serviceTotal;

      // Get monthly amounts based on shift filter
      Map<String, dynamic>? monthlyAmounts;

      if (provider.selectedShiftFilter != 'All') {
        // Check for shift-filtered amounts
        monthlyAmounts = service['filtered_monthly_amounts'] as Map<String, dynamic>?;

        // If not found, try to get from expense-specific shift amounts
        if (monthlyAmounts == null) {
          switch (provider.selectedShiftFilter.toLowerCase()) {
            case 'morning':
              monthlyAmounts = service['morning_amounts'] as Map<String, dynamic>?;
              break;
            case 'evening':
              monthlyAmounts = service['evening_amounts'] as Map<String, dynamic>?;
              break;
            case 'night':
              monthlyAmounts = service['night_amounts'] as Map<String, dynamic>?;
              break;
          }
        }
      }

      // If no shift-specific amounts, use regular monthly amounts
      monthlyAmounts ??= service['monthly_amounts'] as Map<String, dynamic>?;

      for (int month = 1; month <= 12; month++) {
        final monthKey = 'month_$month';
        double monthAmount = 0.0;

        if (monthlyAmounts != null && monthlyAmounts.containsKey(monthKey)) {
          final amount = monthlyAmounts[monthKey];
          if (amount is num) {
            monthAmount = amount.toDouble();
          }
        }

        // Add to monthly total
        monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + monthAmount;
      }
    }

    // Calculate grand total for expenses
    double grandTotal = expenseServices.fold(0.0, (sum, service) {
      if (provider.selectedShiftFilter != 'All') {
        double shiftTotal = (service['shift_filtered_total'] as num?)?.toDouble() ?? 0.0;

        if (shiftTotal == 0.0 && service.containsKey('filtered_monthly_amounts')) {
          final filteredAmounts = service['filtered_monthly_amounts'] as Map<String, dynamic>?;
          if (filteredAmounts != null) {
            filteredAmounts.forEach((key, value) {
              if (value is num) {
                shiftTotal += value.toDouble();
              }
            });
          }
        }
        return sum + shiftTotal;
      } else {
        return sum + ((service['total'] as num?)?.toDouble() ?? 0.0);
      }
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header Row - Months with Shift Indicator
            Container(
              color: Color(0xFFF9FAFB),
              child: Row(
                children: columns.map((columnName) {
                  final isExpenseColumn = columnName == 'Expense Head';
                  final isTotalColumn = columnName == 'Year Total';

                  return Container(
                    width: isExpenseColumn ? 180 : 200,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            columnName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 14 : 13,
                              color: Color(0xFF374151),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (provider.selectedShiftFilter != 'All' && !isExpenseColumn && !isTotalColumn)
                            Text(
                              '(${provider.selectedShiftFilter})',
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 9,
                                color: _getShiftColor(provider.selectedShiftFilter),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Data Rows - Expense Heads
            if (expenseServices.isNotEmpty)
              ...expenseServices.map((service) {
                final expenseName = service['service_name'].toString();

                // Determine which total to use based on shift filter
                double serviceTotal = 0.0;

                if (provider.selectedShiftFilter != 'All') {
                  serviceTotal = (service['shift_filtered_total'] as num?)?.toDouble() ?? 0.0;

                  if (serviceTotal == 0.0 && service.containsKey('filtered_monthly_amounts')) {
                    final filteredAmounts = service['filtered_monthly_amounts'] as Map<String, dynamic>?;
                    if (filteredAmounts != null) {
                      filteredAmounts.forEach((key, value) {
                        if (value is num) {
                          serviceTotal += value.toDouble();
                        }
                      });
                    }
                  }
                } else {
                  serviceTotal = (service['total'] as num?)?.toDouble() ?? 0.0;
                }

                return Container(
                  color: expenseServices.indexOf(service) % 2 == 0 ? Colors.white : Color(0xFFF9FAFB),
                  child: Row(
                    children: [
                      // Expense Name Column with Shift Indicator
                      Container(
                        width: 180,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expenseName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14 : 13,
                                color: Color(0xFFD97706),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    fontSize: isTablet ? 11 : 10,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if (provider.selectedShiftFilter != 'All')
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        provider.selectedShiftFilter,
                                        style: TextStyle(
                                          fontSize: isTablet ? 9 : 8,
                                          color: _getShiftColor(provider.selectedShiftFilter),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Month Columns with Shift-specific amounts
                      ...monthlyBreakdown.map((monthData) {
                        final month = monthData['month'] as int;
                        final monthAmount = _getServiceMonthAmount(provider, month, expenseName, false);

                        return Container(
                          width: 200,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE5E7EB)),
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rs ${_formatAmount(monthAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 12 : 11,
                                  color: monthAmount > 0 ? Color(0xFFDC2626) : Colors.grey[400],
                                ),
                              ),
                              if (monthAmount > 0 && provider.selectedShiftFilter != 'All')
                                SizedBox(height: 4),
                              if (monthAmount > 0 && provider.selectedShiftFilter != 'All')
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    provider.selectedShiftFilter,
                                    style: TextStyle(
                                      fontSize: isTablet ? 8 : 7,
                                      color: _getShiftColor(provider.selectedShiftFilter),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Year Total Column (Row Total) with Shift Indicator
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rs ${_formatAmount(serviceTotal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 14 : 13,
                                color: serviceTotal > 0 ? Color(0xFFB45309) : Colors.grey[400],
                              ),
                            ),
                            if (serviceTotal > 0 && provider.selectedShiftFilter != 'All')
                              SizedBox(height: 4),
                            if (serviceTotal > 0 && provider.selectedShiftFilter != 'All')
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${provider.selectedShiftFilter} Total',
                                  style: TextStyle(
                                    fontSize: isTablet ? 10 : 9,
                                    color: _getShiftColor(provider.selectedShiftFilter),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
            else
              Container(
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.money_off,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8),
                      Text(
                        provider.selectedShiftFilter != 'All'
                            ? 'No expense data for ${provider.selectedShiftFilter} shift'
                            : 'No expense data available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Expenses Column Totals Row (Monthly Totals) with Shift Indicator
            Container(
              color: Color(0xFFFEF3C7),
              child: Row(
                children: [
                  // Label Column
                  Container(
                    width: 180,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.selectedShiftFilter != 'All'
                              ? '${provider.selectedShiftFilter} Expense Totals'
                              : 'Expense Monthly Totals',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 13,
                            color: provider.selectedShiftFilter != 'All'
                                ? _getShiftColor(provider.selectedShiftFilter)
                                : Color(0xFFD97706),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          provider.selectedShiftFilter != 'All'
                              ? 'Sum of ${provider.selectedShiftFilter} shift'
                              : 'Sum of expenses',
                          style: TextStyle(
                            fontSize: isTablet ? 10 : 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month Column Totals
                  ...monthlyBreakdown.map((monthData) {
                    final month = monthData['month'] as int;
                    final monthTotal = monthlyTotals[month] ?? 0.0;

                    return Container(
                      width: 200,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE5E7EB)),
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Rs ${_formatAmount(monthTotal)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 12 : 11,
                              color: provider.selectedShiftFilter != 'All'
                                  ? _getShiftColor(provider.selectedShiftFilter)
                                  : Color(0xFFD97706),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            provider.selectedShiftFilter != 'All'
                                ? '${provider.selectedShiftFilter} ${monthData['month_name']}'
                                : 'Month ${monthData['month_name']}',
                            style: TextStyle(
                              fontSize: isTablet ? 10 : 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Expenses Grand Total Column with Shift Indicator
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Rs ${_formatAmount(grandTotal)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 13,
                            color: provider.selectedShiftFilter != 'All'
                                ? _getShiftColor(provider.selectedShiftFilter)
                                : Color(0xFFB45309),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          provider.selectedShiftFilter != 'All'
                              ? '${provider.selectedShiftFilter} Grand Total'
                              : 'Expenses Grand Total',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Legend with Shift Indicator
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                color: Color(0xFFF3F4F6),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem('Expense Heads', Color(0xFFD97706)),
                  _buildLegendItem('Expense Amount', Color(0xFFDC2626)),
                  if (provider.selectedShiftFilter != 'All')
                    _buildLegendItem(
                      '${provider.selectedShiftFilter} Shift',
                      _getShiftColor(provider.selectedShiftFilter),
                    ),
                  _buildLegendItem(
                    provider.selectedShiftFilter != 'All'
                        ? '${provider.selectedShiftFilter} Totals'
                        : 'Monthly Expense Totals',
                    provider.selectedShiftFilter != 'All'
                        ? _getShiftColor(provider.selectedShiftFilter)
                        : Color(0xFFD97706),
                  ),
                  _buildLegendItem(
                    provider.selectedShiftFilter != 'All'
                        ? '${provider.selectedShiftFilter} Grand Total'
                        : 'Expenses Grand Total',
                    provider.selectedShiftFilter != 'All'
                        ? _getShiftColor(provider.selectedShiftFilter)
                        : Color(0xFFB45309),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // opd serviecs
  Widget _buildOpdServiceMonthPivotTable(EnhancedShiftReportProvider provider, bool isTablet) {
    final yearlySummary = provider.yearlySummary!;
    final monthlyBreakdown = (yearlySummary['monthly_breakdown'] as List<dynamic>);

    // Use FILTERED services instead of all OPD services
    final filteredServices = provider.filteredServices
        .where((service) => service['type'] == 'OPD')
        .toList();

    // Get month names for header
    final monthNames = monthlyBreakdown
        .map<String>((m) => m['month_name'] as String)
        .toList();

    // Add "Service" column and month columns
    final List<String> columns = ['OPD Service', ...monthNames, 'Year Total'];

    // Calculate totals for each month - RESPECT SHIFT FILTER
    Map<int, double> monthlyTotals = {};
    Map<String, double> rowTotals = {};
    Map<int, Map<String, double>> monthlyServiceTotals = {};

    // Initialize totals
    for (int i = 1; i <= 12; i++) {
      monthlyTotals[i] = 0.0;
      monthlyServiceTotals[i] = {};
    }

    // Calculate monthly totals and row totals for OPD services - RESPECT SHIFT FILTER
    for (var service in filteredServices) {
      final serviceName = service['service_name'].toString();
      // Use shift-filtered total if available, otherwise use regular total
      double serviceTotal = 0.0;

      if (provider.selectedShiftFilter != 'All') {
        // Use shift-filtered total
        serviceTotal = (service['shift_filtered_total'] as num?)?.toDouble() ?? 0.0;

        // If shift_filtered_total doesn't exist, calculate from shift-specific monthly amounts
        if (serviceTotal == 0.0) {
          final shiftKey = '${provider.selectedShiftFilter.toLowerCase()}_amounts';
          final shiftAmounts = service[shiftKey] as Map<String, dynamic>?;
          if (shiftAmounts != null) {
            shiftAmounts.forEach((key, value) {
              if (value is num) {
                serviceTotal += value.toDouble();
              }
            });
          }
        }
      } else {
        // Use regular total
        serviceTotal = (service['total'] as num?)?.toDouble() ?? 0.0;
      }

      rowTotals[serviceName] = serviceTotal;

      // Get monthly amounts - RESPECT SHIFT FILTER
      Map<String, dynamic>? monthlyAmounts;

      if (provider.selectedShiftFilter != 'All') {
        // Use shift-specific amounts
        final shiftKey = '${provider.selectedShiftFilter.toLowerCase()}_amounts';
        monthlyAmounts = service[shiftKey] as Map<String, dynamic>?;

        // If shift-specific amounts don't exist, fall back to filtered_monthly_amounts
        if (monthlyAmounts == null) {
          monthlyAmounts = service['filtered_monthly_amounts'] as Map<String, dynamic>?;
        }
      }

      // If no shift-specific amounts, use regular monthly amounts
      monthlyAmounts ??= service['monthly_amounts'] as Map<String, dynamic>?;

      for (int month = 1; month <= 12; month++) {
        final monthKey = 'month_$month';
        double monthAmount = 0.0;

        if (monthlyAmounts != null && monthlyAmounts.containsKey(monthKey)) {
          final amount = monthlyAmounts[monthKey];
          if (amount is num) {
            monthAmount = amount.toDouble();
          }
        }

        // Add to monthly total
        monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + monthAmount;

        // Add to monthly service totals
        monthlyServiceTotals[month]![serviceName] = monthAmount;
      }
    }

    // Calculate grand total - RESPECT SHIFT FILTER
    double grandTotal = 0.0;
    if (provider.selectedShiftFilter != 'All') {
      // Sum all shift-filtered totals
      for (var service in filteredServices) {
        double serviceTotal = (service['shift_filtered_total'] as num?)?.toDouble() ?? 0.0;
        if (serviceTotal == 0.0) {
          // Calculate from shift-specific monthly amounts
          final shiftKey = '${provider.selectedShiftFilter.toLowerCase()}_amounts';
          final shiftAmounts = service[shiftKey] as Map<String, dynamic>?;
          if (shiftAmounts != null) {
            shiftAmounts.forEach((key, value) {
              if (value is num) {
                serviceTotal += value.toDouble();
              }
            });
          }
        }
        grandTotal += serviceTotal;
      }
    } else {
      grandTotal = rowTotals.values.fold(0.0, (sum, value) => sum + value);
    }

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              // Header Row - Months with Shift Indicator
              Container(
                color: Color(0xFFF9FAFB),
                child: Row(
                  children: columns.map((columnName) {
                    final isServiceColumn = columnName == 'OPD Service';
                    final isTotalColumn = columnName == 'Year Total';

                    return Container(
                      width: isServiceColumn ? 180 : 200,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE5E7EB)),
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              columnName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 14 : 13,
                                color: Color(0xFF374151),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (provider.selectedShiftFilter != 'All' && !isServiceColumn && !isTotalColumn)
                              Text(
                                '(${provider.selectedShiftFilter})',
                                style: TextStyle(
                                  fontSize: isTablet ? 10 : 9,
                                  color: _getShiftColor(provider.selectedShiftFilter),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Data Rows - OPD Services
              if (filteredServices.isNotEmpty)
                ...filteredServices.map((service) {
                  final serviceName = service['service_name'].toString();
                  // Use appropriate total based on shift filter
                  double serviceTotal = 0.0;

                  if (provider.selectedShiftFilter != 'All') {
                    serviceTotal = (service['shift_filtered_total'] as num?)?.toDouble() ?? 0.0;
                    if (serviceTotal == 0.0) {
                      // Calculate from shift-specific monthly amounts
                      final shiftKey = '${provider.selectedShiftFilter.toLowerCase()}_amounts';
                      final shiftAmounts = service[shiftKey] as Map<String, dynamic>?;
                      if (shiftAmounts != null) {
                        shiftAmounts.forEach((key, value) {
                          if (value is num) {
                            serviceTotal += value.toDouble();
                          }
                        });
                      }
                    }
                  } else {
                    serviceTotal = (service['total'] as num?)?.toDouble() ?? 0.0;
                  }

                  return Container(
                    color: filteredServices.indexOf(service) % 2 == 0 ? Colors.white : Color(0xFFF9FAFB),
                    child: Row(
                      children: [
                        // Service Name Column with Shift Indicator
                        Container(
                          width: 180,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE5E7EB)),
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 14 : 13,
                                  color: Color(0xFF109A8A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'OPD Service',
                                    style: TextStyle(
                                      fontSize: isTablet ? 11 : 10,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  if (provider.selectedShiftFilter != 'All')
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          provider.selectedShiftFilter,
                                          style: TextStyle(
                                            fontSize: isTablet ? 9 : 8,
                                            color: _getShiftColor(provider.selectedShiftFilter),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Month Columns with Shift-specific amounts
                        ...monthlyBreakdown.map((monthData) {
                          final month = monthData['month'] as int;
                          final monthAmount = _getServiceMonthAmount(provider, month, serviceName, true);

                          return Container(
                            width: 200,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Color(0xFFE5E7EB)),
                                bottom: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Rs ${_formatAmount(monthAmount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet ? 12 : 11,
                                    color: monthAmount > 0 ? Color(0xFF10B981) : Colors.grey[400],
                                  ),
                                ),
                                if (monthAmount > 0 && provider.selectedShiftFilter != 'All')
                                  SizedBox(height: 4),
                                if (monthAmount > 0 && provider.selectedShiftFilter != 'All')
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      provider.selectedShiftFilter,
                                      style: TextStyle(
                                        fontSize: isTablet ? 8 : 7,
                                        color: _getShiftColor(provider.selectedShiftFilter),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),

                        // Year Total Column (Row Total) with Shift Indicator
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE5E7EB)),
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rs ${_formatAmount(serviceTotal)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 14 : 13,
                                  color: serviceTotal > 0 ? Color(0xFF047857) : Colors.grey[400],
                                ),
                              ),
                              if (serviceTotal > 0 && provider.selectedShiftFilter != 'All')
                                SizedBox(height: 4),
                              if (serviceTotal > 0 && provider.selectedShiftFilter != 'All')
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getShiftColor(provider.selectedShiftFilter).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${provider.selectedShiftFilter} Total',
                                    style: TextStyle(
                                      fontSize: isTablet ? 10 : 9,
                                      color: _getShiftColor(provider.selectedShiftFilter),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              else
                Container(
                  height: 150,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_alt_off,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          provider.selectedShiftFilter != 'All'
                              ? 'No OPD data for ${provider.selectedShiftFilter} shift'
                              : 'No OPD service data available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // OPD Column Totals Row (Monthly Totals) with Shift Indicator
              Container(
                color: Color(0xFFEFF6FF),
                child: Row(
                  children: [
                    // Label Column
                    Container(
                      width: 180,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE5E7EB)),
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.selectedShiftFilter != 'All'
                                ? '${provider.selectedShiftFilter} Monthly Totals'
                                : 'OPD Monthly Totals',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 14 : 13,
                              color: provider.selectedShiftFilter != 'All'
                                  ? _getShiftColor(provider.selectedShiftFilter)
                                  : Color(0xFF109A8A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            provider.selectedShiftFilter != 'All'
                                ? 'Sum of ${provider.selectedShiftFilter} shift'
                                : 'Sum of OPD services',
                            style: TextStyle(
                              fontSize: isTablet ? 10 : 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Month Column Totals
                    ...monthlyBreakdown.map((monthData) {
                      final month = monthData['month'] as int;
                      final monthTotal = monthlyTotals[month] ?? 0.0;

                      return Container(
                        width: 200,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rs ${_formatAmount(monthTotal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 12 : 11,
                                color: provider.selectedShiftFilter != 'All'
                                    ? _getShiftColor(provider.selectedShiftFilter)
                                    : Color(0xFF109A8A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              provider.selectedShiftFilter != 'All'
                                  ? '${provider.selectedShiftFilter} ${monthData['month_name']}'
                                  : 'Month ${monthData['month_name']}',
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // OPD Grand Total Column with Shift Indicator
                    Container(
                      width: 200,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE5E7EB)),
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Rs ${_formatAmount(grandTotal)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 14 : 13,
                              color: provider.selectedShiftFilter != 'All'
                                  ? _getShiftColor(provider.selectedShiftFilter)
                                  : Color(0xFF047857),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            provider.selectedShiftFilter != 'All'
                                ? '${provider.selectedShiftFilter} Grand Total'
                                : 'OPD Grand Total',
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Legend with Shift Indicator
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  color: Color(0xFFF3F4F6),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem('OPD Services', Color(0xFF109A8A)),
                    _buildLegendItem('OPD Revenue', Color(0xFF10B981)),
                    if (provider.selectedShiftFilter != 'All')
                      _buildLegendItem(
                        '${provider.selectedShiftFilter} Shift',
                        _getShiftColor(provider.selectedShiftFilter),
                      ),
                    _buildLegendItem(
                      provider.selectedShiftFilter != 'All'
                          ? '${provider.selectedShiftFilter} Totals'
                          : 'Monthly OPD Totals',
                      provider.selectedShiftFilter != 'All'
                          ? _getShiftColor(provider.selectedShiftFilter)
                          : Color(0xFF109A8A),
                    ),
                    _buildLegendItem(
                      provider.selectedShiftFilter != 'All'
                          ? '${provider.selectedShiftFilter} Grand Total'
                          : 'OPD Grand Total',
                      provider.selectedShiftFilter != 'All'
                          ? _getShiftColor(provider.selectedShiftFilter)
                          : Color(0xFF047857),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
  Color _getShiftColor(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return Color(0xFFF59E0B); // Orange for morning
      case 'evening':
        return Color(0xFF8B5CF6); // Purple for evening
      case 'night':
        return Color(0xFF1F2937); // Dark grey for night
      default:
        return Color(0xFF109A8A); // Default teal
    }
  }
  // Helper method to calculate total by type
  double _calculateTotalByType(List<Map<String, dynamic>> services, String type) {
    return services
        .where((service) => service['type'] == type)
        .fold(0.0, (sum, service) => sum + ((service['total'] as num?)?.toDouble() ?? 0.0));
  }
// Helper method to get service amount for a specific month
  double _getServiceMonthAmount(EnhancedShiftReportProvider provider, int month, String serviceName, bool isOpd) {
    if (provider.filteredServices.isEmpty) {
      return 0.0;
    }

    // Find the service in filtered breakdown
    for (var service in provider.filteredServices) {
      if (service['service_name'] == serviceName) {
        // Check if it's a consultation service
        final isConsultation = service['type'] == 'CONSULTATION';

        // Determine which monthly amounts to use based on shift filter
        Map<String, dynamic>? monthlyAmounts;

        if (provider.selectedShiftFilter != 'All') {
          // Check for shift-filtered amounts first
          if (service.containsKey('filtered_monthly_amounts')) {
            monthlyAmounts = service['filtered_monthly_amounts'] as Map<String, dynamic>?;
            print('🔍 Using filtered_monthly_amounts for $serviceName');
          } else if (isConsultation) {
            // Fall back to consultation-specific shift amounts
            switch (provider.selectedShiftFilter.toLowerCase()) {
              case 'morning':
                monthlyAmounts = service['morning_amounts'] as Map<String, dynamic>?;
                break;
              case 'evening':
                monthlyAmounts = service['evening_amounts'] as Map<String, dynamic>?;
                break;
              case 'night':
                monthlyAmounts = service['night_amounts'] as Map<String, dynamic>?;
                break;
            }
            print('🔍 Using ${provider.selectedShiftFilter.toLowerCase()}_amounts for $serviceName');
          }
        }

        // If no shift-specific amounts, use regular monthly amounts
        if (monthlyAmounts == null) {
          monthlyAmounts = service['monthly_amounts'] as Map<String, dynamic>?;
          print('🔍 Using monthly_amounts for $serviceName');
        }

        if (monthlyAmounts != null) {
          final monthKey = 'month_$month';
          final amount = monthlyAmounts[monthKey];

          print('📊 $serviceName - Month $month: $amount');

          if (amount is num) {
            return amount.toDouble();
          } else if (amount is double) {
            return amount;
          } else if (amount is int) {
            return amount.toDouble();
          }
          return 0.0;
        }

        print('⚠️ No monthly amounts found for $serviceName');
        return 0.0;
      }
    }

    print('❌ Service $serviceName not found in filteredServices');
    return 0.0;
  }
// Helper method for legend items
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationMonthPivotTable(EnhancedShiftReportProvider provider, bool isTablet) {
    final yearlySummary = provider.yearlySummary!;
    final monthlyBreakdown = (yearlySummary['monthly_breakdown'] as List<dynamic>);

    // Use filteredServices
    final consultationServices = provider.filteredServices
        .where((service) => service['type'] == 'CONSULTATION')
        .toList();

    // Get month names for header
    final monthNames = monthlyBreakdown
        .map<String>((m) => m['month_name'] as String)
        .toList();

    // Add "Doctor" column and month columns
    final List<String> columns = ['Doctor', ...monthNames, 'Year Total'];

    // Calculate totals for each month
    Map<int, double> monthlyTotals = {};

    // Initialize totals
    for (int i = 1; i <= 12; i++) {
      monthlyTotals[i] = 0.0;
    }

    // Calculate monthly totals for consultations
    for (var service in consultationServices) {
      // Get monthly amounts based on shift filter
      Map<String, dynamic>? monthlyAmounts;

      if (provider.selectedShiftFilter != 'All') {
        // Use shift-specific amounts
        switch (provider.selectedShiftFilter.toLowerCase()) {
          case 'morning':
            monthlyAmounts = service['morning_amounts'] as Map<String, dynamic>?;
            break;
          case 'evening':
            monthlyAmounts = service['evening_amounts'] as Map<String, dynamic>?;
            break;
          case 'night':
            monthlyAmounts = service['night_amounts'] as Map<String, dynamic>?;
            break;
        }
      } else {
        // Use regular monthly amounts
        monthlyAmounts = service['monthly_amounts'] as Map<String, dynamic>?;
      }

      if (monthlyAmounts != null) {
        for (int month = 1; month <= 12; month++) {
          final monthKey = 'month_$month';
          double monthAmount = 0.0;

          final amount = monthlyAmounts[monthKey];
          if (amount is num) {
            monthAmount = amount.toDouble();
          }

          // Add to monthly total
          monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + monthAmount;
        }
      }
    }

    // Calculate grand total for consultations
    double grandTotal = consultationServices.fold(0.0, (sum, service) {
      if (provider.selectedShiftFilter != 'All') {
        double shiftTotal = 0.0;
        switch (provider.selectedShiftFilter.toLowerCase()) {
          case 'morning':
            shiftTotal = (service['morning_total'] as num?)?.toDouble() ?? 0.0;
            break;
          case 'evening':
            shiftTotal = (service['evening_total'] as num?)?.toDouble() ?? 0.0;
            break;
          case 'night':
            shiftTotal = (service['night_total'] as num?)?.toDouble() ?? 0.0;
            break;
        }
        return sum + shiftTotal;
      } else {
        return sum + ((service['total'] as num?)?.toDouble() ?? 0.0);
      }
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header Row - Months with Shift Indicator
            Container(
              color: Color(0xFFF9FAFB),
              child: Row(
                children: columns.map((columnName) {
                  final isDoctorColumn = columnName == 'Doctor';
                  final isTotalColumn = columnName == 'Year Total';

                  return Container(
                    width: isDoctorColumn ? 180 : 200,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            columnName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 14 : 13,
                              color: Color(0xFF374151),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (provider.selectedShiftFilter != 'All' && !isDoctorColumn && !isTotalColumn)
                            Text(
                              '(${provider.selectedShiftFilter})',
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 9,
                                color: _getShiftColor(provider.selectedShiftFilter),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Data Rows - Doctors
            if (consultationServices.isNotEmpty)
              ...consultationServices.map((service) {
                final doctorName = service['service_name'].toString();

                // Determine which total to use based on shift filter
                double serviceTotal = 0.0;

                if (provider.selectedShiftFilter != 'All') {
                  switch (provider.selectedShiftFilter.toLowerCase()) {
                    case 'morning':
                      serviceTotal = (service['morning_total'] as num?)?.toDouble() ?? 0.0;
                      break;
                    case 'evening':
                      serviceTotal = (service['evening_total'] as num?)?.toDouble() ?? 0.0;
                      break;
                    case 'night':
                      serviceTotal = (service['night_total'] as num?)?.toDouble() ?? 0.0;
                      break;
                  }
                } else {
                  serviceTotal = (service['total'] as num?)?.toDouble() ?? 0.0;
                }

                return Container(
                  color: consultationServices.indexOf(service) % 2 == 0 ? Colors.white : Color(0xFFF9FAFB),
                  child: Row(
                    children: [
                      // Doctor Name Column
                      Container(
                        width: 180,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14 : 13,
                                color: Color(0xFF8B5CF6),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Consultation',
                              style: TextStyle(
                                fontSize: isTablet ? 11 : 10,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Month Columns
                      ...monthlyBreakdown.map((monthData) {
                        final month = monthData['month'] as int;
                        double monthAmount = 0.0;

                        // Get appropriate month amount based on shift filter
                        if (provider.selectedShiftFilter != 'All') {
                          Map<String, dynamic>? shiftAmounts;
                          switch (provider.selectedShiftFilter.toLowerCase()) {
                            case 'morning':
                              shiftAmounts = service['morning_amounts'] as Map<String, dynamic>?;
                              break;
                            case 'evening':
                              shiftAmounts = service['evening_amounts'] as Map<String, dynamic>?;
                              break;
                            case 'night':
                              shiftAmounts = service['night_amounts'] as Map<String, dynamic>?;
                              break;
                          }

                          if (shiftAmounts != null) {
                            final monthKey = 'month_$month';
                            final amount = shiftAmounts[monthKey];
                            if (amount is num) {
                              monthAmount = amount.toDouble();
                            }
                          }
                        } else {
                          // Use the helper method for "All" shifts
                          monthAmount = _getServiceMonthAmount(provider, month, doctorName, false);
                        }

                        return Container(
                          width: 200,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE5E7EB)),
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rs ${_formatAmount(monthAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 12 : 11,
                                  color: monthAmount > 0 ? Color(0xFF8B5CF6) : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Year Total Column (Row Total)
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rs ${_formatAmount(serviceTotal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 14 : 13,
                                color: serviceTotal > 0 ? Color(0xFF7C3AED) : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
            else
              Container(
                height: 150,
                child: Center(
                  child: Text(
                    'No consultation data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            // Consultation Column Totals Row (Monthly Totals)
            Container(
              color: Color(0xFFF5F3FF),
              child: Row(
                children: [
                  // Label Column
                  Container(
                    width: 180,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Monthly Totals',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 13,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sum of consultations',
                          style: TextStyle(
                            fontSize: isTablet ? 10 : 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month Column Totals
                  ...monthlyBreakdown.map((monthData) {
                    final month = monthData['month'] as int;
                    final monthTotal = monthlyTotals[month] ?? 0.0;

                    return Container(
                      width: 200,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE5E7EB)),
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Rs ${_formatAmount(monthTotal)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 12 : 11,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Month ${monthData['month_name']}',
                            style: TextStyle(
                              fontSize: isTablet ? 10 : 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Consultation Grand Total Column
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Rs ${_formatAmount(grandTotal)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 13,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Consultation Grand Total',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// Helper widget for summary items
  Widget _buildSummaryItem(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, IconData icon, Color color, bool isTablet) {
    // Enhanced MediaQuery for comprehensive responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // Multiple breakpoints for better responsiveness
    final isLargeDesktop = screenWidth > 1440;
    final isDesktop = screenWidth > 1024;
    final isLargeTablet = screenWidth > 768;
    final isTablet = screenWidth > 600;
    final isLargeMobile = screenWidth > 400;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Calculate responsive sizes
    double getCardPadding() {
      if (isLargeDesktop) return 22;
      if (isDesktop) return 20;
      if (isLargeTablet) return 18;
      if (isTablet) return 16;
      if (isLargeMobile) return 14;
      return 12;
    }

    double getIconPadding() {
      if (isLargeDesktop) return 14;
      if (isDesktop) return 12;
      if (isLargeTablet) return 11;
      if (isTablet) return 10;
      if (isLargeMobile) return 9;
      return 8;
    }

    double getIconSize() {
      if (isLargeDesktop) return 22;
      if (isDesktop) return 20;
      if (isLargeTablet) return 19;
      if (isTablet) return 18;
      if (isLargeMobile) return 17;
      return 16;
    }

    double getSpacing() {
      if (isLargeDesktop) return 16;
      if (isDesktop) return 14;
      if (isLargeTablet) return 13;
      if (isTablet) return 12;
      if (isLargeMobile) return 11;
      return 10;
    }

    double getTitleFontSize() {
      if (isLargeDesktop) return 13;
      if (isDesktop) return 12;
      if (isLargeTablet) return 11.5;
      if (isTablet) return 11;
      if (isLargeMobile) return 10.5;
      return 10;
    }

    double getValueFontSize() {
      if (isLargeDesktop) return 17;
      if (isDesktop) return 16;
      if (isLargeTablet) return 15;
      if (isTablet) return 14;
      if (isLargeMobile) return 13.5;
      return 13;
    }

    double getBorderRadius() {
      if (isLargeDesktop) return 16;
      if (isDesktop) return 14;
      if (isLargeTablet) return 13;
      if (isTablet) return 12;
      if (isLargeMobile) return 11;
      return 10;
    }

    // Get the calculated values
    final cardPadding = getCardPadding();
    final iconPadding = getIconPadding();
    final iconSize = getIconSize();
    final spacing = getSpacing();
    final titleFontSize = getTitleFontSize();
    final valueFontSize = getValueFontSize();
    final borderRadius = getBorderRadius();
    final formattedValue = _formatAmount(value);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container with modern design
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius * 0.7),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),

          SizedBox(width: spacing),

          // Content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title with subtle styling
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: 4),

                // Value with better typography
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    bool isValueTooLong = formattedValue.length > 8;

                    return Text(
                      'Rs $formattedValue',
                      style: TextStyle(
                        fontSize: isValueTooLong && availableWidth < 120
                            ? valueFontSize * 0.9
                            : valueFontSize,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardsTabs(ShiftReportProvider provider, bool isTablet) {
    if (provider.isLoading && provider.opdRecords.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF109A8A).withOpacity(0.1),
                    width: 3,
                  ),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF109A8A)),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading financial data...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final financial = provider.financialSummary;

    final tabs = [
      {
        'title': 'Total Revenue',
        'value': 'Rs ${_formatAmount(financial.totalRevenue)}',
        'subtitle': 'All services revenue',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF109A8A),
        'gradient': LinearGradient(
          colors: [Color(0xFF109A8A), Color(0xFF0B7C6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Total Expenses',
        'value': 'Rs ${_formatAmount(financial.totalExpensesWithDocShare)}',
        'subtitle': 'Including doctor share',
        'icon': Icons.trending_down_rounded,
        'color': const Color(0xFFD97706),
        'gradient': LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Net Revenue',
        'value': 'Rs ${_formatAmount(financial.netHospitalRevenue)}',
        'subtitle': 'After all expenses',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF10B981),
        'gradient': LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Consultations',
        'value': '${provider.consultationSummaries.length}',
        'subtitle': 'Active doctors',
        'icon': Icons.medical_services_rounded,
        'color': const Color(0xFF14B8A6),
        'gradient': LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    // Get screen dimensions with MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 768;
    final isSmallScreen = screenWidth <= 480;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    // Calculate available width for cards (accounting for padding)
    final availableWidth = screenWidth - padding.left - padding.right - 32; // 16px padding on each side

    // Calculate card width based on available space (2 cards per row with spacing)
    final cardWidth = (availableWidth - 16) / 2; // Subtract spacing between cards

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth,
        minHeight: 200,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Always 2 cards per row
          crossAxisSpacing: _getCrossAxisSpacing(screenWidth),
          mainAxisSpacing: _getMainAxisSpacing(screenWidth),
          childAspectRatio: _getChildAspectRatio(screenWidth),
        ),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _selectedTabIndex == index;

          return Container(
            constraints: BoxConstraints(
              maxWidth: cardWidth,
            ),
            child: _buildModernSummaryCard(
              title: tab['title'] as String,
              value: tab['value'] as String,
              subtitle: tab['subtitle'] as String,
              icon: tab['icon'] as IconData,
              color: tab['color'] as Color,
              gradient: tab['gradient'] as LinearGradient,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedTabIndex = isSelected ? -1 : index;
                });
              },
              screenWidth: screenWidth,
              cardWidth: cardWidth,
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
    required bool isSelected,
    required VoidCallback onTap,
    required double screenWidth,
    required double cardWidth,
  }) {
    // Calculate sizes based on card width to prevent overflow
    final bool isLargeCard = cardWidth > 180;
    final bool isMediumCard = cardWidth > 140;

    final double padding = isLargeCard ? 16 : (isMediumCard ? 14 : 12);
    final double iconSize = isLargeCard ? 22 : (isMediumCard ? 20 : 18);
    final double iconContainerSize = isLargeCard ? 44 : (isMediumCard ? 40 : 36);
    final double fontSizeTitle = isLargeCard ? 15 : (isMediumCard ? 14 : 13);
    final double fontSizeValue = isLargeCard ? 20 : (isMediumCard ? 18 : 16);
    final double fontSizeSubtitle = isLargeCard ? 12 : 11;
    final double borderRadius = isLargeCard ? 14 : 12;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: cardWidth,
            minHeight: 120,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(
              minHeight: 120,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isSelected ? color.withOpacity(0.4) : Color(0xFFE5E7EB),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.15 : 0.06),
                  blurRadius: isSelected ? 20 : 12,
                  spreadRadius: isSelected ? -2 : 0,
                  offset: Offset(0, isSelected ? 8 : 4),
                ),
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row: Icon and title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container
                      Container(
                        width: iconContainerSize,
                        height: iconContainerSize,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [Colors.white, Colors.white.withOpacity(0.8)],
                          )
                              : LinearGradient(
                            colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                          ),
                          borderRadius: BorderRadius.circular(borderRadius * 0.5),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: isSelected ? color : color.withOpacity(0.9),
                            size: iconSize,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: fontSizeTitle,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black87,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            // Value display
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: fontSizeValue,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : color,
                                  letterSpacing: -0.5,
                                  shadows: isSelected
                                      ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ]
                                      : [],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: color,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Bottom row: Subtitle and indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: fontSizeSubtitle,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Status indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 50,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isSelected ? '✓ Selected' : 'Tap',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                          textAlign: TextAlign.center,
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

  // Helper methods for responsive grid calculations
  double _getCrossAxisSpacing(double screenWidth) {
    if (screenWidth > 1200) return 20;
    if (screenWidth > 768) return 16;
    if (screenWidth > 480) return 12;
    return 8;
  }

  double _getMainAxisSpacing(double screenWidth) {
    if (screenWidth > 1200) return 20;
    if (screenWidth > 768) return 16;
    if (screenWidth > 480) return 12;
    return 8;
  }

  double _getChildAspectRatio(double screenWidth) {
    // Aspect ratio calculation based on screen width
    if (screenWidth > 1200) return 1.5; // Desktop - wider cards
    if (screenWidth > 768) return 1.4;  // Tablet
    if (screenWidth > 480) return 1.3;  // Large mobile
    return 1.2; // Small mobile - more compact
  }
  Widget _buildTabContent(ShiftReportProvider provider, int tabIndex, bool isTablet) {
    switch (tabIndex) {
      case 0:
        return _buildRevenueContent(provider, isTablet);
      case 1:
        return _buildExpensesContent(provider, isTablet);
      case 2:
        return _buildNetRevenueContent(provider, isTablet);
      case 3:
        return _buildConsultationsContent(provider, isTablet);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRevenueContent(ShiftReportProvider provider, bool isTablet) {
    SizedBox(height: 40);
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF109A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: const Color(0xFF109A8A),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Text(
                  'Total Revenue Breakdown',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Consultation Table
          _buildConsultationTable(provider, isTablet),
          SizedBox(height: isTablet ? 20 : 16),

          // Other Services Table
          _buildOtherServicesTable(provider, isTablet),
        ],
      ),
    );
  }

  Widget _buildExpensesContent(ShiftReportProvider provider, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: const Color(0xFFD97706),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Text(
                  'Expenses Breakdown',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Expenses Table
          _buildExpensesTable(provider, isTablet),
        ],
      ),
    );
  }

  Widget _buildNetRevenueContent(ShiftReportProvider provider, bool isTablet) {
    final financial = provider.financialSummary;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: const Color(0xFF10B981),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Text(
                  'Net Revenue Analysis',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // Financial Summary Cards
          _buildFinancialSummaryCard(
            'Total Revenue',
            financial.totalRevenue,
            Icons.trending_up,
            const Color(0xFF109A8A),
            isTablet: isTablet,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildFinancialSummaryCard(
            'Total Expenses',
            financial.totalExpensesWithDocShare,
            Icons.trending_down,
            const Color(0xFFD97706),
            isTablet: isTablet,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildFinancialSummaryCard(
            'Net Revenue',
            financial.netHospitalRevenue,
            Icons.account_balance,
            const Color(0xFF10B981),
            isTablet: isTablet,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationsContent(ShiftReportProvider provider, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: const Color(0xFF14B8A6),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Text(
                  'Consultations by Doctor',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Consultation Table
          _buildConsultationTable(provider, isTablet),
        ],
      ),
    );
  }

  Widget _buildConsultationTable(ShiftReportProvider provider, bool isTablet) {
    final consultations = provider.consultationSummaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description,
              color: const Color(0xFF109A8A),
              size: isTablet ? 18 : 14,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              'Consultation (Doctors)',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        if (consultations.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 30 : 20),
              child: Text(
                'No consultation data available',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: isTablet ? 24 : 20,
              headingRowHeight: isTablet ? 48 : 40,
              dataRowHeight: isTablet ? 48 : 40,
              columns: [
                DataColumn(
                  label: Text(
                    'Doctor Name',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Service Amount',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Dr. Share',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Hospital Received',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: [
                ...consultations.map((consultation) {
                  return DataRow(cells: [
                    DataCell(
                      Text(
                        consultation.doctorName,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(consultation.totalAmount),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(consultation.drShare),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(consultation.hospitalShare),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]);
                }),
                // Total row
                DataRow(
                  color: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                  cells: [
                    DataCell(
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.totalAmount)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.drShare)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.hospitalShare)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOtherServicesTable(ShiftReportProvider provider, bool isTablet) {
    final services = provider.serviceSummaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description,
              color: const Color(0xFF109A8A),
              size: isTablet ? 18 : 14,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              'Other Services',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        if (services.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 30 : 20),
              child: Text(
                'No other services data available',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: isTablet ? 24 : 20,
              headingRowHeight: isTablet ? 48 : 40,
              dataRowHeight: isTablet ? 48 : 40,
              columns: [
                DataColumn(
                  label: Text(
                    'Service Name',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Dr. Share',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Hospital Received',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: [
                ...services.map((service) {
                  return DataRow(cells: [
                    DataCell(
                      Text(
                        service.serviceName,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(service.totalAmount),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(service.drShare),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(service.hospitalShare),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]);
                }),
                // Total row
                DataRow(
                  color: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                  cells: [
                    DataCell(
                      Text(
                        'Total Services',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(services.fold(0.0, (sum, s) => sum + s.totalAmount)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(services.fold(0.0, (sum, s) => sum + s.drShare)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(services.fold(0.0, (sum, s) => sum + s.hospitalShare)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpensesTable(ShiftReportProvider provider, bool isTablet) {
    final expenses = provider.expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_cart,
              color: const Color(0xFFD97706),
              size: isTablet ? 18 : 14,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              'Expenses',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        if (expenses.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 30 : 20),
              child: Text(
                'No expenses data available',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: isTablet ? 24 : 20,
              headingRowHeight: isTablet ? 48 : 40,
              dataRowHeight: isTablet ? 48 : 40,
              columns: [
                DataColumn(
                  label: Text(
                    'Expense Head',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: [
                ...expenses.map((expense) {
                  return DataRow(cells: [
                    DataCell(
                      Text(
                        expense.expenseHead ?? '-',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        expense.expenseDescription ?? '-',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatAmount(expense.expenseAmount),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ),
                  ]);
                }),
                // Total row
                DataRow(
                  color: MaterialStateProperty.all(const Color(0xFFFFFBEB)),
                  cells: [
                    DataCell(
                      Text(
                        'Total Expenses',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const DataCell(Text('')),
                    DataCell(
                      Text(
                        _formatAmount(expenses.fold(0.0, (sum, e) => sum + e.expenseAmount)),
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard(
      String title,
      double amount,
      IconData icon,
      Color color, {
        bool isHighlight = false,
        required bool isTablet,
      }) {
    // Use MediaQuery for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: isHighlight ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isLargeScreen ? 24 : 20,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 6 : 4),
                Text(
                  'Rs ${_formatAmount(amount)}',
                  style: TextStyle(
                    fontSize: isHighlight
                        ? (isLargeScreen ? 26 : 22)
                        : (isLargeScreen ? 22 : 18),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _selectDate(BuildContext context, ShiftReportProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF109A8A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
      if (widget.onDateChanged != null) {
        widget.onDateChanged!(picked);
      }
      provider.fetchAvailableShifts().then((_) {
        provider.fetchData();
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF109A8A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
      firstDate: _selectedStartDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF109A8A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedFilterType = FilterType.daily;
      _selectedYear = DateTime.now().year;
      _selectedMonth = DateTime.now().month;
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedTabIndex = -1;
    });
  }

  Future<void> _refreshData(
      ShiftReportProvider provider,
      EnhancedShiftReportProvider? enhancedProvider
      ) async {
    if (_selectedFilterType == FilterType.daily) {
      await provider.refresh();
    } else {
      if (enhancedProvider != null) {
        // Update enhanced provider filters
        enhancedProvider.setSelectedYear(_selectedYear);
        enhancedProvider.setSelectedMonth(_selectedMonth);
        enhancedProvider.setSelectedStartDate(_selectedStartDate);
        enhancedProvider.setSelectedEndDate(_selectedEndDate);
        enhancedProvider.setSelectedFilterType(_selectedFilterType);

        // Fetch data based on filter type
        switch (_selectedFilterType) {
          case FilterType.monthly:
            await enhancedProvider.fetchMonthlyReport();
            break;
          case FilterType.dateRange:
            if (_selectedStartDate != null && _selectedEndDate != null) {
              await enhancedProvider.fetchDateRangeReport();
            }
            break;
          case FilterType.yearly:
            await enhancedProvider.fetchYearlySummary();
            break;
          case FilterType.daily:
          // Already handled above
            break;
        }
      }
    }
  }
}