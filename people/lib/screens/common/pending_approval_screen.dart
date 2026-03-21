import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../auth/role_selection_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  final String role; // 'ngo' or 'volunteer'

  const PendingApprovalScreen({super.key, required this.role});

  bool get _isNGO => role == 'ngo';

  @override
  Widget build(BuildContext context) {
    final color = _isNGO ? AppTheme.ngoColor : AppTheme.volunteerColor;
    final icon = _isNGO ? Icons.business_rounded : Icons.handshake_rounded;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 48),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Pending Admin Approval',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                _isNGO
                    ? 'Your NGO registration is under review. Admin will verify your documents and approve your account.'
                    : 'Your volunteer application is under review. Admin will verify your details and approve your account.',
                style: const TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Status steps
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    _step('Registration Submitted', true, color),
                    _divider(),
                    _step('Documents Under Review', true, color),
                    _divider(),
                    _step('Admin Approval', false, color),
                    _divider(),
                    _step('Account Activated', false, color),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isNGO ? 'NGO / Organisation' : 'Volunteer',
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.grey,
                    side: const BorderSide(color: AppTheme.borderGrey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String label, bool done, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color : AppTheme.lightGrey,
              border: Border.all(color: done ? color : AppTheme.borderGrey),
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.circle_outlined,
              size: 16,
              color: done ? AppTheme.white : AppTheme.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: done ? AppTheme.primaryDark : AppTheme.grey,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.only(left: 13),
        child: Container(width: 2, height: 12, color: AppTheme.borderGrey),
      );

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }
}
