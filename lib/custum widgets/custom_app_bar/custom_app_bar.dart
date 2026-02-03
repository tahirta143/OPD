// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import '../colors/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hospitalName;
  final String department;
  final int notificationCount;
  final int patientCount;
  final int appointmentCount;
  final String? profileImageUrl;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onDrawerPressed;

  const CustomAppBar({
    Key? key,
    this.hospitalName = "MediCare Central",
    this.department = "Administration",
    this.notificationCount = 3,
    this.patientCount = 24,
    this.appointmentCount = 8,
    this.profileImageUrl,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.onDrawerPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLargeScreen = size.width > 1200;
    final isMediumScreen = size.width > 768;
    final isSmallScreen = size.width <= 768;

    final now = DateTime.now();
    final formattedDate = '${_getWeekday(now.weekday)} ${now.day} ${_getMonth(now.month)}';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Color(0xFF109A8A), // Primary color
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2EC1B1).withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : isMediumScreen ? 24 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Drawer Button and Hospital Info
                Row(
                  children: [
                    // Drawer Button
                    IconButton(
                      onPressed: onDrawerPressed ?? () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: isLargeScreen ? 28 : isMediumScreen ? 26 : 24,
                      ),
                    ),

                    SizedBox(width: isMediumScreen ? 20 : 16),

                    // Hospital Info
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospitalName,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : isMediumScreen ? 20 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMediumScreen ? 16 : 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            department.toUpperCase(),
                            style: TextStyle(
                              fontSize: isMediumScreen ? 12 : 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Center: Quick Stats (Hidden on small screens)
                if (isMediumScreen)
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(
                              icon: Icons.people,
                              value: patientCount.toString(),
                              label: 'Patients',
                              iconColor: Colors.white,
                            ),
                            SizedBox(width: 24),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            SizedBox(width: 24),
                            _buildStatItem(
                              icon: Icons.calendar_today,
                              value: appointmentCount.toString(),
                              label: 'Appointments',
                              iconColor: Colors.white,
                            ),
                            SizedBox(width: 24),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            SizedBox(width: 24),
                            _buildStatItem(
                              icon: Icons.today,
                              value: formattedDate,
                              label: 'Today',
                              iconColor: Colors.white,
                              isDate: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Right: User Actions
                Row(
                  children: [
                    // Notifications
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: onNotificationsPressed ?? () {},
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: isLargeScreen ? 26 : isMediumScreen ? 24 : 22,
                          ),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: isMediumScreen ? 8 : 4),

                    // User Profile
                    Container(
                      width: isLargeScreen ? 50 : isMediumScreen ? 46 : 42,
                      height: isLargeScreen ? 50 : isMediumScreen ? 46 : 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profileImageUrl != null
                            ? Image.network(
                          profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackAvatar(),
                        )
                            : _buildFallbackAvatar(),
                      ),
                    ).asClickable(onProfilePressed ?? () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: Color(0xFF2EC1B1).withOpacity(0.8),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    bool isDate = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isDate ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
}

// Extension for clickable widgets with ripple effect
extension ClickableExtension on Widget {
  Widget asClickable(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: this,
      ),
    );
  }
}