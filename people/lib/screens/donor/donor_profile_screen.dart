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

  // 5. Donation History & Analytics
  Widget _buildDonationAnalyticsSection() {
    final recentDonations = _getRecentDonations();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Donation History', style: AppTheme.headingSmall),
              TextButton(
                onPressed: _showAllDonations,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.donorColor.withValues(alpha: 0.2),
                  AppTheme.donorColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.donorColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactStat('₹25,000', 'Total', Icons.attach_money),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.white.withValues(alpha: 0.2),
                ),
                _buildCompactStat('15', 'Donations', Icons.card_giftcard),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.white.withValues(alpha: 0.2),
                ),
                _buildCompactStat('50+', 'Lives', Icons.favorite),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Recent Donations List
          ...recentDonations.map(
            (donation) => _buildDonationHistoryItem(
              donation['title'] as String,
              donation['ngo'] as String,
              donation['type'] as String,
              donation['amount'] as String?,
              donation['quantity'] as int?,
              donation['date'] as String,
              donation['status'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.donorColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDonationHistoryItem(
    String title,
    String ngo,
    String type,
    String? amount,
    int? quantity,
    String date,
    String status,
  ) {
    final typeColor = _getDonationTypeColor(type);
    final typeIcon = _getDonationTypeIcon(type);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Type Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: typeColor.withValues(alpha: 0.3)),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 12,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ngo,
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 11,
                      color: AppTheme.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount/Quantity
          if (amount != null)
            Text(
              amount,
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (quantity != null)
            Text(
              '$quantity',
              style: TextStyle(
                color: typeColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Color _getDonationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'money':
        return AppTheme.success;
      case 'clothes':
        return AppTheme.volunteerColor;
      case 'food':
        return AppTheme.gold;
      case 'books':
        return AppTheme.info;
      case 'medical':
        return AppTheme.accent;
      default:
        return AppTheme.donorColor;
    }
  }

  IconData _getDonationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'money':
        return Icons.attach_money;
      case 'clothes':
        return Icons.checkroom;
      case 'food':
        return Icons.restaurant;
      case 'books':
        return Icons.menu_book;
      case 'medical':
        return Icons.medical_services;
      default:
        return Icons.card_giftcard;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'in progress':
        return AppTheme.info;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getRecentDonations() {
    return [
      {
        'title': 'Monthly Donation',
        'type': 'Money',
        'ngo': 'Hope Foundation',
        'amount': '₹5,000',
        'date': 'Dec 28, 2024',
        'status': 'Completed',
      },
      {
        'title': 'Winter Clothes',
        'type': 'Clothes',
        'ngo': 'Care India',
        'quantity': 25,
        'date': 'Dec 25, 2024',
        'status': 'In Progress',
      },
      {
        'title': 'Food Donation',
        'type': 'Food',
        'ngo': 'Feeding India',
        'quantity': 50,
        'date': 'Dec 20, 2024',
        'status': 'Completed',
      },
    ];
  }

  void _showAllDonations() {
    // TODO: Navigate to full donation history or show modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full donation history coming soon!'),
        backgroundColor: AppTheme.info,
      ),
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
