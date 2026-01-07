import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/role_selection_screen.dart';
import 'donor/donor_dashboard.dart';
import 'ngo/ngo_dashboard.dart';
import 'volunteer/volunteer_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _loadingController;
  late AnimationController _pulseController;
  late AnimationController _iconController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _loadingOpacity;
  late Animation<double> _pulseAnimation;

  // Donation icons to animate
  final List<IconData> _donationIcons = [
    Icons.volunteer_activism,
    Icons.favorite,
    Icons.restaurant,
    Icons.checkroom,
    Icons.attach_money,
    Icons.medical_services,
    Icons.school,
    Icons.home,
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo animation controller (0-2 seconds)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Text animation controller (1-3 seconds)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    // Tagline animation controller (2-4 seconds)
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    // Pulse animation for continuous effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Icon animation controller
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
  }

  void _startAnimationSequence() async {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation after 800ms
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Start tagline animation after 1.5s
    await Future.delayed(const Duration(milliseconds: 700));
    _taglineController.forward();

    // Start loading animation after 2s
    await Future.delayed(const Duration(milliseconds: 500));
    _loadingController.forward();

    // Navigate after 5 seconds total
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    try {
      // Check if user is already logged in
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in, fetch their role from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          final role = userDoc.data()?['role'] as String?;

          Widget destination;
          switch (role) {
            case 'donor':
              destination = const DonorDashboard();
              break;
            case 'ngo':
              destination = const NGODashboard();
              break;
            case 'volunteer':
              destination = const VolunteerDashboard();
              break;
            default:
              // If role is not set or invalid, go to role selection
              destination = const RoleSelectionScreen();
          }

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destination,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
          return;
        }
      }

      // No user logged in, go to role selection
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RoleSelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      // On error, go to role selection
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RoleSelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _loadingController.dispose();
    _pulseController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.white, // Solid white background
        child: SafeArea(
          child: Stack(
            children: [
              // Animated floating icons background
              _buildFloatingIcons(),

              // Main content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Logo
                        _buildAnimatedLogo(),

                        const SizedBox(height: 30),

                        // App Name with animation
                        _buildAppName(),

                        const SizedBox(height: 20),

                        // Tagline with animation
                        _buildTagline(),

                        const SizedBox(height: 60),

                        // Loading indicator
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final size = MediaQuery.of(context).size;
            final progress = (_iconController.value + index * 0.125) % 1.0;
            final x = size.width * (0.1 + (index % 4) * 0.25);
            final y = size.height * (1.2 - progress * 1.4);
            final opacity = (1 - (progress - 0.5).abs() * 2).clamp(0.0, 0.25);

            return Positioned(
              left: x + math.sin(progress * math.pi * 2) * 20,
              top: y,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: progress * math.pi * 2,
                  child: Icon(
                    _donationIcons[index],
                    size: 24.0 + (index % 3) * 8.0,
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value * _pulseAnimation.value,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryDark,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 56,
                color: AppTheme.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return SlideTransition(
      position: _textSlide,
      child: FadeTransition(
        opacity: _textOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'People',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'for People',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: AppTheme.primaryDark.withValues(alpha: 0.7),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return SlideTransition(
      position: _taglineSlide,
      child: FadeTransition(
        opacity: _taglineOpacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppTheme.lightGrey,
          ),
          child: Text(
            'Every act of kindness matters',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.grey,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _loadingOpacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.lightGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryDark,
                ),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
