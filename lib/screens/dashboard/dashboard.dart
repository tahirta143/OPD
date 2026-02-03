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
import 'package:provider/provider.dart';
// import '../../custum widgets/shift_report/shift_report_widget.dart';

class AttractiveHealthDashboard extends StatefulWidget {
  const AttractiveHealthDashboard({super.key});

  @override
  State<AttractiveHealthDashboard> createState() => _AttractiveHealthDashboardState();
}

class _AttractiveHealthDashboardState extends State<AttractiveHealthDashboard> {
  int _currentIndex = 0;
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
    final shiftProvider = Provider.of<ShiftReportProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    print('$department tapped');
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
                            colors: [Color(0xFF037389), Color(0xFF14B8A6)],
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
                                    Icon(Icons.description, color: Colors.white),
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
                              icon: const Icon(Icons.close, color: Colors.white),
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