// lib/widgets/opd_cards.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class OPDCards extends StatelessWidget {
  final bool showOPDContent;
  final String? selectedOPDCard;
  final Function(String) onOPDCardTap;
  final Function() onOPDTap;

  const OPDCards({
    Key? key,
    required this.showOPDContent,
    required this.selectedOPDCard,
    required this.onOPDCardTap,
    required this.onOPDTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Header
        Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 24 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hospital Departments',
                style: HospitalColors.getModernTextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isDesktop)
                Text(
                  'Select a department to view details',
                  style: HospitalColors.getModernTextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),

        // Modern Scrollable Cards
        SizedBox(
          height: isTablet ? 140 : 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(width: isTablet ? 12 : 8),

              // OPD Card
              _buildModernDepartmentCard(
                title: 'OPD',
                icon: Icons.medical_services_outlined,
                department: 'opd',
                onTap: onOPDTap,
                isTablet: isTablet,
              ),

              SizedBox(width: isTablet ? 20 : 16),

              // Indoor Card
              _buildModernDepartmentCard(
                title: 'Indoor',
                icon: Icons.night_shelter_outlined,
                department: 'indoor',
                onTap: () => onOPDCardTap('Indoor'),
                isTablet: isTablet,
              ),

              SizedBox(width: isTablet ? 20 : 16),

              // Laboratory Card
              _buildModernDepartmentCard(
                title: 'Lab',
                icon: Icons.science_outlined,
                department: 'laboratory',
                onTap: () => onOPDCardTap('Laboratory'),
                isTablet: isTablet,
              ),

              SizedBox(width: isTablet ? 20 : 16),

              // Pharmacy Card
              _buildModernDepartmentCard(
                title: 'Pharmacy',
                icon: Icons.medication_outlined,
                department: 'pharmacy',
                onTap: () => onOPDCardTap('Pharmacy'),
                isTablet: isTablet,
              ),

              SizedBox(width: isTablet ? 20 : 16),

              // Store Card
              _buildModernDepartmentCard(
                title: 'Store',
                icon: Icons.inventory_2_outlined,
                department: 'store',
                onTap: () => onOPDCardTap('Store'),
                isTablet: isTablet,
              ),

              if (isTablet) ...[
                SizedBox(width: 20),

                // Staff Card
                _buildModernDepartmentCard(
                  title: 'Staff',
                  icon: Icons.people_outline,
                  department: 'staff',
                  onTap: () => onOPDCardTap('Staff'),
                  isTablet: isTablet,
                ),

                SizedBox(width: 20),

                // Finance Card
                _buildModernDepartmentCard(
                  title: 'Finance',
                  icon: Icons.account_balance_outlined,
                  department: 'finance',
                  onTap: () => onOPDCardTap('Finance'),
                  isTablet: isTablet,
                ),
              ],

              SizedBox(width: isTablet ? 12 : 8),
            ],
          ),
        ),

        // Additional cards for tablet/desktop
        if (isTablet && !isDesktop)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(width: 12),

                  // Staff Card
                  _buildModernDepartmentCard(
                    title: 'Staff',
                    icon: Icons.people_outline,
                    department: 'staff',
                    onTap: () => onOPDCardTap('Staff'),
                    isTablet: isTablet,
                  ),

                  SizedBox(width: 20),

                  // Finance Card
                  _buildModernDepartmentCard(
                    title: 'Finance',
                    icon: Icons.account_balance_outlined,
                    department: 'finance',
                    onTap: () => onOPDCardTap('Finance'),
                    isTablet: isTablet,
                  ),

                  SizedBox(width: 20),

                  // Emergency Card
                  _buildModernDepartmentCard(
                    title: 'Emergency',
                    icon: Icons.emergency_outlined,
                    department: 'emergency',
                    onTap: () => onOPDCardTap('Emergency'),
                    isTablet: isTablet,
                  ),

                  SizedBox(width: 20),

                  // Radiology Card
                  _buildModernDepartmentCard(
                    title: 'Radiology',
                    icon: Icons.scanner_outlined,
                    department: 'radiology',
                    onTap: () => onOPDCardTap('Radiology'),
                    isTablet: isTablet,
                  ),

                  SizedBox(width: 12),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernDepartmentCard({
    required String title,
    required IconData icon,
    required String department,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    final isSelected = showOPDContent && selectedOPDCard == department.toLowerCase();
    final Color departmentColor = HospitalColors.getDepartmentColor(department);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? departmentColor.withOpacity(0.1) : AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: HospitalColors.getModernCardShadow(elevation: isSelected ? 6 : 4),
          border: Border.all(
            color: isSelected ? departmentColor : AppColors.borderColor,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: departmentColor.withOpacity(0.05),
            splashColor: departmentColor.withOpacity(0.1),
            child: Container(
              width: isTablet ? 110 : 90,
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Modern icon with gradient background
                  Container(
                    width: isTablet ? 56 : 44,
                    height: isTablet ? 56 : 44,
                    decoration: BoxDecoration(
                      gradient: HospitalColors.getModernGradient(departmentColor),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: departmentColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: isTablet ? 28 : 22,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: isTablet ? 16 : 12),

                  // Modern title with better typography
                  Text(
                    title,
                    style: HospitalColors.getModernTextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? departmentColor : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}