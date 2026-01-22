// // attractive_health_dashboard.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class AttractiveHealthDashboard extends StatefulWidget {
//   const AttractiveHealthDashboard({super.key});
//
//   @override
//   State<AttractiveHealthDashboard> createState() => _AttractiveHealthDashboardState();
// }
//
// class _AttractiveHealthDashboardState extends State<AttractiveHealthDashboard> {
//   int _currentIndex = 0;
//
//   // OPD Navigation State
//   int _opdContentIndex = -1; // -1 means no OPD content selected
//   bool _showOPDContent = false;
//   String? _selectedOPDCard;
//
//   // Filter State
//   DateTime _selectedDate = DateTime.now();
//   String _selectedShift = 'Morning';
//   final List<String> _shifts = ['Morning', 'Evening', 'Night'];
//
//   // Sample Data
//   final List<Map<String, dynamic>> _consultantsData = [
//     {
//       'name': 'Dr. Sharma',
//       'specialization': 'Cardiology',
//       'morning': 4500,
//       'evening': 5000,
//       'night': 5500,
//       'color': Color(0xFFEF4444),
//     },
//     {
//       'name': 'Dr. Patel',
//       'specialization': 'Orthopedics',
//       'morning': 3500,
//       'evening': 4000,
//       'night': 4500,
//       'color': Color(0xFFF59E0B),
//     },
//     {
//       'name': 'Dr. Gupta',
//       'specialization': 'Pediatrics',
//       'morning': 3000,
//       'evening': 3500,
//       'night': 4000,
//       'color': Color(0xFF10B981),
//     },
//     {
//       'name': 'Dr. Kumar',
//       'specialization': 'Neurology',
//       'morning': 5000,
//       'evening': 5500,
//       'night': 6000,
//       'color': Color(0xFF3B82F6),
//     },
//   ];
//
//   // Vibrant and Attractive Color Scheme
//   final Color _primaryColor = const Color(0xFF6366F1); // Vibrant Indigo
//   final Color _secondaryColor = const Color(0xFF8B5CF6); // Purple
//   final Color _accentColor = const Color(0xFFEC4899); // Pink
//   final Color _successColor = const Color(0xFF10B981); // Emerald
//   final Color _warningColor = const Color(0xFFF59E0B); // Amber
//   final Color _dangerColor = const Color(0xFFEF4444); // Red
//   final Color _infoColor = const Color(0xFF3B82F6); // Blue
//   final Color _tealColor = const Color(0xFF14B8A6); // Teal
//   final Color _bgColor = const Color(0xFFF8FAFC);
//   final Color _cardColor = const Color(0xFFFFFFFF);
//   final Color _textPrimary = const Color(0xFF1E293B);
//   final Color _textSecondary = const Color(0xFF64748B);
//   final Color _lightIndigo = const Color(0xFFE0E7FF);
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 768;
//
//     return Scaffold(
//       backgroundColor: _bgColor,
//       appBar: _buildCustomAppBar(isTablet),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.all(isTablet ? 24 : 16),
//             child: Column(
//               children: [
//                 // Health Score Card
//                 _buildHealthScoreCard(isTablet),
//
//                 SizedBox(height: isTablet ? 24 : 16),
//
//                 // If OPD content is showing, show OPD summary cards
//                 if (_showOPDContent && _selectedOPDCard == 'opd')
//                   _buildOPDSummaryCards(isTablet),
//
//                 // Show OPD content based on selection
//                 if (_showOPDContent && _selectedOPDCard != null)
//                   _buildOPDContentSection(isTablet),
//
//                 // If not showing OPD content, show the rest of the dashboard
//                 if (!_showOPDContent) ...[
//                   // Health Metrics Grid
//                   _buildHealthMetricsGrid(isTablet),
//
//                   SizedBox(height: isTablet ? 24 : 16),
//
//                   // Activity & Sleep Section
//                   _buildActivitySleepSection(isTablet),
//
//                   SizedBox(height: isTablet ? 24 : 16),
//
//                   // Health Insights
//                   _buildHealthInsights(isTablet),
//
//                   SizedBox(height: isTablet ? 24 : 16),
//
//                   // Quick Stats
//                   _buildQuickStats(isTablet),
//                 ],
//
//                 SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(isTablet),
//     );
//   }
//
//   // OPD Summary Cards (Names, Consultants, OPD, IPD, Laboratory)
//   Widget _buildOPDSummaryCards(bool isTablet) {
//     final summaryCards = [
//       {
//         'title': 'Names',
//         'icon': Icons.group,
//         'bgColor': _lightIndigo,
//         'iconColor': _infoColor,
//         'contentType': 'names',
//       },
//       {
//         'title': 'Consultants',
//         'icon': Icons.medical_services,
//         'bgColor': const Color(0xFFFCE7F3),
//         'iconColor': _accentColor,
//         'contentType': 'consultants',
//       },
//       {
//         'title': 'OPD',
//         'icon': Icons.local_hospital,
//         'bgColor': const Color(0xFFCCFBF1),
//         'iconColor': _successColor,
//         'contentType': 'opd',
//       },
//       {
//         'title': 'IPD',
//         'icon': Icons.night_shelter,
//         'bgColor': _lightIndigo,
//         'iconColor': _warningColor,
//         'contentType': 'ipd',
//       },
//       {
//         'title': 'Laboratory',
//         'icon': Icons.science,
//         'bgColor': const Color(0xFFFCE7F3),
//         'iconColor': _dangerColor,
//         'contentType': 'laboratory',
//       },
//     ];
//
//     return Column(
//       children: [
//         // Header with Filter
//         Padding(
//           padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'OPD Summary',
//                     style: TextStyle(
//                       fontSize: isTablet ? 22 : 18,
//                       fontWeight: FontWeight.w700,
//                       color: _textPrimary,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       setState(() {
//                         _showOPDContent = false;
//                         _selectedOPDCard = null;
//                         _opdContentIndex = -1;
//                       });
//                     },
//                     icon: Icon(Icons.close, color: _textSecondary),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: isTablet ? 16 : 12),
//
//               // Filter Row
//               _buildFilterRow(isTablet),
//             ],
//           ),
//         ),
//
//         // Summary Cards Grid
//         GridView.builder(
//           physics: const NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: isTablet ? 5 : 3,
//             crossAxisSpacing: isTablet ? 16 : 12,
//             mainAxisSpacing: isTablet ? 16 : 12,
//             childAspectRatio: 1.0,
//           ),
//           itemCount: summaryCards.length,
//           itemBuilder: (context, index) {
//             return _buildOPDSummaryCard(
//               title: summaryCards[index]['title'] as String,
//               icon: summaryCards[index]['icon'] as IconData,
//               bgColor: summaryCards[index]['bgColor'] as Color,
//               iconColor: summaryCards[index]['iconColor'] as Color,
//               contentType: summaryCards[index]['contentType'] as String,
//               isTablet: isTablet,
//             );
//           },
//         ),
//
//         SizedBox(height: isTablet ? 24 : 16),
//       ],
//     );
//   }
//
//   // Filter Row Widget
//   Widget _buildFilterRow(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 16 : 12),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             spreadRadius: 1,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Filter Results',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: _textPrimary,
//             ),
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               // Date Filter
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Select Date',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: _textSecondary,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: _bgColor,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: _lightIndigo),
//                       ),
//                       child: Material(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(12),
//                         child: InkWell(
//                           onTap: () => _selectDate(context),
//                           borderRadius: BorderRadius.circular(12),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.calendar_today,
//                                   size: 18,
//                                   color: _primaryColor,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _formatDate(_selectedDate),
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: _textPrimary,
//                                     ),
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.arrow_drop_down,
//                                   color: _textSecondary,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(width: isTablet ? 20 : 12),
//
//               // Shift Filter
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Select Shift',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: _textSecondary,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: _bgColor,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: _lightIndigo),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _selectedShift,
//                             isExpanded: true,
//                             icon: Icon(Icons.arrow_drop_down, color: _textSecondary),
//                             items: _shifts.map((String shift) {
//                               return DropdownMenuItem<String>(
//                                 value: shift,
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       _getShiftIcon(shift),
//                                       size: 18,
//                                       color: _getShiftColor(shift),
//                                     ),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       shift,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: _textPrimary,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 _selectedShift = newValue!;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(width: isTablet ? 20 : 12),
//
//               // Apply Filter Button
//               if (isTablet)
//                 Container(
//                   margin: const EdgeInsets.only(top: 20),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Filter logic here
//                       setState(() {});
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.filter_alt, size: 18),
//                         SizedBox(width: 8),
//                         Text('Apply'),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//
//           // Apply Filter Button for mobile
//           if (!isTablet)
//             Padding(
//               padding: const EdgeInsets.only(top: 16),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Filter logic here
//                     setState(() {});
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _primaryColor,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.filter_alt, size: 18),
//                       SizedBox(width: 8),
//                       Text('Apply Filter'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // Helper methods for filters
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             primaryColor: _primaryColor,
//             colorScheme: ColorScheme.light(primary: _primaryColor),
//             buttonTheme: const ButtonThemeData(
//               textTheme: ButtonTextTheme.primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   IconData _getShiftIcon(String shift) {
//     switch (shift) {
//       case 'Morning':
//         return Icons.wb_sunny;
//       case 'Evening':
//         return Icons.nights_stay;
//       case 'Night':
//         return Icons.nightlight;
//       default:
//         return Icons.access_time;
//     }
//   }
//
//   Color _getShiftColor(String shift) {
//     switch (shift) {
//       case 'Morning':
//         return _warningColor;
//       case 'Evening':
//         return _primaryColor;
//       case 'Night':
//         return _infoColor;
//       default:
//         return _textPrimary;
//     }
//   }
//
//   Widget _buildOPDSummaryCard({
//     required String title,
//     required IconData icon,
//     required Color bgColor,
//     required Color iconColor,
//     required String contentType,
//     required bool isTablet,
//   }) {
//     final isSelected = _opdContentIndex != -1 &&
//         _getContentTypeForIndex(_opdContentIndex) == contentType;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: isSelected ? iconColor.withOpacity(0.1) : bgColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 12,
//             spreadRadius: 1,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: isSelected ? Border.all(color: iconColor, width: 2) : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           onTap: () {
//             setState(() {
//               _opdContentIndex = _getIndexForContentType(contentType);
//             });
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             padding: EdgeInsets.all(isTablet ? 16 : 12),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Icon
//                 Container(
//                   width: isTablet ? 48 : 40,
//                   height: isTablet ? 48 : 40,
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: isTablet ? 24 : 20,
//                     color: iconColor,
//                   ),
//                 ),
//
//                 SizedBox(height: isTablet ? 12 : 8),
//
//                 // Title
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: isTablet ? 14 : 12,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected ? iconColor : _textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // OPD Content Section
//   Widget _buildOPDContentSection(bool isTablet) {
//     switch (_opdContentIndex) {
//       case 0: // Names
//         return _buildNamesContent(isTablet);
//       case 1: // Consultants
//         return _buildConsultantsContent(isTablet);
//       case 2: // OPD
//         return _buildOPDDetailsContent(isTablet);
//       case 3: // IPD
//         return _buildIPDContent(isTablet);
//       case 4: // Laboratory
//         return _buildLaboratoryContent(isTablet);
//       default:
//         return Container();
//     }
//   }
//
//   // Names Content
//   Widget _buildNamesContent(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Patient Names - ${_formatDate(_selectedDate)} ($_selectedShift)',
//             style: TextStyle(
//               fontSize: isTablet ? 20 : 18,
//               fontWeight: FontWeight.w700,
//               color: _textPrimary,
//             ),
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           // Stats Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStatCard(
//                 'Total Patients',
//                 '${_calculateTotalPatients()}',
//                 Icons.group,
//                 _infoColor,
//                 isTablet,
//               ),
//               _buildStatCard(
//                 'New Today',
//                 '${_calculateNewPatients()}',
//                 Icons.today,
//                 _successColor,
//                 isTablet,
//               ),
//               _buildStatCard(
//                 'Appointments',
//                 '${_calculateAppointments()}',
//                 Icons.event_available,
//                 _warningColor,
//                 isTablet,
//               ),
//             ],
//           ),
//
//           SizedBox(height: isTablet ? 24 : 16),
//
//           // Recent Patients
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Recent Patients',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimary,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _lightIndigo,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.access_time, size: 14, color: _primaryColor),
//                         SizedBox(width: 4),
//                         Text(
//                           _selectedShift,
//                           style: TextStyle(
//                             color: _primaryColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               ...List.generate(_calculatePatientCount(), (index) => _buildPatientItem(isTablet, index)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Consultants Content
//   Widget _buildConsultantsContent(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Consultants - ${_formatDate(_selectedDate)} ($_selectedShift)',
//             style: TextStyle(
//               fontSize: isTablet ? 20 : 18,
//               fontWeight: FontWeight.w700,
//               color: _textPrimary,
//             ),
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           // Stats Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStatCard(
//                 'Total Consultants',
//                 '${_consultantsData.length}',
//                 Icons.medical_services,
//                 _accentColor,
//                 isTablet,
//               ),
//               _buildStatCard(
//                 'Available',
//                 '${_calculateAvailableConsultants()}',
//                 Icons.check_circle,
//                 _successColor,
//                 isTablet,
//               ),
//               _buildStatCard(
//                 'On Leave',
//                 '${_calculateLeaveConsultants()}',
//                 Icons.beach_access,
//                 _warningColor,
//                 isTablet,
//               ),
//             ],
//           ),
//
//           SizedBox(height: isTablet ? 24 : 16),
//
//           // Earnings Summary
//           Container(
//             padding: EdgeInsets.all(isTablet ? 20 : 16),
//             decoration: BoxDecoration(
//               color: _lightIndigo.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Earnings Summary',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: _textPrimary,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: _getShiftColor(_selectedShift).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(_getShiftIcon(_selectedShift), size: 14, color: _getShiftColor(_selectedShift)),
//                           SizedBox(width: 4),
//                           Text(
//                             _selectedShift,
//                             style: TextStyle(
//                               color: _getShiftColor(_selectedShift),
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Today\'s Collection',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _textSecondary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '₹ ${_calculateShiftEarnings()}',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color: _successColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Avg. Per Patient',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _textSecondary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '₹ ${_calculateAverageEarnings()}',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                             color: _primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: isTablet ? 24 : 16),
//
//           // Top Consultants
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Consultant Schedule',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: _textPrimary,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Showing consultants available in $_selectedShift shift',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: _textSecondary,
//                 ),
//               ),
//               SizedBox(height: 12),
//               ...List.generate(_consultantsData.length, (index) => _buildConsultantItem(isTablet, index)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // OPD Details Content
//   Widget _buildOPDDetailsContent(bool isTablet) {
//     final filteredDoctors = _consultantsData.where((doctor) {
//       // In real app, you would filter based on actual availability data
//       return true; // Show all for demo
//     }).toList();
//
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'OPD Details - ${_formatDate(_selectedDate)}',
//                 style: TextStyle(
//                   fontSize: isTablet ? 20 : 18,
//                   fontWeight: FontWeight.w700,
//                   color: _textPrimary,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _getShiftColor(_selectedShift).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(_getShiftIcon(_selectedShift), size: 14, color: _getShiftColor(_selectedShift)),
//                     SizedBox(width: 4),
//                     Text(
//                       _selectedShift,
//                       style: TextStyle(
//                         color: _getShiftColor(_selectedShift),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           // Doctor Schedule Grid
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isTablet ? 2 : 1,
//               crossAxisSpacing: isTablet ? 16 : 12,
//               mainAxisSpacing: isTablet ? 16 : 12,
//               childAspectRatio: isTablet ? 3 : 2.5,
//             ),
//             itemCount: filteredDoctors.length,
//             itemBuilder: (context, index) {
//               return _buildDoctorCard(filteredDoctors[index], isTablet);
//             },
//           ),
//
//           SizedBox(height: isTablet ? 24 : 16),
//
//           // OPD Statistics
//           Container(
//             padding: EdgeInsets.all(isTablet ? 20 : 16),
//             decoration: BoxDecoration(
//               color: _lightIndigo.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'OPD Statistics for $_selectedShift',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Patients Today',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _textSecondary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(Icons.people, size: 16, color: _primaryColor),
//                             SizedBox(width: 8),
//                             Text(
//                               '${_calculatePatientsForShift()}',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w700,
//                                 color: _textPrimary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Shift Collection',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _textSecondary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '₹ ${_calculateShiftCollection()}',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             color: _successColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Consultation Fee',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _textSecondary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '₹ ${_getShiftFee()}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: _warningColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Avg. Waiting Time',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _textSecondary,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '${_getWaitingTime()} min',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: _infoColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // IPD Content
//   Widget _buildIPDContent(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'IPD - ${_formatDate(_selectedDate)} ($_selectedShift)',
//             style: TextStyle(
//               fontSize: isTablet ? 20 : 18,
//               fontWeight: FontWeight.w700,
//               color: _textPrimary,
//             ),
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           // IPD Stats Grid
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isTablet ? 3 : 2,
//               crossAxisSpacing: isTablet ? 16 : 12,
//               mainAxisSpacing: isTablet ? 16 : 12,
//               childAspectRatio: 1.2,
//             ),
//             itemCount: 6,
//             itemBuilder: (context, index) {
//               final stats = [
//                 {'label': 'Occupied Beds', 'value': '${_calculateOccupiedBeds()}', 'color': _warningColor},
//                 {'label': 'Available Beds', 'value': '${_calculateAvailableBeds()}', 'color': _successColor},
//                 {'label': 'Total Beds', 'value': '100', 'color': _infoColor},
//                 {'label': 'ICU Patients', 'value': '${_calculateICUPatients()}', 'color': _dangerColor},
//                 {'label': 'Discharge Today', 'value': '${_calculateDischarges()}', 'color': _tealColor},
//                 {'label': 'Admissions', 'value': '${_calculateAdmissions()}', 'color': _primaryColor},
//               ];
//               return _buildIPDStatCard(stats[index], isTablet);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Laboratory Content
//   Widget _buildLaboratoryContent(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Laboratory - ${_formatDate(_selectedDate)} ($_selectedShift)',
//             style: TextStyle(
//               fontSize: isTablet ? 20 : 18,
//               fontWeight: FontWeight.w700,
//               color: _textPrimary,
//             ),
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           // Lab Stats
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStatCard(
//                 'Tests Today',
//                 '${_calculateTestsToday()}',
//                 Icons.science,
//                 _dangerColor,
//                 isTablet,
//               ),
//               _buildStatCard(
//                 'Pending',
//                 '${_calculatePendingTests()}',
//                 Icons.pending,
//                 _warningColor,
//                 isTablet,
//               ),
//               _buildStatCard(
//                 'Completed',
//                 '${_calculateCompletedTests()}',
//                 Icons.check_circle,
//                 _successColor,
//                 isTablet,
//               ),
//             ],
//           ),
//
//           SizedBox(height: isTablet ? 24 : 16),
//
//           // Test Categories
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Test Categories',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimary,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _lightIndigo,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _selectedShift,
//                       style: TextStyle(
//                         color: _primaryColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               ...List.generate(4, (index) => _buildTestCategoryItem(isTablet, index)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Data calculation methods
//   int _calculateTotalPatients() {
//     return 120 + (_selectedDate.day % 30);
//   }
//
//   int _calculateNewPatients() {
//     return 15 + (_selectedDate.day % 10);
//   }
//
//   int _calculateAppointments() {
//     return 85 + (_selectedDate.day % 15);
//   }
//
//   int _calculatePatientCount() {
//     return 3 + (_selectedDate.day % 4);
//   }
//
//   int _calculateAvailableConsultants() {
//     return _consultantsData.length - _calculateLeaveConsultants();
//   }
//
//   int _calculateLeaveConsultants() {
//     return _selectedDate.weekday == 6 || _selectedDate.weekday == 7 ? 2 : 1;
//   }
//
//   String _calculateShiftEarnings() {
//     int base = 125450;
//     int shiftMultiplier = _selectedShift == 'Morning' ? 1 :
//     _selectedShift == 'Evening' ? 2 : 3;
//     int dateMultiplier = _selectedDate.day % 10;
//     return (base + (shiftMultiplier * 5000) + (dateMultiplier * 1000)).toString();
//   }
//
//   String _calculateAverageEarnings() {
//     return (int.parse(_calculateShiftEarnings()) ~/ _calculatePatientsForShift()).toString();
//   }
//
//   int _calculatePatientsForShift() {
//     return 142 + (_selectedDate.day % 20) + (_shifts.indexOf(_selectedShift) * 10);
//   }
//
//   String _calculateShiftCollection() {
//     int patients = _calculatePatientsForShift();
//     int avgFee = _getShiftFeeNumber();
//     return (patients * avgFee).toString();
//   }
//
//   int _getShiftFeeNumber() {
//     switch (_selectedShift) {
//       case 'Morning':
//         return 4500;
//       case 'Evening':
//         return 5000;
//       case 'Night':
//         return 5500;
//       default:
//         return 4500;
//     }
//   }
//
//   String _getShiftFee() {
//     return _getShiftFeeNumber().toString();
//   }
//
//   String _getWaitingTime() {
//     switch (_selectedShift) {
//       case 'Morning':
//         return '30';
//       case 'Evening':
//         return '45';
//       case 'Night':
//         return '20';
//       default:
//         return '30';
//     }
//   }
//
//   int _calculateOccupiedBeds() {
//     return 85 + (_selectedDate.day % 15);
//   }
//
//   int _calculateAvailableBeds() {
//     return 100 - _calculateOccupiedBeds();
//   }
//
//   int _calculateICUPatients() {
//     return 12 + (_selectedDate.day % 5);
//   }
//
//   int _calculateDischarges() {
//     return 8 + (_selectedDate.day % 4);
//   }
//
//   int _calculateAdmissions() {
//     return 10 + (_selectedDate.day % 6);
//   }
//
//   int _calculateTestsToday() {
//     return 56 + (_selectedDate.day % 20);
//   }
//
//   int _calculatePendingTests() {
//     return 12 + (_selectedDate.day % 8);
//   }
//
//   int _calculateCompletedTests() {
//     return _calculateTestsToday() - _calculatePendingTests();
//   }
//
//   // Helper methods for content items
//   Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isTablet) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: EdgeInsets.all(isTablet ? 16 : 12),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.1)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 24, color: color),
//             SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: isTablet ? 24 : 20,
//                 fontWeight: FontWeight.w800,
//                 color: _textPrimary,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: _textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPatientItem(bool isTablet, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: _lightIndigo,
//             child: Text(
//               'P${index + 1}',
//               style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Patient ${1000 + index}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   '${_getRandomSpecialty(index)} • $_selectedShift Shift',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: _successColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               '₹ ${500 + (index * 100)}',
//               style: TextStyle(
//                 color: _successColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getRandomSpecialty(int index) {
//     final specialties = ['Cardiology', 'Orthopedics', 'Pediatrics', 'Neurology'];
//     return specialties[index % specialties.length];
//   }
//
//   Widget _buildConsultantItem(bool isTablet, int index) {
//     final doctor = _consultantsData[index];
//     final shiftFee = _getShiftFeeForDoctor(doctor, _selectedShift);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: (doctor['color'] as Color).withOpacity(0.1),
//             child: Icon(Icons.person, color: doctor['color'] as Color, size: 28),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   doctor['name'] as String,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   '${doctor['specialization']} • Room ${101 + index}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '₹ $shiftFee',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: _successColor,
//                 ),
//               ),
//               Text(
//                 _selectedShift,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: _textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   int _getShiftFeeForDoctor(Map<String, dynamic> doctor, String shift) {
//     switch (shift) {
//       case 'Morning':
//         return doctor['morning'] as int;
//       case 'Evening':
//         return doctor['evening'] as int;
//       case 'Night':
//         return doctor['night'] as int;
//       default:
//         return doctor['morning'] as int;
//     }
//   }
//
//   Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isTablet) {
//     final shiftFee = _getShiftFeeForDoctor(doctor, _selectedShift);
//     final isAvailable = _isDoctorAvailable(doctor, _selectedDate, _selectedShift);
//
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: (doctor['color'] as Color).withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: (doctor['color'] as Color).withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 24,
//                 backgroundColor: (doctor['color'] as Color).withOpacity(0.1),
//                 child: Icon(
//                   Icons.person,
//                   color: doctor['color'] as Color,
//                   size: 28,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           doctor['name'] as String,
//                           style: TextStyle(
//                             fontSize: isTablet ? 18 : 16,
//                             fontWeight: FontWeight.w700,
//                             color: _textPrimary,
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: isAvailable ? _successColor.withOpacity(0.1) : _dangerColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             isAvailable ? 'Available' : 'On Leave',
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                               color: isAvailable ? _successColor : _dangerColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       doctor['specialization'] as String,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: _textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Shift',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: _textSecondary,
//                     ),
//                   ),
//                   Text(
//                     _selectedShift,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: _getShiftColor(_selectedShift),
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Fee',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: _textSecondary,
//                     ),
//                   ),
//                   Text(
//                     '₹ $shiftFee',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: _textPrimary,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Timing:',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _textSecondary,
//                   ),
//                 ),
//                 Text(
//                   _getShiftTiming(_selectedShift),
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getShiftTiming(String shift) {
//     switch (shift) {
//       case 'Morning':
//         return '9:00 AM - 12:00 PM';
//       case 'Evening':
//         return '4:00 PM - 8:00 PM';
//       case 'Night':
//         return '10:00 PM - 6:00 AM';
//       default:
//         return '9:00 AM - 12:00 PM';
//     }
//   }
//
//   bool _isDoctorAvailable(Map<String, dynamic> doctor, DateTime date, String shift) {
//     // Simple availability logic for demo
//     if (date.weekday == 6 || date.weekday == 7) {
//       return shift != 'Night'; // No night shift on weekends
//     }
//     return true;
//   }
//
//   Widget _buildIPDStatCard(Map<String, dynamic> stat, bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: (stat['color'] as Color).withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: (stat['color'] as Color).withOpacity(0.2)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             stat['value'] as String,
//             style: TextStyle(
//               fontSize: isTablet ? 32 : 28,
//               fontWeight: FontWeight.w800,
//               color: stat['color'] as Color,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             stat['label'] as String,
//             style: TextStyle(
//               fontSize: isTablet ? 14 : 12,
//               color: _textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTestCategoryItem(bool isTablet, int index) {
//     final categories = [
//       {'name': 'Blood Tests', 'count': 15, 'pending': 2, 'revenue': 8400},
//       {'name': 'Urine Tests', 'count': 8, 'pending': 1, 'revenue': 3200},
//       {'name': 'X-Ray', 'count': 12, 'pending': 3, 'revenue': 15600},
//       {'name': 'MRI/CT Scan', 'count': 5, 'pending': 1, 'revenue': 25000},
//     ];
//
//     final category = categories[index % categories.length];
//     final adjustedCount = category['count'] + (_selectedDate.day % 5);
//     final adjustedPending = category['pending'] + (_selectedDate.day % 2);
//     final adjustedRevenue = category['revenue'] + (_selectedDate.day * 100);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: _lightIndigo,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(_getTestIcon(index), color: _primaryColor),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   category['name'] as String,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   '$adjustedCount tests • $adjustedPending pending',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: _successColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '₹ $adjustedRevenue',
//               style: TextStyle(
//                 color: _successColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getTestIcon(int index) {
//     switch (index % 4) {
//       case 0: return Icons.bloodtype;
//       case 1: return Icons.water_drop;
//       case 2: return Icons.visibility;
//       case 3: return Icons.scanner;
//       default: return Icons.science;
//     }
//   }
//
//   // Helper methods for OPD navigation
//   int _getIndexForContentType(String contentType) {
//     switch (contentType) {
//       case 'names': return 0;
//       case 'consultants': return 1;
//       case 'opd': return 2;
//       case 'ipd': return 3;
//       case 'laboratory': return 4;
//       default: return -1;
//     }
//   }
//
//   String _getContentTypeForIndex(int index) {
//     switch (index) {
//       case 0: return 'names';
//       case 1: return 'consultants';
//       case 2: return 'opd';
//       case 3: return 'ipd';
//       case 4: return 'laboratory';
//       default: return '';
//     }
//   }
//
//   // ==================== ORIGINAL METHODS ====================
//
//   PreferredSizeWidget _buildCustomAppBar(bool isTablet) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               _primaryColor,
//               _secondaryColor,
//               _accentColor.withOpacity(0.8),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(25),
//             bottomRight: Radius.circular(25),
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Left side: Menu icon and greetings
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {},
//                       icon: Icon(Icons.menu, color: Colors.white, size: isTablet ? 28 : 24),
//                     ),
//                     SizedBox(width: isTablet ? 16 : 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Good Morning!',
//                           style: TextStyle(
//                             fontSize: isTablet ? 16 : 14,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           'Alex Johnson',
//                           style: TextStyle(
//                             fontSize: isTablet ? 22 : 18,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                             letterSpacing: -0.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//
//                 // Right side: Notifications and profile
//                 Row(
//                   children: [
//                     Stack(
//                       children: [
//                         IconButton(
//                           onPressed: () {},
//                           icon: Icon(
//                             Icons.notifications_outlined,
//                             color: Colors.white,
//                             size: isTablet ? 26 : 22,
//                           ),
//                         ),
//                         Positioned(
//                           right: 10,
//                           top: 10,
//                           child: Container(
//                             width: 8,
//                             height: 8,
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(width: isTablet ? 12 : 8),
//                     Container(
//                       width: isTablet ? 48 : 40,
//                       height: isTablet ? 48 : 40,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                         image: const DecorationImage(
//                           image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       toolbarHeight: isTablet ? 80 : 70,
//     );
//   }
//
//   Widget _buildHealthScoreCard(bool isTablet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         Padding(
//           padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
//           child: Text(
//             'OPD Cards',
//             style: TextStyle(
//               fontSize: isTablet ? 22 : 18,
//               fontWeight: FontWeight.w700,
//               color: _textPrimary,
//             ),
//           ),
//         ),
//
//         // Scrollable Cards Row
//         SizedBox(
//           height: isTablet ? 120 : 100,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             physics: const BouncingScrollPhysics(),
//             children: [
//               SizedBox(width: isTablet ? 8 : 4),
//
//               // Indoor Card
//               _buildOPDCard(
//                 title: 'Indoor',
//                 icon: Icons.home,
//                 isTablet: isTablet,
//                 bgColor: _lightIndigo,
//                 iconColor: _primaryColor,
//                 onTap: () {
//                   print('Indoor tapped');
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 16 : 12),
//
//               // Laboratory Card
//               _buildOPDCard(
//                 title: 'Laboratory',
//                 icon: Icons.science,
//                 isTablet: isTablet,
//                 bgColor: const Color(0xFFFCE7F3),
//                 iconColor: _accentColor,
//                 onTap: () {
//                   print('Laboratory tapped');
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 16 : 12),
//
//               // Pharmacy Card
//               _buildOPDCard(
//                 title: 'Pharmacy',
//                 icon: Icons.medication,
//                 isTablet: isTablet,
//                 bgColor: const Color(0xFFCCFBF1),
//                 iconColor: _successColor,
//                 onTap: () {
//                   print('Pharmacy tapped');
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 16 : 12),
//
//               // Store Card
//               _buildOPDCard(
//                 title: 'Store',
//                 icon: Icons.store,
//                 isTablet: isTablet,
//                 bgColor: _lightIndigo,
//                 iconColor: _infoColor,
//                 onTap: () {
//                   print('Store tapped');
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 16 : 12),
//
//               // Payroll Card
//               _buildOPDCard(
//                 title: 'Payroll',
//                 icon: Icons.payments,
//                 isTablet: isTablet,
//                 bgColor: const Color(0xFFFCE7F3),
//                 iconColor: _warningColor,
//                 onTap: () {
//                   print('Payroll tapped');
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 16 : 12),
//
//               // Account Card
//               _buildOPDCard(
//                 title: 'Account',
//                 icon: Icons.account_balance,
//                 isTablet: isTablet,
//                 bgColor: const Color(0xFFCCFBF1),
//                 iconColor: _tealColor,
//                 onTap: () {
//                   print('Account tapped');
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 16 : 12),
//
//               // OPD Card
//               _buildOPDCard(
//                 title: 'OPD',
//                 icon: Icons.local_hospital,
//                 isTablet: isTablet,
//                 bgColor: const Color(0xFFFCE7F3),
//                 iconColor: _dangerColor,
//                 onTap: () {
//                   setState(() {
//                     _showOPDContent = true;
//                     _selectedOPDCard = 'opd';
//                     _opdContentIndex = -1;
//                   });
//                 },
//               ),
//
//               SizedBox(width: isTablet ? 8 : 4),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOPDCard({
//     required String title,
//     required IconData icon,
//     required bool isTablet,
//     required Color bgColor,
//     required Color iconColor,
//     required VoidCallback onTap,
//   }) {
//     final isSelected = _showOPDContent && _selectedOPDCard == title.toLowerCase();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: isSelected ? iconColor.withOpacity(0.1) : bgColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 12,
//             spreadRadius: 1,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: isSelected ? Border.all(color: iconColor, width: 2) : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(20),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             width: isTablet ? 100 : 85,
//             padding: EdgeInsets.all(isTablet ? 16 : 12),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: isTablet ? 48 : 40,
//                   height: isTablet ? 48 : 40,
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: isTablet ? 24 : 20,
//                     color: iconColor,
//                   ),
//                 ),
//
//                 SizedBox(height: isTablet ? 12 : 8),
//
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: isTablet ? 14 : 12,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected ? iconColor : _textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMiniStat(String title, String status, IconData icon, Color color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 14, color: color),
//             SizedBox(width: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: _textPrimary,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 2),
//         Text(
//           status,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHealthMetricsGrid(bool isTablet) {
//     final metrics = [
//       {
//         'title': 'Heart Rate',
//         'value': '72',
//         'unit': 'BPM',
//         'icon': Icons.favorite,
//         'color': _dangerColor,
//         'trend': Icons.arrow_upward,
//         'status': 'Normal',
//         'bgColor': _lightIndigo,
//       },
//       {
//         'title': 'Blood Pressure',
//         'value': '120/80',
//         'unit': 'mmHg',
//         'icon': Icons.monitor_heart,
//         'color': _warningColor,
//         'trend': Icons.trending_flat,
//         'status': 'Ideal',
//         'bgColor': const Color(0xFFFCE7F3),
//       },
//       {
//         'title': 'Blood Sugar',
//         'value': '98',
//         'unit': 'mg/dL',
//         'icon': Icons.water_drop,
//         'color': _successColor,
//         'trend': Icons.arrow_downward,
//         'status': 'Normal',
//         'bgColor': const Color(0xFFCCFBF1),
//       },
//       {
//         'title': 'Oxygen',
//         'value': '98%',
//         'unit': 'SpO2',
//         'icon': Icons.air,
//         'color': _infoColor,
//         'trend': Icons.arrow_upward,
//         'status': 'Excellent',
//         'bgColor': _lightIndigo,
//       },
//     ];
//
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isTablet ? 4 : 2,
//         crossAxisSpacing: isTablet ? 20 : 16,
//         mainAxisSpacing: isTablet ? 20 : 16,
//         childAspectRatio: 1.0,
//       ),
//       itemCount: metrics.length,
//       itemBuilder: (context, index) {
//         return _buildMetricCard(metrics[index], isTablet);
//       },
//     );
//   }
//
//   Widget _buildMetricCard(Map<String, dynamic> metric, bool isTablet) {
//     return Container(
//       decoration: BoxDecoration(
//         color: metric['bgColor'] as Color,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 12,
//             spreadRadius: 1,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(20),
//         child: InkWell(
//           onTap: () {},
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: EdgeInsets.all(isTablet ? 20 : 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       width: isTablet ? 44 : 40,
//                       height: isTablet ? 44 : 40,
//                       decoration: BoxDecoration(
//                         color: (metric['color'] as Color).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         metric['icon'] as IconData,
//                         color: metric['color'] as Color,
//                         size: isTablet ? 22 : 20,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         metric['trend'] as IconData,
//                         size: 16,
//                         color: metric['color'] as Color,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       metric['value'] as String,
//                       style: TextStyle(
//                         fontSize: isTablet ? 28 : 24,
//                         fontWeight: FontWeight.w800,
//                         color: _textPrimary,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       metric['unit'] as String,
//                       style: TextStyle(
//                         fontSize: isTablet ? 13 : 12,
//                         color: _textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       metric['title'] as String,
//                       style: TextStyle(
//                         fontSize: isTablet ? 14 : 12,
//                         fontWeight: FontWeight.w600,
//                         color: _textPrimary,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         metric['status'] as String,
//                         style: TextStyle(
//                           fontSize: isTablet ? 12 : 10,
//                           fontWeight: FontWeight.w700,
//                           color: metric['color'] as Color,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActivitySleepSection(bool isTablet) {
//     return Column(
//       children: [
//         _buildActivityCard(isTablet),
//         SizedBox(height: isTablet ? 20 : 16),
//         _buildSleepCard(isTablet),
//       ],
//     );
//   }
//
//   Widget _buildActivityCard(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Today\'s Activity',
//                 style: TextStyle(
//                   fontSize: isTablet ? 18 : 16,
//                   fontWeight: FontWeight.w700,
//                   color: _textPrimary,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _lightIndigo,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '8,542 steps',
//                   style: TextStyle(
//                     color: _primaryColor,
//                     fontWeight: FontWeight.w700,
//                     fontSize: isTablet ? 14 : 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           Column(
//             children: [
//               _buildActivityProgress('Steps', 85, _successColor),
//               SizedBox(height: 12),
//               _buildActivityProgress('Calories', 72, _warningColor),
//               SizedBox(height: 12),
//               _buildActivityProgress('Distance', 65, _infoColor),
//             ],
//           ),
//
//           SizedBox(height: isTablet ? 16 : 12),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildActivityStat('Walking', '30 min', Icons.directions_walk, _primaryColor),
//               _buildActivityStat('Running', '15 min', Icons.directions_run, _dangerColor),
//               _buildActivityStat('Cycling', '45 min', Icons.directions_bike, _tealColor),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActivityProgress(String label, int value, Color color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: _textPrimary,
//               ),
//             ),
//             Text(
//               '$value%',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 8),
//         Container(
//           height: 6,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(3),
//           ),
//           child: FractionallySizedBox(
//             widthFactor: value / 100,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [color, color.withOpacity(0.8)],
//                 ),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActivityStat(String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: _textPrimary,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: _textSecondary,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSleepCard(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Sleep Quality',
//                 style: TextStyle(
//                   fontSize: isTablet ? 18 : 16,
//                   fontWeight: FontWeight.w700,
//                   color: _textPrimary,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFCCFBF1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '7h 30m',
//                   style: TextStyle(
//                     color: _tealColor,
//                     fontWeight: FontWeight.w700,
//                     fontSize: isTablet ? 14 : 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildSleepPhase('Deep', '2h 10m', _infoColor),
//               _buildSleepPhase('Light', '4h 20m', _primaryColor),
//               _buildSleepPhase('REM', '1h 0m', _accentColor),
//             ],
//           ),
//
//           SizedBox(height: isTablet ? 20 : 16),
//
//           Container(
//             padding: EdgeInsets.all(isTablet ? 16 : 12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [_primaryColor.withOpacity(0.1), _accentColor.withOpacity(0.1)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: _primaryColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(Icons.bedtime, color: Colors.white, size: 24),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Sleep Score',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: _textPrimary,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         '82/100 • Good quality sleep',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: _textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _textSecondary),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSleepPhase(String phase, String duration, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 60,
//           height: 4,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           duration,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: _textPrimary,
//           ),
//         ),
//         Text(
//           phase,
//           style: TextStyle(
//             fontSize: 10,
//             color: _textSecondary,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHealthInsights(bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Health Insights',
//                 style: TextStyle(
//                   fontSize: isTablet ? 18 : 16,
//                   fontWeight: FontWeight.w700,
//                   color: _textPrimary,
//                 ),
//               ),
//               Icon(Icons.insights_rounded, color: _primaryColor),
//             ],
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//
//           Column(
//             children: [
//               _buildInsightItem(
//                 'Your heart rate is improving!',
//                 'Consistent exercise shows positive effects.',
//                 Icons.favorite,
//                 _dangerColor,
//               ),
//               SizedBox(height: 12),
//               _buildInsightItem(
//                 'Sleep quality increased by 15%',
//                 'Keep your regular sleep schedule.',
//                 Icons.bedtime,
//                 _infoColor,
//               ),
//               SizedBox(height: 12),
//               _buildInsightItem(
//                 'Stay hydrated',
//                 'Drink more water for better performance.',
//                 Icons.water_drop,
//                 _tealColor,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickStats(bool isTablet) {
//     final stats = [
//       {'label': 'Water', 'value': '2.5L', 'icon': Icons.water_drop, 'color': _tealColor},
//       {'label': 'Calories', 'value': '1,850', 'icon': Icons.local_fire_department, 'color': const Color(0xFFF97316)},
//       {'label': 'Medication', 'value': 'Taken', 'icon': Icons.medical_services, 'color': _successColor},
//       {'label': 'Stress', 'value': 'Low', 'icon': Icons.self_improvement, 'color': _primaryColor},
//     ];
//
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isTablet ? 4 : 2,
//         crossAxisSpacing: isTablet ? 16 : 12,
//         mainAxisSpacing: isTablet ? 16 : 12,
//         childAspectRatio: 1.2,
//       ),
//       itemCount: stats.length,
//       itemBuilder: (context, index) {
//         return _buildQuickStatCard(stats[index]);
//       },
//     );
//   }
//
//   Widget _buildQuickStatCard(Map<String, dynamic> stat) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             spreadRadius: 1,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           onTap: () {},
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: (stat['color'] as Color).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     stat['icon'] as IconData,
//                     color: stat['color'] as Color,
//                     size: 20,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   stat['value'] as String,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: _textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   stat['label'] as String,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNavigationBar(bool isTablet) {
//     return Container(
//       height: isTablet ? 80 : 70,
//       decoration: BoxDecoration(
//         color: _cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 20,
//             spreadRadius: 5,
//             offset: const Offset(0, -5),
//           ),
//         ],
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.dashboard_rounded, 'Home', 0, isTablet),
//           _buildNavItem(Icons.health_and_safety_rounded, 'Health', 1, isTablet),
//           _buildFloatingActionButton(isTablet),
//           _buildNavItem(Icons.calendar_today_rounded, 'Calendar', 2, isTablet),
//           _buildNavItem(Icons.person_rounded, 'Profile', 3, isTablet),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, int index, bool isTablet) {
//     final isActive = _currentIndex == index;
//     return GestureDetector(
//       onTap: () => setState(() => _currentIndex = index),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: isTablet ? 26 : 22,
//             color: isActive ? _primaryColor : _textSecondary,
//           ),
//           SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTablet ? 12 : 10,
//               fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//               color: isActive ? _primaryColor : _textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFloatingActionButton(bool isTablet) {
//     return Container(
//       width: isTablet ? 60 : 50,
//       height: isTablet ? 60 : 50,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [_primaryColor, _accentColor],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: _primaryColor.withOpacity(0.3),
//             blurRadius: 15,
//             spreadRadius: 3,
//           ),
//         ],
//       ),
//       child: Icon(
//         Icons.add,
//         color: Colors.white,
//         size: isTablet ? 28 : 24,
//       ),
//     );
//   }
// }
//
// extension on Object? {
//   operator +(int other) {}
// }
// lib/attractive_health_dashboard.dart
// Update the imports in attractive_health_dashboard.dart
import 'package:flutter/material.dart';
import '../../custum widgets/activity_todays/activity_sleep.dart';
import '../../custum widgets/bottom_navigation/bottom_navigation.dart';
import '../../custum widgets/custom_app_bar/custom_app_bar.dart';
import '../../custum widgets/health_insights/health_insights.dart';
import '../../custum widgets/metric_cards/metric_cards.dart';
import '../../custum widgets/opd_cards/opd_cards.dart';
import '../../custum widgets/opd_cards_content/opd_content/opd_content.dart';
import '../../custum widgets/quick_stats/quick_stats.dart';

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
  String _selectedShift = 'Morning';
  final List<String> _shifts = ['Morning', 'Evening', 'Night'];

  final List<Map<String, dynamic>> _consultantsData = [
    {
      'name': 'Dr. A',
      'specialization': 'Cardiology',
      'morning': 4500,
      'evening': 5000,
      'night': 5500,
      'color': Color(0xFFEF4444),
    },
    // ... rest of consultant data
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

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
                  isTablet: isTablet,
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
             // Replace your OPD content section with:
          if (_showOPDContent && _selectedOPDCard == 'opd')
          OPDTabsWithContent(
          isTablet: isTablet,
          opdContentIndex: _opdContentIndex,
          selectedDate: _selectedDate,
          selectedShift: _selectedShift,
          shifts: _shifts,
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
            });
          },
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          onShiftChanged: (shift) {
            setState(() {
              _selectedShift = shift;
            });
          },
          consultantsData: _consultantsData,
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