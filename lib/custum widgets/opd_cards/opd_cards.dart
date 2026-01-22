// lib/widgets/opd_cards.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class OPDCards extends StatelessWidget {
  final bool isTablet;
  final bool showOPDContent;
  final String? selectedOPDCard;
  final Function(String) onOPDCardTap;
  final Function() onOPDTap;

  const OPDCards({
    Key? key,
    required this.isTablet,
    required this.showOPDContent,
    required this.selectedOPDCard,
    required this.onOPDCardTap,
    required this.onOPDTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
          child: Text(
            'OPD Cards',
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Scrollable Cards Row
        SizedBox(
          height: isTablet ? 120 : 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(width: isTablet ? 8 : 4),

              // OPD Card
              _buildOPDCard(
                title: 'OPD',
                icon: Icons.local_hospital,
                bgColor: const Color(0xFFFCE7F3),
                iconColor: AppColors.dangerColor,
                onTap: onOPDTap,
              ),  SizedBox(width: isTablet ? 16 : 12),
              // Indoor Card
              _buildOPDCard(
                title: 'Indoor',
                icon: Icons.home,
                bgColor: AppColors.lightIndigo,
                iconColor: AppColors.primaryColor,
                onTap: () => onOPDCardTap('Indoor'),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Laboratory Card
              _buildOPDCard(
                title: 'Laboratory',
                icon: Icons.science,
                bgColor: const Color(0xFFFCE7F3),
                iconColor: AppColors.accentColor,
                onTap: () => onOPDCardTap('Laboratory'),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Pharmacy Card
              _buildOPDCard(
                title: 'Pharmacy',
                icon: Icons.medication,
                bgColor: const Color(0xFFCCFBF1),
                iconColor: AppColors.successColor,
                onTap: () => onOPDCardTap('Pharmacy'),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Store Card
              _buildOPDCard(
                title: 'Store',
                icon: Icons.store,
                bgColor: AppColors.lightIndigo,
                iconColor: AppColors.infoColor,
                onTap: () => onOPDCardTap('Store'),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Payroll Card
              _buildOPDCard(
                title: 'Payroll',
                icon: Icons.payments,
                bgColor: const Color(0xFFFCE7F3),
                iconColor: AppColors.warningColor,
                onTap: () => onOPDCardTap('Payroll'),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Account Card
              _buildOPDCard(
                title: 'Account',
                icon: Icons.account_balance,
                bgColor: const Color(0xFFCCFBF1),
                iconColor: AppColors.tealColor,
                onTap: () => onOPDCardTap('Account'),
              ),




              SizedBox(width: isTablet ? 8 : 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOPDCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isSelected = showOPDContent && selectedOPDCard == title.toLowerCase();

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? iconColor.withOpacity(0.1) : bgColor,
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: isTablet ? 100 : 85,
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isTablet ? 48 : 40,
                  height: isTablet ? 48 : 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: isTablet ? 24 : 20,
                    color: iconColor,
                  ),
                ),

                SizedBox(height: isTablet ? 12 : 8),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
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
}