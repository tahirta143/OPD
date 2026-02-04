import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';

class TealBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final ScrollController? scrollController;
  final bool hideOnScroll;

  const TealBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.scrollController,
    this.hideOnScroll = true, // Set default to true for auto-hide
  }) : super(key: key);

  @override
  State<TealBottomNavigation> createState() => _TealBottomNavigationState();
}

class _TealBottomNavigationState extends State<TealBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 10,
        //     spreadRadius: 2,
        //     offset: Offset(0, -2),
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: DotCurvedBottomNav(
          scrollController: widget.scrollController,
          hideOnScroll: widget.hideOnScroll, // Enable hide on scroll
          indicatorColor: Color(0xFF0F1419),
          backgroundColor: Color(0xFF109A8A),
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.ease,
          selectedIndex: widget.currentIndex,
          indicatorSize: 5,
          borderRadius: 12, // Set to 0 since parent handles border
          height: 70 + MediaQuery.of(context).padding.bottom, // Add safe area
          onTap: widget.onIndexChanged,
          items: [
            Icon(
              Icons.home,
              color: widget.currentIndex == 0 ? Color(0xFF0F1419) : Colors.white,
              size: 26,
            ),
            Icon(
              Icons.health_and_safety,
              color: widget.currentIndex == 1 ? Color(0xFF0F1419) : Colors.white,
              size: 26,
            ),
            Icon(
              Icons.calendar_today,
              color: widget.currentIndex == 2 ? Color(0xFF0F1419) : Colors.white,
              size: 26,
            ),
            Icon(
              Icons.person,
              color: widget.currentIndex == 3 ? Color(0xFF0F1419) : Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}