import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_models.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  final List<Map<String, dynamic>> _roles = [
    {
      'role': UserRole.ngo,
      'title': 'NGO / Organisation',
      'subtitle': 'Register your organisation to receive donations',
      'icon': Icons.business_rounded,
      'color': AppTheme.ngoColor,
    },
    {
      'role': UserRole.donor,
      'title': 'Donor',
      'subtitle': 'Contribute food, clothes, money or resources',
      'icon': Icons.volunteer_activism_rounded,
      'color': AppTheme.donorColor,
    },
    {
      'role': UserRole.volunteer,
      'title': 'Volunteer',
      'subtitle': 'Help connect donors with those in need',
      'icon': Icons.people_alt_rounded,
      'color': AppTheme.volunteerColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onRoleSelected(UserRole role) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(selectedRole: role),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white, // Explicit white background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // decoration: const BoxDecoration(gradient: AppTheme.primaryGradient), // Removed gradient
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 50),

                  // Role Cards
                  ...List.generate(_roles.length, (index) {
                    return SlideTransition(
                      position: _slideAnimations[index],
                      child: _buildRoleCard(_roles[index], index),
                    );
                  }),

                  const SizedBox(height: 30),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryDark,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 32,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          'People for People',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'How would you like to contribute?',
          style: TextStyle(fontSize: 15, color: AppTheme.grey),
        ),
      ],
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> roleData, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onRoleSelected(roleData['role']),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderGrey,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (roleData['color'] as Color).withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    roleData['icon'],
                    size: 24,
                    color: roleData['color'] as Color,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleData['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        roleData['subtitle'],
                        style: TextStyle(fontSize: 13, color: AppTheme.grey),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: AppTheme.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Making a difference, together',
      style: TextStyle(
        fontSize: 12,
        color: AppTheme.grey.withValues(alpha: 0.7),
        letterSpacing: 0.3,
      ),
    );
  }
}
