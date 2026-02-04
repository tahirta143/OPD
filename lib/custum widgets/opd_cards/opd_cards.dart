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
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final isLargeDesktop = size.width >= 1400;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Dynamic spacing based on screen
    final double horizontalPadding = isMobile ? 16 : (isTablet ? 20 : 24);
    final double verticalPadding = isMobile ? 16 : (isTablet ?20 : 24);
    final double cardSpacing = isMobile ? 12 : (isTablet ? 16 : 20);
    final double cardWidth = isMobile ? 100 : (isTablet ? 120 : (isDesktop ? 140 : 160));
    final double cardHeight = isMobile ? 120 : (isTablet ? 140 : (isDesktop ? 160 : 180));
    final double iconSize = isMobile ? 22 : (isTablet ? 28 : (isDesktop ? 32 : 36));
    final double fontSizeTitle = isMobile ? 12 : (isTablet ? 14 : (isDesktop ? 16 : 18));
    final double fontSizeHeader = isMobile ? 18 : (isTablet ? 22 : (isDesktop ? 26 : 30));

    return Container(
      width: size.width,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital Departments',
                      style: TextStyle(
                        fontSize: fontSizeHeader,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: isDesktop ? -0.8 : -0.5,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      'Select a department to view details',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : (isTablet ? 12 : 14),
                        color: AppColors.textSecondary.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                if (isDesktop && !isMobile)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeDesktop ? 20 : 16,
                      vertical: isLargeDesktop ? 10 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: isLargeDesktop ? 18 : 16,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: isLargeDesktop ? 12 : 8),
                        Text(
                          '${_getActiveDepartmentsCount()} departments',
                          style: TextStyle(
                            fontSize: isLargeDesktop ? 14 : 13,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 16 : (isTablet ? 24 : 28)),

          // Responsive Cards Container
          Container(
            height: isLandscape ? cardHeight * 0.8 : cardHeight,
            width: size.width,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final bool showSingleRow = availableWidth > cardWidth * 5 + cardSpacing * 6;
                final bool showCompactView = availableWidth < cardWidth * 3.5;

                return ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: _buildDepartmentCards(
                    isMobile: isMobile,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    isLargeDesktop: isLargeDesktop,
                    isLandscape: isLandscape,
                    showCompactView: showCompactView,
                    showSingleRow: showSingleRow,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    fontSizeTitle: fontSizeTitle,
                    cardSpacing: cardSpacing,
                  ),
                );
              },
            ),
          ),

          // Second row for large screens
          if ((isDesktop || (isTablet && isLandscape)) && !isMobile)
            SizedBox(height: 20),

          if ((isDesktop || (isTablet && isLandscape)) && !isMobile)
            Container(
              height: cardHeight,
              width: size.width,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    children: _buildSecondaryDepartmentCards(
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isLargeDesktop: isLargeDesktop,
                      isLandscape: isLandscape,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      iconSize: iconSize,
                      fontSizeTitle: fontSizeTitle,
                      cardSpacing: cardSpacing,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDepartmentCards({
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isLargeDesktop,
    required bool isLandscape,
    required bool showCompactView,
    required bool showSingleRow,
    required double cardWidth,
    required double cardHeight,
    required double iconSize,
    required double fontSizeTitle,
    required double cardSpacing,
  }) {
    final departments = [
      _DepartmentInfo('OPD', Icons.medical_services_outlined, 'opd', onOPDTap),
      _DepartmentInfo('Indoor', Icons.bed_outlined, 'indoor', () => onOPDCardTap('indoor')),
      _DepartmentInfo('Lab', Icons.science_outlined, 'laboratory', () => onOPDCardTap('laboratory')),
      _DepartmentInfo('Pharmacy', Icons.medication_liquid_outlined, 'pharmacy', () => onOPDCardTap('pharmacy')),
      _DepartmentInfo('Store', Icons.inventory_2_outlined, 'store', () => onOPDCardTap('store')),
    ];

    // Add more departments for larger screens
    if (isTablet && !isMobile) {
      departments.addAll([
        _DepartmentInfo('Staff', Icons.people_alt_outlined, 'staff', () => onOPDCardTap('staff')),
        _DepartmentInfo('Finance', Icons.account_balance_wallet_outlined, 'finance', () => onOPDCardTap('finance')),
      ]);
    }

    if (isDesktop) {
      departments.addAll([
        _DepartmentInfo('Emergency', Icons.emergency_outlined, 'emergency', () => onOPDCardTap('emergency')),
        _DepartmentInfo('Radiology', Icons.radio, 'radiology', () => onOPDCardTap('radiology')),
      ]);
    }

    List<Widget> cards = [];

    // Add initial spacing
    cards.add(SizedBox(width: isMobile ? 4 : 8));

    for (int i = 0; i < departments.length; i++) {
      final dept = departments[i];
      cards.add(
        _buildResponsiveDepartmentCard(
          title: dept.title,
          icon: dept.icon,
          department: dept.department,
          onTap: dept.onTap,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          iconSize: iconSize,
          fontSizeTitle: fontSizeTitle,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
          isLargeDesktop: isLargeDesktop,
          isSelected: showOPDContent && selectedOPDCard == dept.department,
        ),
      );

      // Add spacing between cards, but less on mobile
      if (i < departments.length - 1) {
        cards.add(SizedBox(width: cardSpacing));
      }
    }

    // Add ending spacing
    cards.add(SizedBox(width: isMobile ? 4 : 8));

    return cards;
  }

  List<Widget> _buildSecondaryDepartmentCards({
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isLargeDesktop,
    required bool isLandscape,
    required double cardWidth,
    required double cardHeight,
    required double iconSize,
    required double fontSizeTitle,
    required double cardSpacing,
  }) {
    if (isMobile) return [];

    final departments = [
      _DepartmentInfo('ICU', Icons.coronavirus_outlined, 'icu', () => onOPDCardTap('icu')),
      _DepartmentInfo('Surgery', Icons.health_and_safety_outlined, 'surgery', () => onOPDCardTap('surgery')),
      _DepartmentInfo('Pediatrics', Icons.child_care_outlined, 'pediatrics', () => onOPDCardTap('pediatrics')),
      _DepartmentInfo('Cardiology', Icons.favorite_outline, 'cardiology', () => onOPDCardTap('cardiology')),
      _DepartmentInfo('Neurology', Icons.memory_outlined, 'neurology', () => onOPDCardTap('neurology')),
    ];

    if (isDesktop) {
      departments.addAll([
        _DepartmentInfo('Orthopedics', Icons.accessible_outlined, 'orthopedics', () => onOPDCardTap('orthopedics')),
        _DepartmentInfo('Dental', Icons.perm_identity, 'dental', () => onOPDCardTap('dental')),
      ]);
    }

    List<Widget> cards = [];

    cards.add(SizedBox(width: isTablet ? 8 : 12));

    for (int i = 0; i < departments.length; i++) {
      final dept = departments[i];
      cards.add(
        _buildResponsiveDepartmentCard(
          title: dept.title,
          icon: dept.icon,
          department: dept.department,
          onTap: dept.onTap,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          iconSize: iconSize,
          fontSizeTitle: fontSizeTitle,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
          isLargeDesktop: isLargeDesktop,
          isSelected: showOPDContent && selectedOPDCard == dept.department,
        ),
      );

      if (i < departments.length - 1) {
        cards.add(SizedBox(width: cardSpacing));
      }
    }

    cards.add(SizedBox(width: isTablet ? 8 : 12));

    return cards;
  }

  Widget _buildResponsiveDepartmentCard({
    required String title,
    required IconData icon,
    required String department,
    required VoidCallback onTap,
    required double cardWidth,
    required double cardHeight,
    required double iconSize,
    required double fontSizeTitle,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required bool isLargeDesktop,
    required bool isSelected,
  }) {
    final Color departmentColor = HospitalColors.getDepartmentColor(department);

    // Adjust title based on screen size
    final String displayTitle = _getAdjustedTitle(title, isMobile, isTablet, isDesktop);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: isMobile ? 300 : 400),
          curve: Curves.easeInOut,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [
                departmentColor.withOpacity(0.2),
                departmentColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [
                Colors.white.withOpacity(isMobile ? 0.95 : 0.9),
                Colors.white.withOpacity(isMobile ? 0.85 : 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isMobile ? 14 : (isDesktop ? 20 : 18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isMobile ? 0.08 : 0.1),
                blurRadius: isMobile ? 15 : (isDesktop ? 25 : 20),
                spreadRadius: isMobile ? -3 : -5,
                offset: Offset(0, isMobile ? 6 : 10),
              ),
              BoxShadow(
                color: isSelected ? departmentColor.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: isMobile ? 8 : (isDesktop ? 15 : 12),
                spreadRadius: isMobile ? -1 : -2,
                offset: Offset(0, isMobile ? 3 : 5),
              ),
            ],
            border: Border.all(
              color: isSelected ? departmentColor.withOpacity(0.5) : Colors.white.withOpacity(0.8),
              width: isSelected ? (isMobile ? 2.0 : 2.5) : (isMobile ? 1.2 : 1.5),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 12 : (isDesktop ? 20 : 16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Responsive Icon Container
                Container(
                  width: isMobile ? 40 : (isDesktop ? 60 : 50),
                  height: isMobile ? 40 : (isDesktop ? 60 : 50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        departmentColor.withOpacity(0.9),
                        departmentColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 12 : (isDesktop ? 16 : 14)),
                    boxShadow: [
                      BoxShadow(
                        color: departmentColor.withOpacity(isMobile ? 0.2 : 0.3),
                        blurRadius: isMobile ? 10 : (isDesktop ? 15 : 12),
                        offset: Offset(0, isMobile ? 4 : 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 8 : (isDesktop ? 16 : 12)),

                // Responsive Title
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: fontSizeTitle,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? departmentColor : AppColors.textPrimary,
                    letterSpacing: isDesktop ? -0.3 : -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isMobile ? 4 : (isDesktop ? 8 : 6)),

                // Responsive Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : (isDesktop ? 10 : 8),
                    vertical: isMobile ? 2 : (isDesktop ? 4 : 3),
                  ),
                  decoration: BoxDecoration(
                    color: departmentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                  ),
                  child: Text(
                    isSelected ? 'Active' : 'View',
                    style: TextStyle(
                      fontSize: isMobile ? 9 : (isDesktop ? 11 : 10),
                      fontWeight: FontWeight.w600,
                      color: departmentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAdjustedTitle(String title, bool isMobile, bool isTablet, bool isDesktop) {
    if (isMobile) {
      // Shorten titles for mobile
      if (title.length > 8) {
        return '${title.substring(0, 8)}..';
      }
      return title;
    } else if (isTablet) {
      // Medium titles for tablet
      if (title.length > 12) {
        return '${title.substring(0, 12)}..';
      }
      return title;
    } else {
      // Full titles for desktop
      return title;
    }
  }

  int _getActiveDepartmentsCount() {
    return 12; // You can customize this
  }
}

class _DepartmentInfo {
  final String title;
  final IconData icon;
  final String department;
  final VoidCallback onTap;

  _DepartmentInfo(this.title, this.icon, this.department, this.onTap);
}

