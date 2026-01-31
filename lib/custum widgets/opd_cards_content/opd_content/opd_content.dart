// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../../provider/shift_provider/shift_provider.dart';
//
// class ShiftReportPage extends StatefulWidget {
//   const ShiftReportPage({Key? key}) : super(key: key);
//
//   @override
//   State<ShiftReportPage> createState() => _ShiftReportPageState();
// }
//
// class _ShiftReportPageState extends State<ShiftReportPage> {
//   final NumberFormat _numberFormat = NumberFormat("#,##0", "en_US");
//
//   String _formatAmount(double amount) => _numberFormat.format(amount);
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<ShiftReportProvider>();
//       provider.fetchAvailableShifts().then((_) {
//         provider.fetchData();
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Consumer<ShiftReportProvider>(
//             builder: (context, provider, child) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   _buildHeader(),
//                   const SizedBox(height: 16),
//
//                   // Filters
//                   _buildFiltersCard(provider),
//                   const SizedBox(height: 16),
//
//                   // Summary Cards
//                   _buildSummaryCards(provider),
//                   const SizedBox(height: 16),
//
//                   // Consultation Table
//                   _buildConsultationTable(provider),
//                   const SizedBox(height: 16),
//
//                   // Other Services Table
//                   _buildOtherServicesTable(provider),
//                   const SizedBox(height: 16),
//
//                   // Expenses Table
//                   _buildExpensesTable(provider),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF037389), Color(0xFF14B8A6)],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.description, color: Colors.white),
//               SizedBox(width: 8),
//               Text(
//                 'Shift Report',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Shift-based financial summary',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.85),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFiltersCard(ShiftReportProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               // Date Filter
//               Expanded(
//                 child: _buildDateFilter(provider),
//               ),
//               const SizedBox(width: 12),
//
//               // Shift Filter
//               Expanded(
//                 child: _buildShiftFilter(provider),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               // Print Button
//               ElevatedButton.icon(
//                 onPressed: provider.opdRecords.isEmpty ? null : () {
//                   // TODO: Implement print functionality
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Print functionality coming soon')),
//                   );
//                 },
//                 icon: const Icon(Icons.print, size: 16),
//                 label: const Text('Print'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               const SizedBox(width: 8),
//
//               // Refresh Button
//               ElevatedButton.icon(
//                 onPressed: provider.isLoading ? null : () {
//                   provider.refresh();
//                 },
//                 icon: provider.isLoading
//                     ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//                     : const Icon(Icons.refresh, size: 16),
//                 label: const Text('Refresh'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateFilter(ShiftReportProvider provider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Date',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: () => _selectDate(context, provider),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF9FAFB),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 16, color: Color(0xFF037389)),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     DateFormat('dd/MM/yyyy').format(provider.selectedDate),
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildShiftFilter(ShiftReportProvider provider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Shift',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF9FAFB),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: const Color(0xFFE5E7EB)),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: provider.selectedShiftId ?? 'All',
//               isExpanded: true,
//               items: [
//                 const DropdownMenuItem(
//                   value: 'All',
//                   child: Text('All Shifts', style: TextStyle(fontSize: 14)),
//                 ),
//                 ...provider.availableShifts.map((shift) {
//                   return DropdownMenuItem(
//                     value: shift.shiftId.toString(),
//                     child: Text(
//                       '${shift.shiftType} (ID: ${shift.shiftId})',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   );
//                 }),
//               ],
//               onChanged: (value) {
//                 if (value != null) {
//                   provider.setSelectedShiftId(value);
//                   provider.fetchData();
//                 }
//               },
//             ),
//           ),
//         ),
//         if (provider.availableShifts.isEmpty && !provider.isLoading)
//           const Padding(
//             padding: EdgeInsets.only(top: 2),
//             child: Text(
//               'No shifts found',
//               style: TextStyle(fontSize: 11, color: Colors.grey),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSummaryCards(ShiftReportProvider provider) {
//     if (provider.isLoading && provider.opdRecords.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(40),
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     final financial = provider.financialSummary;
//
//     return Row(
//       children: [
//         // Total Revenue Card
//         Expanded(
//           child: _buildSummaryCard(
//             title: 'Total Revenue',
//             value: 'Rs ${_formatAmount(financial.totalRevenue)}',
//             subtitle: 'All services',
//             icon: Icons.attach_money,
//             color: const Color(0xFF3B82F6),
//           ),
//         ),
//         const SizedBox(width: 12),
//
//         // Total Expenses Card
//         Expanded(
//           child: _buildSummaryCard(
//             title: 'Total Expenses',
//             value: 'Rs ${_formatAmount(financial.totalExpensesWithDocShare)}',
//             subtitle: 'Incl. doctor share',
//             icon: Icons.shopping_cart,
//             color: const Color(0xFFEF4444),
//           ),
//         ),
//         const SizedBox(width: 12),
//
//         // Net Revenue Card
//         Expanded(
//           child: _buildSummaryCard(
//             title: 'Net Revenue',
//             value: 'Rs ${_formatAmount(financial.netHospitalRevenue)}',
//             subtitle: 'After expenses',
//             icon: Icons.account_balance_wallet,
//             color: const Color(0xFF10B981),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSummaryCard({
//     required String title,
//     required String value,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             color.withOpacity(0.05),
//             color.withOpacity(0.1),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.1),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [color, color.withOpacity(0.8)],
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 16),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: color.withOpacity(0.8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: const TextStyle(
//               fontSize: 11,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildConsultationTable(ShiftReportProvider provider) {
//     final consultations = provider.consultationSummaries;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.description, color: Color(0xFF037389), size: 14),
//               SizedBox(width: 6),
//               Text(
//                 'Consultation (Doctors)',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (consultations.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Text('No consultation data available'),
//               ),
//             )
//           else
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 20,
//                 headingRowHeight: 40,
//                 dataRowHeight: 40,
//                 columns: const [
//                   DataColumn(label: Text('Doctor Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Total Service Amount', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Dr. Share', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Hospital Received', style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 rows: [
//                   ...consultations.map((consultation) {
//                     return DataRow(cells: [
//                       DataCell(Text(consultation.doctorName, style: const TextStyle(fontWeight: FontWeight.w600))),
//                       DataCell(Text(_formatAmount(consultation.totalAmount))),
//                       DataCell(Text(_formatAmount(consultation.drShare))),
//                       DataCell(Text(_formatAmount(consultation.hospitalShare), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
//                     ]);
//                   }),
//                   // Total row
//                   DataRow(
//                     color: MaterialStateProperty.all(Colors.grey[100]),
//                     cells: [
//                       const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataCell(Text(
//                         _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.totalAmount)),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                       DataCell(Text(
//                         _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.drShare)),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                       DataCell(Text(
//                         _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.hospitalShare)),
//                         style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//                       )),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOtherServicesTable(ShiftReportProvider provider) {
//     final services = provider.serviceSummaries;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.description, color: Color(0xFF037389), size: 14),
//               SizedBox(width: 6),
//               Text(
//                 'Other Services',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (services.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Text('No other services data available'),
//               ),
//             )
//           else
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 20,
//                 headingRowHeight: 40,
//                 dataRowHeight: 40,
//                 columns: const [
//                   DataColumn(label: Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Dr. Share', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Hospital Received', style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 rows: [
//                   ...services.map((service) {
//                     return DataRow(cells: [
//                       DataCell(Text(service.serviceName, style: const TextStyle(fontWeight: FontWeight.w600))),
//                       DataCell(Text(_formatAmount(service.totalAmount))),
//                       DataCell(Text(_formatAmount(service.drShare))),
//                       DataCell(Text(_formatAmount(service.hospitalShare), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
//                     ]);
//                   }),
//                   // Total row
//                   DataRow(
//                     color: MaterialStateProperty.all(Colors.grey[100]),
//                     cells: [
//                       const DataCell(Text('Total Services', style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataCell(Text(
//                         _formatAmount(services.fold(0.0, (sum, s) => sum + s.totalAmount)),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                       DataCell(Text(
//                         _formatAmount(services.fold(0.0, (sum, s) => sum + s.drShare)),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                       DataCell(Text(
//                         _formatAmount(services.fold(0.0, (sum, s) => sum + s.hospitalShare)),
//                         style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//                       )),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildExpensesTable(ShiftReportProvider provider) {
//     final expenses = provider.expenses;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.shopping_cart, color: Color(0xFFD97706), size: 14),
//               SizedBox(width: 6),
//               Text(
//                 'Expenses',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (expenses.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Text('No expenses data available'),
//               ),
//             )
//           else
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 20,
//                 headingRowHeight: 40,
//                 dataRowHeight: 40,
//                 columns: const [
//                   DataColumn(label: Text('Expense Head', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 rows: [
//                   ...expenses.map((expense) {
//                     return DataRow(cells: [
//                       DataCell(Text(expense.expenseHead ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
//                       DataCell(Text(expense.expenseDescription ?? '-')),
//                       DataCell(Text(_formatAmount(expense.expenseAmount))),
//                     ]);
//                   }),
//                   // Total row
//                   DataRow(
//                     color: MaterialStateProperty.all(const Color(0xFFFFFBEB)),
//                     cells: [
//                       const DataCell(Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.bold))),
//                       const DataCell(Text('')),
//                       DataCell(Text(
//                         _formatAmount(expenses.fold(0.0, (sum, e) => sum + e.expenseAmount)),
//                         style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
//                       )),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _selectDate(BuildContext context, ShiftReportProvider provider) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: provider.selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//
//     if (picked != null && picked != provider.selectedDate) {
//       provider.setSelectedDate(picked);
//       provider.fetchAvailableShifts().then((_) {
//         provider.fetchData();
//       });
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../provider/shift_provider/shift_provider.dart';


class ShiftReportPage extends StatefulWidget {
  const ShiftReportPage({Key? key}) : super(key: key);

  @override
  State<ShiftReportPage> createState() => _ShiftReportPageState();
}

class _ShiftReportPageState extends State<ShiftReportPage> {
  final NumberFormat _numberFormat = NumberFormat("#,##0", "en_US");
  int _selectedTabIndex = -1; // -1 means no tab selected

  String _formatAmount(double amount) => _numberFormat.format(amount);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShiftReportProvider>();
      provider.fetchAvailableShifts().then((_) {
        provider.fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<ShiftReportProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Filters
                  _buildFiltersCard(provider),
                  const SizedBox(height: 16),

                  // Summary Cards (Tabs)
                  _buildSummaryCardsTabs(provider),
                  const SizedBox(height: 24),

                  // Show selected tab content
                  if (_selectedTabIndex >= 0)
                    _buildTabContent(provider, _selectedTabIndex),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                    'Shift Report',
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
          if (_selectedTabIndex >= 0)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedTabIndex = -1;
                });
              },
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: 'Close details',
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(ShiftReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Date Filter
              Expanded(
                child: _buildDateFilter(provider),
              ),
              const SizedBox(width: 12),

              // Shift Filter
              Expanded(
                child: _buildShiftFilter(provider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Print Button
              ElevatedButton.icon(
                onPressed: provider.opdRecords.isEmpty ? null : () {
                  // TODO: Implement print functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Print'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),

              // Refresh Button
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () {
                  provider.refresh();
                },
                icon: provider.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(ShiftReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF037389)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(provider.selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
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

  Widget _buildShiftFilter(ShiftReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shift',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedShiftId ?? 'All',
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: 'All',
                  child: Text('All Shifts', style: TextStyle(fontSize: 14)),
                ),
                ...provider.availableShifts.map((shift) {
                  return DropdownMenuItem(
                    value: shift.shiftId.toString(),
                    child: Text(
                      '${shift.shiftType} (ID: ${shift.shiftId})',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.setSelectedShiftId(value);
                  provider.fetchData();
                }
              },
            ),
          ),
        ),
        if (provider.availableShifts.isEmpty && !provider.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'No shifts found',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCardsTabs(ShiftReportProvider provider) {
    if (provider.isLoading && provider.opdRecords.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final financial = provider.financialSummary;

    final tabs = [
      {
        'title': 'Total Revenue',
        'value': 'Rs ${_formatAmount(financial.totalRevenue)}',
        'subtitle': 'All services',
        'icon': Icons.attach_money,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Total Expenses',
        'value': 'Rs ${_formatAmount(financial.totalExpensesWithDocShare)}',
        'subtitle': 'Incl. doctor share',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Net Revenue',
        'value': 'Rs ${_formatAmount(financial.netHospitalRevenue)}',
        'subtitle': 'After expenses',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Consultations',
        'value': '${provider.consultationSummaries.length}',
        'subtitle': 'Doctors',
        'icon': Icons.medical_services,
        'color': const Color(0xFF14B8A6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final tab = tabs[index];
        final isSelected = _selectedTabIndex == index;

        return _buildSummaryCardTab(
          title: tab['title'] as String,
          value: tab['value'] as String,
          subtitle: tab['subtitle'] as String,
          icon: tab['icon'] as IconData,
          color: tab['color'] as Color,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedTabIndex = isSelected ? -1 : index;
            });
          },
        );
      },
    );
  }

  Widget _buildSummaryCardTab({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [color.withOpacity(0.15), color.withOpacity(0.2)]
                : [color.withOpacity(0.05), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isSelected ? 0.2 : 0.1),
              blurRadius: isSelected ? 8 : 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ShiftReportProvider provider, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildRevenueContent(provider);
      case 1:
        return _buildExpensesContent(provider);
      case 2:
        return _buildNetRevenueContent(provider);
      case 3:
        return _buildConsultationsContent(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRevenueContent(ShiftReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_money, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Total Revenue Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Consultation Table
          _buildConsultationTable(provider),
          const SizedBox(height: 16),

          // Other Services Table
          _buildOtherServicesTable(provider),
        ],
      ),
    );
  }

  Widget _buildExpensesContent(ShiftReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_cart, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Expenses Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expenses Table
          _buildExpensesTable(provider),
        ],
      ),
    );
  }

  Widget _buildNetRevenueContent(ShiftReportProvider provider) {
    final financial = provider.financialSummary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Net Revenue Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Financial Summary Cards
          _buildFinancialSummaryCard(
            'Total Revenue',
            financial.totalRevenue,
            Icons.trending_up,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          _buildFinancialSummaryCard(
            'Total Expenses',
            financial.totalExpensesWithDocShare,
            Icons.trending_down,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          _buildFinancialSummaryCard(
            'Net Revenue',
            financial.netHospitalRevenue,
            Icons.account_balance,
            const Color(0xFF10B981),
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
      String title,
      double amount,
      IconData icon,
      Color color, {
        bool isHighlight = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isHighlight ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isHighlight ? 0.3 : 0.2),
          width: isHighlight ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_formatAmount(amount)}',
                  style: TextStyle(
                    fontSize: isHighlight ? 22 : 18,
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

  Widget _buildConsultationsContent(ShiftReportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_services, color: Color(0xFF14B8A6), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Consultations by Doctor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Consultation Table
          _buildConsultationTable(provider),
        ],
      ),
    );
  }

  Widget _buildConsultationTable(ShiftReportProvider provider) {
    final consultations = provider.consultationSummaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description, color: Color(0xFF037389), size: 14),
            SizedBox(width: 6),
            Text(
              'Consultation (Doctors)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (consultations.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No consultation data available'),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 40,
              dataRowHeight: 40,
              columns: const [
                DataColumn(label: Text('Doctor Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Service Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Dr. Share', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hospital Received', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...consultations.map((consultation) {
                  return DataRow(cells: [
                    DataCell(Text(consultation.doctorName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(_formatAmount(consultation.totalAmount))),
                    DataCell(Text(_formatAmount(consultation.drShare))),
                    DataCell(Text(_formatAmount(consultation.hospitalShare), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                  ]);
                }),
                // Total row
                DataRow(
                  color: MaterialStateProperty.all(Colors.grey[100]),
                  cells: [
                    const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(
                      _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.totalAmount)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.drShare)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      _formatAmount(consultations.fold(0.0, (sum, c) => sum + c.hospitalShare)),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOtherServicesTable(ShiftReportProvider provider) {
    final services = provider.serviceSummaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description, color: Color(0xFF037389), size: 14),
            SizedBox(width: 6),
            Text(
              'Other Services',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (services.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No other services data available'),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 40,
              dataRowHeight: 40,
              columns: const [
                DataColumn(label: Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Dr. Share', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hospital Received', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...services.map((service) {
                  return DataRow(cells: [
                    DataCell(Text(service.serviceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(_formatAmount(service.totalAmount))),
                    DataCell(Text(_formatAmount(service.drShare))),
                    DataCell(Text(_formatAmount(service.hospitalShare), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                  ]);
                }),
                // Total row
                DataRow(
                  color: MaterialStateProperty.all(Colors.grey[100]),
                  cells: [
                    const DataCell(Text('Total Services', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(
                      _formatAmount(services.fold(0.0, (sum, s) => sum + s.totalAmount)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      _formatAmount(services.fold(0.0, (sum, s) => sum + s.drShare)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      _formatAmount(services.fold(0.0, (sum, s) => sum + s.hospitalShare)),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpensesTable(ShiftReportProvider provider) {
    final expenses = provider.expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.shopping_cart, color: Color(0xFFD97706), size: 14),
            SizedBox(width: 6),
            Text(
              'Expenses',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No expenses data available'),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 40,
              dataRowHeight: 40,
              columns: const [
                DataColumn(label: Text('Expense Head', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...expenses.map((expense) {
                  return DataRow(cells: [
                    DataCell(Text(expense.expenseHead ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(expense.expenseDescription ?? '-')),
                    DataCell(Text(_formatAmount(expense.expenseAmount))),
                  ]);
                }),
                // Total row
                DataRow(
                  color: MaterialStateProperty.all(const Color(0xFFFFFBEB)),
                  cells: [
                    const DataCell(Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('')),
                    DataCell(Text(
                      _formatAmount(expenses.fold(0.0, (sum, e) => sum + e.expenseAmount)),
                      style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, ShiftReportProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
      provider.fetchAvailableShifts().then((_) {
        provider.fetchData();
      });
    }
  }
}
