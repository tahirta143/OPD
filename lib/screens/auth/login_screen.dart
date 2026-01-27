// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Your specified purple colors
  final Color _primaryColor = const Color(0xFF8B5CF6);
  final Color _secondaryColor = const Color(0xFF7C3AED);
  final Color _accentColor = const Color(0xFF6D28D9);
  final Color _lightPurple = const Color(0xFFEDE9FE);
  final Color _darkPurple = const Color(0xFF4C1D95);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuart,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    //   _showSnackBar('Please fill in all fields', Colors.red.shade400);
    //   return;
    // }
    //
    // if (!_emailController.text.contains('@')) {
    //   _showSnackBar('Please enter a valid email', Colors.orange.shade400);
    //   return;
    // }
    //flutter
    // setState(() => _isLoading = true);
    //
    // // Simulate API call
    // await Future.delayed(const Duration(seconds: 2));
    //
    // setState(() => _isLoading = false);

    // Navigate to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AttractiveHealthDashboard(),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;
    final padding = isTablet ? 40.0 : 24.0;
    final buttonHeight = isTablet ? 65.0 : 58.0;
    final cardPadding = isTablet ? 40.0 : 30.0;
    final logoSize = isTablet ? 140.0 : 110.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Background layers using Stack
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryColor.withOpacity(0.95),
                        _secondaryColor.withOpacity(0.95),
                        _accentColor.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Animated floating circles - Multiple layers
              ..._buildFloatingElements(size),

              // Decorative elements
              Positioned(
                top: size.height * 0.05,
                left: size.width * 0.05,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: size.height * 0.1,
                right: size.width * 0.1,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: size.width * 0.2,
                    height: size.width * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content stack
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        // Top decorative wave
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: _WaveClipper(),
                            child: Container(
                              height: size.height * 0.15,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Main content column
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: padding,
                              vertical: isLandscape ? 10 : 0,
                            ),
                            child: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: size.height,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Top spacer
                                    if (!isLandscape) SizedBox(height: size.height * 0.10),

                                    // Logo section with Stack
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Outer glow effect
                                        Container(
                                          width: logoSize + 20,
                                          height: logoSize + 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Animated logo container
                                        FadeTransition(
                                          opacity: _animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, -0.3),
                                              end: Offset.zero,
                                            ).animate(_controller),
                                            child: Container(
                                              width: logoSize,
                                              height: logoSize,
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _lightPurple,
                                                    Colors.white,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _darkPurple.withOpacity(0.3),
                                                    blurRadius: 30,
                                                    spreadRadius: 3,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _primaryColor.withOpacity(0.15),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    'assets/images/logo.png',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: isTablet ? 22 : 10),

                                    // Title section
                                    FadeTransition(
                                      opacity: _animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, -0.2),
                                          end: Offset.zero,
                                        ).animate(_controller),
                                        child: Column(
                                          children: [
                                            ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    _lightPurple,
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: Text(
                                                'Welcome Back',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 40 : 30,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: -0.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: _darkPurple
                                                          .withOpacity(0.4),
                                                      blurRadius: 15,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: isTablet ? 12 : 6),
                                            Text(
                                              'Sign in to continue your journey',
                                              style: TextStyle(
                                                fontSize: isTablet ? 18 : 16,
                                                color:
                                                Colors.white.withOpacity(0.9),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: isTablet ? 34 : 22),

                                    // Login form card with Stack
                                    FadeTransition(
                                      opacity: _animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.5),
                                          end: Offset.zero,
                                        ).animate(_controller),
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: isTablet
                                                ? 500
                                                : double.infinity,
                                          ),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: isTablet
                                                ? (size.width - 500) / 2
                                                : 0,
                                          ),
                                          child: Stack(
                                            children: [
                                              // Card shadow
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(35),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: _darkPurple
                                                            .withOpacity(0.3),
                                                        blurRadius: 50,
                                                        spreadRadius: 5,
                                                        offset:
                                                        const Offset(0, 25),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Main card
                                              Container(
                                                padding: EdgeInsets.all(cardPadding),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(35),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Form fields
                                                    _buildTextField(
                                                      controller: _emailController,
                                                      label: 'Email Address',
                                                      hintText: 'you@example.com',
                                                      prefixIcon:
                                                      Icons.email_outlined,
                                                      keyboardType:
                                                      TextInputType.emailAddress,
                                                      isTablet: isTablet,
                                                    ),
                                                    SizedBox(
                                                        height: isTablet ? 20 : 16),

                                                    _buildPasswordField(
                                                        isTablet: isTablet),
                                                    SizedBox(
                                                        height: isTablet ? 18 : 14),

                                                    // Remember me & Forgot password
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Transform.scale(
                                                              scale:
                                                              isTablet ? 1.4 : 1.2,
                                                              child: Checkbox(
                                                                value: _rememberMe,
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    _rememberMe =
                                                                    value!;
                                                                  });
                                                                },
                                                                shape:
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      6),
                                                                ),
                                                                fillColor: MaterialStateProperty
                                                                    .resolveWith<
                                                                    Color>(
                                                                      (Set<MaterialState>
                                                                  states) {
                                                                    if (states.contains(
                                                                        MaterialState
                                                                            .selected)) {
                                                                      return _primaryColor;
                                                                    }
                                                                    return Colors
                                                                        .grey
                                                                        .shade300;
                                                                  },
                                                                ),
                                                                side: BorderSide(
                                                                  color: _primaryColor
                                                                      .withOpacity(
                                                                      0.5),
                                                                  width: 2,
                                                                ),
                                                              ),
                                                            ),
                                                            // SizedBox(
                                                            //     width: isTablet
                                                            //         ? 8
                                                            //         : 2),
                                                            Text(
                                                              'Remember me',
                                                              style: TextStyle(
                                                                color: Colors.grey
                                                                    .shade800,
                                                                fontSize: isTablet
                                                                    ? 16
                                                                    : 13,
                                                                fontWeight:
                                                                FontWeight.w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            _showSnackBar(
                                                                'Password reset link sent',
                                                                _primaryColor);
                                                          },
                                                          child: Text(
                                                            'Forgot Password?',
                                                            style: TextStyle(
                                                              color: _primaryColor,
                                                              fontWeight:
                                                              FontWeight.w700,
                                                              fontSize: isTablet
                                                                  ? 16
                                                                  : 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(
                                                        height: isTablet ? 30 : 18),

                                                    // Login button with Stack
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: buttonHeight,
                                                      child: Stack(
                                                        children: [
                                                          // Button background with gradient
                                                          Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              gradient:
                                                              LinearGradient(
                                                                colors: [
                                                                  _primaryColor,
                                                                  _secondaryColor,
                                                                ],
                                                                begin: Alignment
                                                                    .centerLeft,
                                                                end: Alignment
                                                                    .centerRight,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                isTablet ? 22 : 18,
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: _primaryColor
                                                                      .withOpacity(
                                                                      0.4),
                                                                  blurRadius: 20,
                                                                  spreadRadius: 2,
                                                                  offset:
                                                                  const Offset(
                                                                      0, 8),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          // Button content
                                                          Material(
                                                            color: Colors.transparent,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                isTablet
                                                                    ? 22
                                                                    : 18),
                                                            child: InkWell(
                                                              onTap: _isLoading
                                                                  ? null
                                                                  : _login,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                isTablet ? 22 : 18,
                                                              ),
                                                              child: Center(
                                                                child: _isLoading
                                                                    ? SizedBox(
                                                                  width:
                                                                  isTablet
                                                                      ? 32
                                                                      : 26,
                                                                  height:
                                                                  isTablet
                                                                      ? 32
                                                                      : 26,
                                                                  child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                    3,
                                                                    valueColor:
                                                                    AlwaysStoppedAnimation<Color>(
                                                                      Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                )
                                                                    : Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      'Sign In',
                                                                      style:
                                                                      TextStyle(
                                                                        fontSize: isTablet ? 20 : 18,
                                                                        fontWeight: FontWeight.w800,
                                                                        letterSpacing: 0.5,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                        isTablet ? 16 : 12),
                                                                    Icon(
                                                                      Icons
                                                                          .arrow_forward_rounded,
                                                                      size: isTablet
                                                                          ? 26
                                                                          : 22,
                                                                      color:
                                                                      Colors.white,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),


                                                    SizedBox(
                                                        height: isTablet ? 34 : 30),

                                                    // Sign up link
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Don't have an account? ",
                                                          style: TextStyle(
                                                            color: Colors.grey
                                                                .shade700,
                                                            fontSize: isTablet
                                                                ? 16
                                                                : 15,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            _showSnackBar(
                                                                'Navigate to sign up',
                                                                _primaryColor);
                                                          },
                                                          child: Text(
                                                            'Sign up',
                                                            style: TextStyle(
                                                              color: _primaryColor,
                                                              fontWeight:
                                                              FontWeight.w800,
                                                              fontSize: isTablet
                                                                  ? 16
                                                                  : 15,
                                                              decoration:
                                                              TextDecoration
                                                                  .underline,
                                                              decorationColor:
                                                              _primaryColor
                                                                  .withOpacity(
                                                                  0.3),
                                                              decorationThickness:
                                                              2,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Bottom spacer
                                    SizedBox(
                                        height: isTablet ? 40 : 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingElements(Size size) {
    return [
      // Large animated circle
      Positioned(
        top: -size.height * 0.1,
        right: -size.width * 0.1,
        child: Transform.rotate(
          angle: _animation.value * 6.28,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _lightPurple.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.8],
              ),
            ),
          ),
        ),
      ),

      // Medium circle
      Positioned(
        bottom: -size.height * 0.15,
        left: -size.width * 0.15,
        child: Container(
          width: size.width * 0.8,
          height: size.width * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _lightPurple.withOpacity(0.15),
                Colors.transparent,
              ],
              stops: const [0.05, 0.8],
            ),
          ),
        ),
      ),

      // Small animated circle
      Positioned(
        top: size.height * 0.3,
        left: size.width * 0.1,
        child: Transform.scale(
          scale: 0.5 + _animation.value * 0.5,
          child: Container(
            width: size.width * 0.3,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _darkPurple,
            fontSize: isTablet ? 17 : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            // Field background with shadow
            Container(
              height: isTablet ? 65 : 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),

            // Text field
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                color: Colors.black87,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isTablet ? 16 : 14,
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: isTablet ? 16 : 12),
                  child: Icon(
                    prefixIcon,
                    color: _primaryColor,
                    size: isTablet ? 26 : 22,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  borderSide: BorderSide(
                    color: _primaryColor,
                    width: 2.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 22 : 18,
                  vertical: isTablet ? 22 : 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField({required bool isTablet}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: _darkPurple,
            fontSize: isTablet ? 17 : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            // Field background with shadow
            Container(
              height: isTablet ? 65 : 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: TextStyle(
                color: Colors.black87,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isTablet ? 16 : 14,
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: isTablet ? 16 : 12),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: _primaryColor,
                    size: isTablet ? 26 : 22,
                  ),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: isTablet ? 16 : 12),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey.shade600,
                      size: isTablet ? 26 : 22,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  borderSide: BorderSide(
                    color: _primaryColor,
                    width: 2.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 22 : 18,
                  vertical: isTablet ? 22 : 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return Expanded(
      child: Stack(
        children: [
          // Button shadow
          Container(
            height: isTablet ? 60 : 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),

          // Button content
          Container(
            height: isTablet ? 60 : 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.grey.shade700,
                      size: isTablet ? 26 : 22,
                    ),
                    SizedBox(width: isTablet ? 14 : 10),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 17 : 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wave Clipper for decorative wave
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}