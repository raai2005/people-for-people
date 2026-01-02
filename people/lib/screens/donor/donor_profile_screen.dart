import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_models.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../theme/app_theme.dart';
import '../auth/role_selection_screen.dart';
import 'package:file_picker/file_picker.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  DonorUser? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUploadingImage = false;
  bool _viewingAsPublic = false; // Toggle between private and public view
  bool _isBioExpanded = false; // Track if bio is expanded

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
      // Create updated donorProfile with synced fields
      final updatedDonorProfile = DonorProfile(
        bio: _bioController.text.trim(),
        occupation: _occupationController.text.trim(),
        location: _locationController.text.trim(),
        profileImage: _currentUser!.donorProfile.profileImage,
        badges: _currentUser!.donorProfile.badges,
        donationCount: _currentUser!.donorProfile.donationCount,
        rating: _currentUser!.donorProfile.rating,
      );

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
        donorProfile: updatedDonorProfile,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _viewingAsPublic ? 'Public Profile' : 'My Profile',
          style: const TextStyle(color: AppTheme.white),
        ),
        actions: [
          // Toggle between private and public view
          TextButton.icon(
            onPressed: () {
              setState(() => _viewingAsPublic = !_viewingAsPublic);
            },
            icon: Icon(
              _viewingAsPublic ? Icons.lock_open : Icons.visibility,
              color: AppTheme.accent,
              size: 20,
            ),
            label: Text(
              _viewingAsPublic ? 'My View' : 'Public View',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
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
            _buildCertificatesMemoriesSection(),

            // Private sections - only visible in private view
            if (!_viewingAsPublic) ...[
              const SizedBox(height: 20),
              _buildCompletionSection(),
              const SizedBox(height: 20),
              _buildBadgesSection(),
              const SizedBox(height: 20),
              _buildDonationAnalyticsSection(),
            ] else ...[
              const SizedBox(height: 20),
              _buildBadgesSection(),
            ],

            if (_isEditing) ...[
              const SizedBox(height: 20),
              _buildCancelButton(),
            ],

            // Logout button - only in My View
            if (!_viewingAsPublic) ...[
              const SizedBox(height: 20),
              _buildLogoutButton(),
            ],
          ],
        ),
      ),
      floatingActionButton: !_viewingAsPublic
          ? FloatingActionButton.extended(
              onPressed: _isEditing
                  ? _saveProfile
                  : () => setState(() => _isEditing = true),
              backgroundColor: AppTheme.donorColor,
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: Colors.white,
              ),
              label: Text(
                _isEditing ? 'Save Changes' : 'Edit Profile',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
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
          GestureDetector(
            onTap: _isEditing ? _pickAndUploadImage : null,
            child: Stack(
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
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.white,
                        )
                      : null,
                ),
                // Loading overlay
                if (_isUploadingImage)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.donorColor,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                // Camera icon badge
                if (_isEditing && !_isUploadingImage)
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
    final bioText = _currentUser!.bio?.isNotEmpty == true
        ? _currentUser!.bio!
        : 'No bio added yet.';
    final bioLines = '\n'.allMatches(bioText).length + 1;
    final shouldShowReadMore = bioLines > 3 && bioText != 'No bio added yet.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About', style: AppTheme.headingSmall),
          const SizedBox(height: 12),
          if (_isEditing)
            TextFormField(
              controller: _bioController,
              maxLines: 5,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write your bio...',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bioText,
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                  maxLines: _isBioExpanded ? null : 3,
                  overflow: _isBioExpanded ? null : TextOverflow.ellipsis,
                ),
                if (shouldShowReadMore) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isBioExpanded = !_isBioExpanded);
                    },
                    child: Text(
                      _isBioExpanded ? 'Read Less' : 'Read More',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
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

  // Certificates & Memories Section
  Widget _buildCertificatesMemoriesSection() {
    // TODO: Fetch certificates and photos from Firestore
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Certificates & Memories',
                style: AppTheme.headingSmall,
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full gallery coming soon!'),
                      backgroundColor: AppTheme.info,
                    ),
                  );
                },
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
          _buildCertificatesPreview(),
          const SizedBox(height: 20),
          _buildMemoriesPreview(),
        ],
      ),
    );
  }

  Widget _buildCertificatesPreview() {
    // TODO: Fetch from Firestore - donation certificates
    final hasCertificates = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppTheme.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Donation Certificates',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Add button
            if (!_viewingAsPublic)
              GestureDetector(
                onTap: _showCertificateUploadDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppTheme.gold, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasCertificates)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppTheme.white.withValues(alpha: 0.3),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No certificates yet',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Certificates will appear here after donations',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemoriesPreview() {
    // TODO: Fetch from Firestore - donation photos/memories
    final hasMemories = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppTheme.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Donation Memories',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Add button
            if (!_viewingAsPublic)
              GestureDetector(
                onTap: _showMemoryUploadDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppTheme.accent, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasMemories)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    color: AppTheme.white.withValues(alpha: 0.3),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No memories yet',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photos and memories will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorSnackbar('No user logged in');
        return;
      }

      // Check if email is already verified
      await user.reload();
      if (user.emailVerified) {
        // Update Firestore
        final authService = AuthService();
        await authService.updateUserFields(user.uid, {
          'verification.email': true,
        });

        // Reload current user data
        await _loadUserData();

        _showSuccessSnackbar('Email is already verified!');
        return;
      }

      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );

      // Send verification email
      await user.sendEmailVerification();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  color: AppTheme.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Verify Email', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A verification link has been sent to:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: AppTheme.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.email ?? '',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your inbox and click the verification link. After verifying, click "Check Status" below.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _checkEmailVerificationStatus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Check Status'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String errorMessage = 'Failed to send verification email';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }

      _showErrorSnackbar(errorMessage);
    }
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorSnackbar('No user logged in');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );

      // Reload user to get latest verification status
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      // Close loading
      if (mounted) Navigator.pop(context);

      if (updatedUser?.emailVerified == true) {
        // Update Firestore
        final authService = AuthService();
        await authService.updateUserFields(user.uid, {
          'verification.email': true,
        });

        // Reload current user data
        await _loadUserData();

        _showSuccessSnackbar('Email verified successfully!');
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.warning),
                SizedBox(width: 12),
                Text('Not Verified Yet', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'Your email is not verified yet. Please check your inbox and click the verification link, then try again.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _verifyEmail(); // Resend email
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Resend Email'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackbar('Failed to check verification status');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.success),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorSnackbar('No user logged in');
        return;
      }

      // Get phone number from user data
      if (_currentUser?.phone == null || _currentUser!.phone.isEmpty) {
        _showErrorSnackbar(
          'No phone number found. Please update your profile.',
        );
        return;
      }

      String phoneNumber = _currentUser!.phone;

      // Ensure phone number has country code
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber'; // Default to India, adjust as needed
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );

      // Send OTP
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          try {
            await user.updatePhoneNumber(credential);

            // Update Firestore
            final authService = AuthService();
            await authService.updateUserFields(user.uid, {
              'verification.phone': true,
            });

            // Close loading
            if (mounted) Navigator.pop(context);

            // Reload data
            await _loadUserData();

            _showSuccessSnackbar('Phone verified automatically!');
          } catch (e) {
            if (mounted) Navigator.pop(context);
            _showErrorSnackbar('Auto-verification failed');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          // Close loading
          if (mounted) Navigator.pop(context);

          String errorMessage = 'Verification failed';

          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = e.message ?? errorMessage;
          }

          _showErrorSnackbar(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          // Close loading
          if (mounted) Navigator.pop(context);

          // Show OTP input dialog
          _showOTPDialog(verificationId, phoneNumber);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
          debugPrint('Auto-retrieval timeout: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      // Close loading if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackbar('Failed to send OTP: ${e.toString()}');
    }
  }

  void _showOTPDialog(String verificationId, String phoneNumber) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.phone_android,
                color: AppTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Verify Phone', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the 6-digit code sent to:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: AppTheme.accent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  color: AppTheme.white.withValues(alpha: 0.3),
                  letterSpacing: 8,
                ),
                counterText: '',
                filled: true,
                fillColor: AppTheme.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.accent,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Didn\'t receive the code?',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyPhone(); // Resend OTP
              },
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              otpController.dispose();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = otpController.text.trim();

              if (code.length != 6) {
                _showErrorSnackbar('Please enter a valid 6-digit code');
                return;
              }

              // Close OTP dialog
              Navigator.pop(context);

              // Verify OTP
              await _verifyOTP(verificationId, code);

              otpController.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOTP(String verificationId, String smsCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorSnackbar('No user logged in');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Update phone number
      await user.updatePhoneNumber(credential);

      // Update Firestore
      final authService = AuthService();
      await authService.updateUserFields(user.uid, {
        'verification.phone': true,
      });

      // Close loading
      if (mounted) Navigator.pop(context);

      // Reload data
      await _loadUserData();

      _showSuccessSnackbar('Phone verified successfully!');
    } on FirebaseAuthException catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      String errorMessage = 'Verification failed';

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP code. Please try again.';
          break;
        case 'session-expired':
          errorMessage = 'OTP expired. Please request a new code.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      _showErrorSnackbar(errorMessage);
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);
      _showErrorSnackbar('Failed to verify OTP');
    }
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
                // TODO: Fetch from Firestore - user's total donated
                _buildCompactStat('₹0', 'Total', Icons.attach_money),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.white.withValues(alpha: 0.2),
                ),
                // TODO: Fetch from Firestore - user's donation count
                _buildCompactStat('0', 'Donations', Icons.card_giftcard),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.white.withValues(alpha: 0.2),
                ),
                // TODO: Fetch from Firestore - calculated impact
                _buildCompactStat('0', 'Lives', Icons.favorite),
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
    // TODO: Fetch from Firestore
    // return await FirebaseFirestore.instance
    //   .collection('donations')
    //   .where('donorId', '==', currentUser.uid)
    //   .orderBy('createdAt', descending: true)
    //   .limit(3)
    //   .get();

    return []; // Empty - no mock data
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

  // Image Upload Method
  Future<void> _pickAndUploadImage() async {
    if (!_isEditing) return;

    // Show bottom sheet with camera/gallery options
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Image Source',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.donorColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppTheme.donorColor,
                  ),
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Take a new photo',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppTheme.accent,
                  ),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Choose from gallery',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Show loading
      setState(() => _isUploadingImage = true);

      // Read image as bytes (works on all platforms)
      final imageBytes = await pickedFile.readAsBytes();
      final filename = pickedFile.name;

      // Upload to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(
        imageBytes,
        filename,
      );

      // Update Firestore - store in donorProfile.profileImage
      await _authService.updateUserFields(_currentUser!.id, {
        'donorProfile.profileImage': imageUrl,
        'profileImageUrl':
            imageUrl, // Also update root level for backward compatibility
      });

      // Reload user data
      await _loadUserData();

      if (mounted) {
        _showSuccessSnackbar('Profile image updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
          'Failed to upload image: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppTheme.error),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: AppTheme.white)),
                ],
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // File Upload Dialog for Certificates
  Future<void> _showCertificateUploadDialog() async {
    final TextEditingController captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: AppTheme.gold),
            SizedBox(width: 12),
            Text('Upload Certificate', style: TextStyle(color: AppTheme.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a file (SVG, JPG, PNG, or PDF)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: captionController,
              style: const TextStyle(color: AppTheme.white),
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Add a caption (optional)',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['svg', 'jpg', 'jpeg', 'png', 'pdf'],
                );

                if (result != null) {
                  Navigator.pop(context);
                  // TODO: Upload to Cloudinary/Firestore
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.files.first.name}\\nCaption: ${captionController.text.isEmpty ? "No caption" : captionController.text}',
                        ),
                        backgroundColor: AppTheme.success,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error picking file: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // File Upload Dialog for Memories
  Future<void> _showMemoryUploadDialog() async {
    final TextEditingController captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.photo_library, color: AppTheme.accent),
            SizedBox(width: 12),
            Text('Upload Memory', style: TextStyle(color: AppTheme.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a photo (SVG, JPG, PNG, or PDF)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: captionController,
              style: const TextStyle(color: AppTheme.white),
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Add a caption (optional)',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['svg', 'jpg', 'jpeg', 'png', 'pdf'],
                );

                if (result != null) {
                  Navigator.pop(context);
                  // TODO: Upload to Cloudinary/Firestore
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.files.first.name}\\nCaption: ${captionController.text.isEmpty ? "No caption" : captionController.text}',
                        ),
                        backgroundColor: AppTheme.success,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error picking file: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
