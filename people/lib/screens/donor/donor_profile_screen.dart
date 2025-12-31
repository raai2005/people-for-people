import 'package:flutter/material.dart';
import '../../models/user_models.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  DonorUser? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _bioController = TextEditingController();
    _occupationController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    DonorUser? user;
    try {
      user = await _authService.getUserProfile() as DonorUser?;
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    if (user == null) {
      debugPrint('No user found, please login.');
    }

    if (mounted) {
      setState(() {
        _currentUser = user;
        _populateControllers();
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_currentUser == null) return;
    _nameController.text = _currentUser!.name;
    _locationController.text = _currentUser!.location;
    _bioController.text = _currentUser!.bio ?? '';
    _occupationController.text = _currentUser!.occupation ?? '';
    _phoneController.text = _currentUser!.phone;
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 3) return '${name.substring(0, 1)}***@${parts[1]}';
    return '${name.substring(0, 3)}***@${parts[1]}';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      // Create updated user with all fields preserved
      final updatedUser = DonorUser(
        id: _currentUser!.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _currentUser!.email,
        location: _locationController.text.trim(),
        verifiedIdUrl: _currentUser!.verifiedIdUrl,
        qualification: _currentUser!.qualification,
        profileImageUrl: _currentUser!.profileImageUrl,
        bio: _bioController.text.trim(),
        occupation: _occupationController.text.trim(),
        isApproved: _currentUser!.isApproved,
        createdAt: _currentUser!.createdAt,
        profileCompletion: _currentUser!.profileCompletion,
        verification: _currentUser!.verification,
        donorProfile: _currentUser!.donorProfile,
      );

      // Update in Firestore using AuthService
      await _authService.updateUserProfile(updatedUser);

      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating profile: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.donorColor),
      );
    }

    if (_currentUser == null) {
      return const Center(child: Text('User not found'));
    }

    // Using ListView for reliable scrolling
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildAboutSection(),
            const SizedBox(height: 20),
            _buildCompletionSection(),
            const SizedBox(height: 20),
            _buildBadgesSection(),
            const SizedBox(height: 20),
            _buildDonationAnalyticsSection(),
            const SizedBox(height: 20),
            _buildProofsSection(),

            if (_isEditing) ...[
              const SizedBox(height: 20),
              _buildCancelButton(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isEditing
            ? _saveProfile
            : () => setState(() => _isEditing = true),
        backgroundColor: AppTheme.donorColor,
        icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
        label: Text(
          _isEditing ? 'Save Changes' : 'Edit Profile',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 1. Profile Header
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.donorColor, width: 2),
                  image: _currentUser!.profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_currentUser!.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppTheme.white.withValues(alpha: 0.1),
                ),
                child: _currentUser!.profileImageUrl == null
                    ? const Icon(Icons.person, size: 50, color: AppTheme.white)
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.donorColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Info Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  TextFormField(
                    controller: _nameController,
                    style: AppTheme.headingSmall,
                    decoration: const InputDecoration(
                      hintText: 'Your Name',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: UnderlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                else
                  Text(_currentUser!.name, style: AppTheme.headingSmall),
                const SizedBox(height: 8),
                Text(
                  _maskEmail(_currentUser!.email),
                  style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.donorColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.donorColor),
                  ),
                  child: const Text(
                    'Role: Donor',
                    style: TextStyle(
                      color: AppTheme.donorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Member Since ${_currentUser!.createdAt.year}',
                  style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. About (View More)
  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('About', style: AppTheme.headingSmall),
              Text(
                'View More',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditing)
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write a short bio...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            )
          else
            Text(
              _currentUser!.bio?.isNotEmpty == true
                  ? _currentUser!.bio!
                  : 'No bio added yet.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.school,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Education / Motivation: ${_currentUser!.qualification}',
                  style: AppTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Profile Completion & Verification
  Widget _buildCompletionSection() {
    // Use actual verification data from user model
    final bool emailVerified = _currentUser!.verification.email;
    final bool phoneVerified = _currentUser!.verification.phone;
    final bool govtVerified = _currentUser!.verification.governmentId;

    int completedSteps = 0;
    if (emailVerified) completedSteps++;
    if (phoneVerified) completedSteps++;
    if (govtVerified) completedSteps++;
    if (_currentUser!.bio?.isNotEmpty == true) completedSteps++;

    double completion = (completedSteps / 4);

    return Container(
      padding: const EdgeInsets.all(20),
      // Use a border color warning if incomplete?
      decoration: AppTheme.cardDecoration.copyWith(
        border: completion < 0.7
            ? Border.all(color: AppTheme.warning.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Profile Completion & Verification',
                style: AppTheme.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie Chart
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: completion,
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      color: completion >= 0.7
                          ? AppTheme.success
                          : AppTheme.warning,
                    ),
                    Center(
                      child: Text(
                        '${(completion * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Checklist with Verify Buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckItemWithButton(
                      'Email Verified',
                      emailVerified,
                      onVerify: emailVerified ? null : _verifyEmail,
                    ),
                    _buildCheckItemWithButton(
                      'Phone Verified',
                      phoneVerified,
                      onVerify: phoneVerified ? null : _verifyPhone,
                    ),
                    _buildCheckItem('Govt ID Verified (Admin)', govtVerified),
                    if (completion < 0.7)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '⚠ 70% required to donate',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItemWithButton(
    String label,
    bool isChecked, {
    VoidCallback? onVerify,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isChecked ? AppTheme.success : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          if (onVerify != null)
            TextButton(
              onPressed: onVerify,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isChecked ? AppTheme.success : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Verification Methods
  Future<void> _verifyEmail() async {
    // TODO: Implement email verification flow
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Verify Email',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'A verification link has been sent to your email address. Please check your inbox and click the link to verify.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPhone() async {
    // TODO: Implement phone verification flow
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Verify Phone',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'An OTP has been sent to your phone number. Please enter the code to verify.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  // 4. Badges
  Widget _buildBadgesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Badges', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildBadgeChip(
                'Email Verified',
                Icons.mark_email_read,
                AppTheme.info,
              ),
              _buildBadgeChip(
                'Phone Verified',
                Icons.phone_android,
                AppTheme.purple,
              ),
              _buildBadgeChip('Trusted Donor', Icons.verified, AppTheme.gold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Donation Analytics (Mock)
  Widget _buildDonationAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Donation Analytics', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          // Mock Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Total Donations',
                '₹ 12,500',
                Icons.monetization_on,
              ),
              _buildStatItem('Donations', '15', Icons.volunteer_activism),
              _buildStatItem('Impact', 'High', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '• Types of Donations: Money, Food, Clothes',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Impact Summary: Helped 50+ people',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.donorColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  // 6. Proofs & History (Mock)
  Widget _buildProofsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Proofs & History', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          _buildProofLink('Donation Photos', 12),
          _buildProofLink('Receipts / Certificates', 5),
          _buildProofLink('NGO Feedback', 8),
        ],
      ),
    );
  }

  Widget _buildProofLink(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder_open,
              color: AppTheme.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          Text(
            '$count items',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white30),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _isEditing = false;
            _populateControllers(); // Reset changes
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.white.withValues(alpha: 0.5)),
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Cancel Editing'),
      ),
    );
  }
}
