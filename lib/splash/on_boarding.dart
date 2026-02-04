import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../screens/auth/login_screen.dart';

class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color theme using 0xFF109A8A
  final Color _primaryColor = const Color(0xFF109A8A);
  final Color _secondaryColor = const Color(0xFF0B7C6F);
  final Color _accentColor = const Color(0xFF087065);
  final Color _lightTeal = const Color(0xFFE0F2F1);
  final Color _darkTeal = const Color(0xFF004D40);
  final Color _backgroundColor = const Color(0xFFF8FAFC);

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Manage Everything \nin One Place",
      description: "Track operations, manage resources, and monitor performance seamlessly with a centralized ERP system designed to simplify your business workflow.",
      imagePath: "assets/images/img1.jpeg",
      icon: Icons.dashboard_rounded,
    ),
    OnboardingPage(
      title: "Automate. Optimize. Grow.",
      description: "Reduce manual work with smart automation. Streamline processes across departments to save time, reduce errors, and increase productivity.",
      imagePath: "assets/images/img2.jpeg",
      icon: Icons.auto_awesome_rounded,
    ),
    OnboardingPage(
      title: "Welcome to Your Task System",
      description: "Your complete solution for managing operations, improving efficiency, and driving business success—all in one powerful platform.",
      imagePath: "assets/images/img3.jpeg",
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _skip() {
    _onFinish();
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _backgroundColor,
                    _lightTeal.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Floating decorative circles
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -size.height * 0.15,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _secondaryColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Skip button at top
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    right: 24,
                  ),
                  child: _currentIndex == _pages.length - 1
                      ? const SizedBox.shrink()
                      : TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _animationController.reset();
                      _animationController.forward();
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildOnboardingPage(page, size, isTablet),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom section with indicators and button
              _buildBottomSection(size, isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, Size size, bool isTablet) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.05),

          // Image container with decoration
          Container(
            width: isTablet ? size.width * 0.5 : size.width * 0.7,
            height: isTablet ? size.width * 0.5 : size.width * 0.7,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _lightTeal,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          SizedBox(height: isTablet ? 40 : 30),

          // Icon badge
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                page.icon,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          SizedBox(height: 30),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 60 : 30,
            ),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 32 : 26,
                fontWeight: FontWeight.w800,
                color: _darkTeal,
                letterSpacing: -0.5,
                height: 1.3,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 80 : 40,
            ),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(Size size, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 24,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: _primaryColor,
              dotColor: Colors.grey[300]!,
              expansionFactor: 3,
              spacing: 10,
            ),
          ),

          SizedBox(height: 26),

          // Next/Start button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 65 : 58,
            child: Stack(
              children: [
                // Button background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryColor,
                        _secondaryColor,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),

                // Button content
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  child: InkWell(
                    onTap: _onNext,
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _pages.length - 1
                                ? "Get Started"
                                : "Continue",
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            _currentIndex == _pages.length - 1
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: isTablet ? 26 : 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Progress indicator
          SizedBox(
            width: size.width * 0.6,
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _pages.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              minHeight: 3,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: 1),

          // Text(
          //   "Step ${_currentIndex + 1} of ${_pages.length}",
          //   style: TextStyle(
          //     color: Colors.grey[600],
          //     fontSize: 14,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}