import 'package:flutter/material.dart';
import '../../custum widgets/activity_todays/activity_sleep.dart';
import '../../custum widgets/bottom_navigation/bottom_navigation.dart';
import '../../custum widgets/custom_app_bar/custom_app_bar.dart';
import '../../custum widgets/health_insights/health_insights.dart';
import '../../custum widgets/metric_cards/metric_cards.dart';
import '../../custum widgets/opd_cards/opd_cards.dart';
import '../../custum widgets/opd_cards_content/opd_content/opd_content.dart';
import '../../custum widgets/quick_stats/quick_stats.dart';
import '../../provider/shift_provider/shift_provider.dart';
import 'package:provider/provider.dart'; // Add this import

class AttractiveHealthDashboard extends StatefulWidget {
  const AttractiveHealthDashboard({super.key});

  @override
  State<AttractiveHealthDashboard> createState() => _AttractiveHealthDashboardState();
}

class _AttractiveHealthDashboardState extends State<AttractiveHealthDashboard> {
  int _currentIndex = 0;
  int _opdContentIndex = -1;
  bool _showOPDContent = false;
  String? _selectedOPDCard;
  DateTime _selectedDate = DateTime.now();
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedTimeFilter = 'All';
  String _selectedShift = 'All';
  final List<String> _shifts = ['All', 'Morning', 'Evening', 'Night'];
  final List<String> _timeFilters = ['All', 'Week', 'Month'];

  final List<Map<String, dynamic>> _consultantsData = [
    {
      'name': 'Dr. Sharma',
      'specialization': 'Cardiology',
      'morning': 4500,
      'evening': 5000,
      'night': 5500,
      'color': Color(0xFFEF4444),
    },
    {
      'name': 'Dr. Patel',
      'specialization': 'Orthopedics',
      'morning': 3500,
      'evening': 4000,
      'night': 4500,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Dr. Gupta',
      'specialization': 'Pediatrics',
      'morning': 3000,
      'evening': 3500,
      'night': 4000,
      'color': Color(0xFF10B981),
    },
    {
      'name': 'Dr. Kumar',
      'specialization': 'Neurology',
      'morning': 5000,
      'evening': 5500,
      'night': 6000,
      'color': Color(0xFF3B82F6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    final shiftProvider = Provider.of<ShiftProvider>(context); // Get the provider

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(isTablet: isTablet),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              children: [
                // OPD Cards
                OPDCards(
                  // isTablet: isTablet,
                  showOPDContent: _showOPDContent,
                  selectedOPDCard: _selectedOPDCard,
                  onOPDCardTap: (title) {
                    print('$title tapped');
                  },
                  onOPDTap: () {
                    setState(() {
                      _showOPDContent = true;
                      _selectedOPDCard = 'opd';
                      _opdContentIndex = -1;
                    });
                  },
                ),

                SizedBox(height: isTablet ? 24 : 16),

              // Add these variables to your state class


// Update your OPDTabsWithContent widget call with the new parameters:
              if (_showOPDContent && _selectedOPDCard == 'opd')
          OPDTabsWithContent(
          isTablet: isTablet,
          fromDate: _fromDate, // Use your state variable
          toDate: _toDate, // Use your state variable
          opdContentIndex: _opdContentIndex,
          selectedDate: _selectedDate,
          selectedShift: _selectedShift,
          selectedTimeFilter: _selectedTimeFilter,
          shifts: _shifts,
          timeFilters: _timeFilters,
          onTabSelected: (index) {
            setState(() {
              _opdContentIndex = index;
            });
          },
          onClose: () {
            setState(() {
              _showOPDContent = false;
              _selectedOPDCard = null;
              _opdContentIndex = -1;
              // Optionally clear date range when closing
              _fromDate = null;
              _toDate = null;
            });
          },
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
            shiftProvider.setSelectedDate(date); // Update provider
          },
          onShiftChanged: (shift) {
            setState(() {
              _selectedShift = shift;
            });
            shiftProvider.setSelectedShift(shift); // Update provider
          },
          onTimeFilterChanged: (filter) {
            setState(() {
              _selectedTimeFilter = filter;
            });
            shiftProvider.setSelectedTimeFilter(filter); // Update provider
          },
          onFromDateChanged: (date) {
            setState(() {
              _fromDate = date;
            });
            // You might want to add provider update here if needed
            // shiftProvider.setFromDate(date);
          },
          onToDateChanged: (date) {
            setState(() {
              _toDate = date;
            });
            // You might want to add provider update here if needed
            // shiftProvider.setToDate(date);
          },
          consultantsData: _consultantsData,
          shiftProvider: shiftProvider,
        ),

// If not showing OPD content, show the rest of the dashboard
          if (!_showOPDContent) ...[
        MetricCards(isTablet: isTablet),
    SizedBox(height: isTablet ? 24 : 16),
    ActivitySleepSection(isTablet: isTablet),
    SizedBox(height: isTablet ? 24 : 16),
    HealthInsights(isTablet: isTablet),
    SizedBox(height: isTablet ? 24 : 16),
    QuickStats(isTablet: isTablet),
    ],
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        isTablet: isTablet,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}