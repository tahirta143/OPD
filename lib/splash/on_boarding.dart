
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../screens/auth/login_screen.dart';


class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Introscreens(
      title: "Manage Everything \n  in One Place",
      description:
      "Track operations, manage resources, and monitor performance seamlessly with a centralized ERP system designed to simplify your business workflow.",
      imagePath: "assets/images/img1.jpeg",
    ),
    Introscreens(
      title: "Automate. Optimize. Grow.",
      description:
      "Reduce manual work with smart automation. Streamline processes across departments to save time, reduce errors, and increase productivity",
      imagePath: "assets/images/img2.jpeg",
    ),
    Introscreens(
      title: "Welcome to Your Task System",
      description:
      "Your complete solution for managing operations, improving efficiency, and driving business success—all in one powerful platform",
      imagePath: "assets/images/img3.jpeg",
    ),
  ];
  void _skip() {
    _onFinish();
    _pageController.animateToPage(
      _pages.length - 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
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
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) => _pages[index],
          ),
          _currentIndex == _pages.length - 1
              ? SizedBox.shrink()
              : Positioned(
            bottom: 40,
            left: 20,
            child: TextButton(
              onPressed: _skip,
              child: Text(
                "Skip",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              child: Text(
                _currentIndex == _pages.length - 1 ? "Start" : "Next",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 160,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  dotColor: Colors.grey,
                  activeDotColor: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Introscreens extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  const Introscreens({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 80),
          Image.asset(imagePath, height: 400, width: 300),
          SizedBox(height: 30),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: "Merienda",
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}