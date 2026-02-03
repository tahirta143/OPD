// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isTablet;
  final String hospitalName;
  final String department;
  final int notificationCount;

  const CustomAppBar({
    Key? key,
    required this.isTablet,
    this.hospitalName = "MediCare Central",
    this.department = "Administration",
    this.notificationCount = 3,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(isTablet ? 100 : 85);

  @override
  Widget build(BuildContext context) {
    final timeOfDay = _getTimeOfDay();
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor, // Deep blue
              Color(0xFF0052D4), // Medical blue
              AppColors.accentColor.withOpacity(0.9), // Teal accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Hospital Logo and Info
                Row(
                  children: [
                    // Hospital Logo/Icon
                    Container(
                      width: isTablet ? 52 : 44,
                      height: isTablet ? 52 : 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.medical_services_outlined,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    
                    // Hospital Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hospitalName,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            department,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Center: Welcome Message
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getTimeOfDayIcon(timeOfDay),
                              color: Colors.white.withOpacity(0.9),
                              size: isTablet ? 18 : 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '$timeOfDay, ',
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Dr. Anderson',
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getWelcomeMessage(timeOfDay),
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right side: Actions
                Row(
                  children: [
                    // Emergency Button
                    Container(
                      margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Handle emergency
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 16 : 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.emergency_outlined,
                                  color: Colors.white,
                                  size: isTablet ? 16 : 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'EMERGENCY',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Notifications with Badge
                    Stack(
                      children: [
                        Container(
                          width: isTablet ? 46 : 40,
                          height: isTablet ? 46 : 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: isTablet ? 22 : 20,
                            ),
                          ),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: isTablet ? 6 : 4,
                            top: isTablet ? 6 : 4,
                            child: Container(
                              width: isTablet ? 20 : 18,
                              height: isTablet ? 20 : 18,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  notificationCount > 9 ? '9+' : '$notificationCount',
                                  style: TextStyle(
                                    fontSize: isTablet ? 10 : 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: isTablet ? 12 : 8),

                    // Profile with Status Indicator
                    Stack(
                      children: [
                        Container(
                          width: isTablet ? 52 : 44,
                          height: isTablet ? 52 : 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&h=200&fit=crop',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: isTablet ? 14 : 12,
                            height: isTablet ? 14 : 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  IconData _getTimeOfDayIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return Icons.wb_sunny_outlined;
      case 'Afternoon':
        return Icons.light_mode_outlined;
      case 'Evening':
        return Icons.nights_stay_outlined;
      default:
        return Icons.access_time_outlined;
    }
  }

  String _getWelcomeMessage(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return 'Ready for today\'s patients';
      case 'Afternoon':
        return 'Keep up the great work';
      case 'Evening':
        return 'Night shift activated';
      default:
        return 'Hospital Dashboard';
    }
  }
}