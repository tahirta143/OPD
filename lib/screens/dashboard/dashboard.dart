import 'package:flutter/material.dart';
import '../../custum widgets/activity_todays/activity_sleep.dart';
import '../../custum widgets/bottom_navigation/bottom_navigation.dart';
import '../../custum widgets/custom_app_bar/custom_app_bar.dart';
import '../../custum widgets/metric_cards/metric_cards.dart';
import '../../custum widgets/opd_cards/opd_cards.dart';
import '../../custum widgets/opd_cards_content/opd_content/opd_content.dart';
import '../../provider/shift_provider/shift_provider.dart';
import 'package:provider/provider.dart';

class AttractiveHealthDashboard extends StatefulWidget {
  const AttractiveHealthDashboard({super.key});

  @override
  State<AttractiveHealthDashboard> createState() =>
      _AttractiveHealthDashboardState();
}

class _AttractiveHealthDashboardState extends State<AttractiveHealthDashboard> {
  int _currentIndex = 0;
  bool _showOPDContent = false;
  String? _selectedOPDCard;
  DateTime _selectedDate = DateTime.now();
  // Add this ScrollController
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    final shiftProvider = Provider.of<ShiftReportProvider>(context);

    return Scaffold(

      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(),
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                children: [
                  // OPD Cards
                  OPDCards(
                    showOPDContent: _showOPDContent,
                    selectedOPDCard: _selectedOPDCard,
                    onOPDCardTap: (department) {
                      setState(() {
                        _showOPDContent = true;
                        _selectedOPDCard = department.toLowerCase();
                      });
                    },
                    onOPDTap: () {
                      setState(() {
                        _showOPDContent = true;
                        _selectedOPDCard = 'opd';
                      });
                    },
                  ),

                  SizedBox(height: isTablet ? 24 : 16),

                  // Show Shift Report Widget when OPD is selected
                  if (_showOPDContent && _selectedOPDCard == 'opd')
                    Column(
                      children: [
                        // Close Button for OPD Content
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF109A8A), Color(0xFF109A8A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'OPD Shift Report',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Shift-based financial summary',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showOPDContent = false;
                                    _selectedOPDCard = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                tooltip: 'Close OPD Report',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),

                        // Shift Report Widget
                        ShiftReportWidget(
                          onClose: () {
                            setState(() {
                              _showOPDContent = false;
                              _selectedOPDCard = null;
                            });
                          },
                          onDateChanged: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                            shiftProvider.setSelectedDate(date);
                          },
                        ),
                      ],
                    ),

                  // Show normal dashboard when no OPD content is shown
                  if (!_showOPDContent) ...[
                    MetricCards(isTablet: isTablet),
                    SizedBox(height: 10),

                    // Heart Rate Graph - Line Chart
                    // Monthly Expenses Chart
                    // Monthly Revenue with PKR - Line Chart
                    FlChartGraphWidget(
                      title: 'Monthly Revenue',
                      subtitle: '2024 Revenue growth',
                      value: '1.2L', // Value for the header
                      valueColor: Color(0xFF10B981),
                      chartType: ChartType.line,
                      data: [
                        ChartData('Jan', 85000),
                        ChartData('Feb', 92000),
                        ChartData('Mar', 78000),
                        ChartData('Apr', 115000),
                        ChartData('May', 105000),
                        ChartData('Jun', 98000),
                        ChartData('Jul', 132000),
                        ChartData('Aug', 95000),
                        ChartData('Sep', 118000),
                        ChartData('Oct', 126000),
                        ChartData('Nov', 102000),
                        ChartData('Dec', 145000),
                      ],
                      isTablet: isTablet,
                      showLegend: false,
                      isMonthly: true,
                      showPKR: true, // Enable PKR formatting
                    ),
                    SizedBox(height: 20,),
                    FlChartGraphWidget(
                      title: 'Monthly Profit',
                      subtitle: 'Revenue - Expenses',
                      value: '75,180',
                      valueColor: Color(0xFF109A8A), // Your teal color
                      chartType: ChartType.bar,
                      data: [
                        ChartData('Jan', 40000),
                        ChartData('Feb', 40000),
                        ChartData('Mar', 40000),
                        ChartData('Apr', 53000),
                        ChartData('May', 50000),
                        ChartData('Jun', 50000),
                        ChartData('Jul', 61000),
                        ChartData('Aug', 52000),
                        ChartData('Sep', 59000),
                        ChartData('Oct', 60000),
                        ChartData('Nov', 50000),
                        ChartData('Dec', 70000),
                      ],
                      isTablet: isTablet,
                      showLegend: false,
                      isMonthly: true,
                      showPKR: true,
                    ),
                    SizedBox(height: 20,),
// Monthly Expenses with PKR - Bar Chart
                    FlChartGraphWidget(
                      title: 'Monthly Expenses',
                      subtitle: '2024 Expense trends',
                      value: '45,820',
                      valueColor: Color(0xFFEF4444),
                      chartType: ChartType.line,
                      data: [
                        ChartData('Jan', 45000),
                        ChartData('Feb', 52000),
                        ChartData('Mar', 38000),
                        ChartData('Apr', 62000),
                        ChartData('May', 55000),
                        ChartData('Jun', 48000),
                        ChartData('Jul', 71000),
                        ChartData('Aug', 43000),
                        ChartData('Sep', 59000),
                        ChartData('Oct', 66000),
                        ChartData('Nov', 52000),
                        ChartData('Dec', 75000),
                      ],
                      isTablet: isTablet,
                      showLegend: false,
                      isMonthly: true,
                      showPKR: true,
                    ),

// Profit Analysis with PKR - Bar Chart

                    SizedBox(height: isTablet ? 24 : 16),
                    // HealthInsights(isTablet: isTablet),
                    // SizedBox(height: isTablet ? 24 : 16),
                    // QuickStats(isTablet: isTablet),
                  ],
                  // SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: TealBottomNavigation(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Pass the scroll controller to enable hide-on-scroll
        scrollController: _scrollController,
        hideOnScroll: true, // Enable hide on scroll
      ),
      extendBody: true,
    );
  }
}
