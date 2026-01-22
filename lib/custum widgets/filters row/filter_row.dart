// lib/widgets/filter_row.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../utils/utils.dart';

class FilterRow extends StatelessWidget {
  final bool isTablet;
  final DateTime selectedDate;
  final String selectedShift;
  final List<String> shifts;
  final Function(DateTime) onDateChanged;
  final Function(String) onShiftChanged;

  const FilterRow({
    Key? key,
    required this.isTablet,
    required this.selectedDate,
    required this.selectedShift,
    required this.shifts,
    required this.onDateChanged,
    required this.onShiftChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Results',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Date Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightIndigo),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: AppColors.primaryColor,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppUtils.formatDate(selectedDate),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 20 : 12),

              // Shift Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Shift',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightIndigo),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedShift,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                            items: shifts.map((String shift) {
                              return DropdownMenuItem<String>(
                                value: shift,
                                child: Row(
                                  children: [
                                    Icon(
                                      AppUtils.getShiftIcon(shift),
                                      size: 18,
                                      color: AppUtils.getShiftColor(shift),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      shift,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                onShiftChanged(newValue);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 20 : 12),

              // Apply Filter Button
              if (isTablet)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, size: 18),
                        SizedBox(width: 8),
                        Text('Apply'),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Apply Filter Button for mobile
          // if (!isTablet)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 16),
          //     child: SizedBox(
          //       width: double.infinity,
          //       child: ElevatedButton(
          //         onPressed: () {},
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: AppColors.primaryColor,
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(vertical: 14),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           elevation: 0,
          //         ),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Icon(Icons.filter_alt, size: 18),
          //             SizedBox(width: 8),
          //             Text('Apply Filter'),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}