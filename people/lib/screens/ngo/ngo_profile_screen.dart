import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_models.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class NGOProfileScreen extends StatefulWidget {
  const NGOProfileScreen({super.key});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  NGOUser? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUploadingImage = false;

  // Controllers
  late TextEditingController _orgNameController;
  late TextEditingController _orgPhoneController;
  late TextEditingController _orgEmailController;
  late TextEditingController _addressController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _planOfActionController;
  late TextEditingController _headNameController;
  late TextEditingController _headEmailController;
  late TextEditingController _headPhoneController;

  @override
  void initState() {
    super.initState();
    _orgNameController = TextEditingController();
    _orgPhoneController = TextEditingController();
    _orgEmailController = TextEditingController();
    _addressController = TextEditingController();
    _locationController = TextEditingController();
    _bioController = TextEditingController();
    _planOfActionController = TextEditingController();
    _headNameController = TextEditingController();
    _headEmailController = TextEditingController();
    _headPhoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgPhoneController.dispose();
    _orgEmailController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _planOfActionController.dispose();
    _headNameController.dispose();
    _headEmailController.dispose();
    _headPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    NGOUser? user;
    try {
      user = await _authService.getUserProfile() as NGOUser?;
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
    _orgNameController.text = _currentUser!.organizationName;
    _orgPhoneController.text = _currentUser!.organizationPhone;
    _orgEmailController.text = _currentUser!.organizationEmail;
    _addressController.text = _currentUser!.address;
    _locationController.text = _currentUser!.location;
    _bioController.text = _currentUser!.bio ?? '';
    _planOfActionController.text = _currentUser!.ngoProfile.planOfAction;
    _headNameController.text = _currentUser!.headOfOrgName;
    _headEmailController.text = _currentUser!.headOfOrgEmail;
    _headPhoneController.text = _currentUser!.headOfOrgPhone;
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
      // Create updated ngoProfile
      final updatedNGOProfile = NGOProfile(
        organizationName: _orgNameController.text.trim(),
        address: _addressController.text.trim(),
        bio: _bioController.text.trim(),
        planOfAction: _planOfActionController.text.trim(),
        profileImage: _currentUser!.ngoProfile.profileImage,
        certifications: _currentUser!.ngoProfile.certifications,
        projectsCompleted: _currentUser!.ngoProfile.projectsCompleted,
        rating: _currentUser!.ngoProfile.rating,
      );

      // Create updated user
      final updatedUser = NGOUser(
        id: _currentUser!.id,
        name: _orgNameController.text.trim(),
        phone: _orgPhoneController.text.trim(),
        email: _currentUser!.email,
        location: _locationController.text.trim(),
        verifiedIdUrl: _currentUser!.verifiedIdUrl,
        organizationName: _orgNameController.text.trim(),
        organizationPhone: _orgPhoneController.text.trim(),
        organizationEmail: _orgEmailController.text.trim(),
        address: _addressController.text.trim(),
        govtVerifiedDocUrl: _currentUser!.govtVerifiedDocUrl,
        headOfOrgName: _headNameController.text.trim(),
        headOfOrgEmail: _headEmailController.text.trim(),
        headOfOrgPhone: _headPhoneController.text.trim(),
        headOfOrgId: _currentUser!.headOfOrgId,
        headOfOrgIdUrl: _currentUser!.headOfOrgIdUrl,
        headOfOrgEmployeeId: _currentUser!.headOfOrgEmployeeId,
        bio: _bioController.text.trim(),
        profileImageUrl: _currentUser!.profileImageUrl,
        isApproved: _currentUser!.isApproved,
        createdAt: _currentUser!.createdAt,
        profileCompletion: _currentUser!.profileCompletion,
        verification: _currentUser!.verification,
        ngoProfile: updatedNGOProfile,
      );

      // Update in Firestore
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

  Future<void> _pickAndUploadImage() async {
    if (!_isEditing) return;

    try {
      // Show image source selection
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Choose Image Source',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.ngoColor),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.ngoColor,
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      setState(() => _isUploadingImage = true);

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      // Read bytes
      final bytes = await pickedFile.readAsBytes();

      // Upload to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(
        bytes,
        pickedFile.name,
      );

      // Update user profile with new image URL
      if (_currentUser != null) {
        final updatedNGOProfile = NGOProfile(
          organizationName: _currentUser!.ngoProfile.organizationName,
          address: _currentUser!.ngoProfile.address,
          bio: _currentUser!.ngoProfile.bio,
          planOfAction: _currentUser!.ngoProfile.planOfAction,
          profileImage: imageUrl,
          certifications: _currentUser!.ngoProfile.certifications,
          projectsCompleted: _currentUser!.ngoProfile.projectsCompleted,
          rating: _currentUser!.ngoProfile.rating,
        );

        final updatedUser = NGOUser(
          id: _currentUser!.id,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          email: _currentUser!.email,
          location: _currentUser!.location,
          verifiedIdUrl: _currentUser!.verifiedIdUrl,
          organizationName: _currentUser!.organizationName,
          organizationPhone: _currentUser!.organizationPhone,
          organizationEmail: _currentUser!.organizationEmail,
          address: _currentUser!.address,
          govtVerifiedDocUrl: _currentUser!.govtVerifiedDocUrl,
          headOfOrgName: _currentUser!.headOfOrgName,
          headOfOrgEmail: _currentUser!.headOfOrgEmail,
          headOfOrgPhone: _currentUser!.headOfOrgPhone,
          headOfOrgId: _currentUser!.headOfOrgId,
          headOfOrgIdUrl: _currentUser!.headOfOrgIdUrl,
          headOfOrgEmployeeId: _currentUser!.headOfOrgEmployeeId,
          bio: _currentUser!.bio,
          profileImageUrl: imageUrl,
          isApproved: _currentUser!.isApproved,
          createdAt: _currentUser!.createdAt,
          profileCompletion: _currentUser!.profileCompletion,
          verification: _currentUser!.verification,
          ngoProfile: updatedNGOProfile,
        );

        await _authService.updateUserProfile(updatedUser);

        setState(() {
          _currentUser = updatedUser;
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
        await _authService.updateUserFields(user.uid, {
          'verification.email': true,
        });
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
          child: CircularProgressIndicator(color: AppTheme.ngoColor),
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
                  color: AppTheme.ngoColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  color: AppTheme.ngoColor,
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
                    color: AppTheme.ngoColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: AppTheme.ngoColor, size: 16),
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
                backgroundColor: AppTheme.ngoColor,
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
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackbar('Failed to send verification email');
    }
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackbar('No user logged in');
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.ngoColor),
        ),
      );

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (mounted) Navigator.pop(context);

      if (updatedUser?.emailVerified == true) {
        await _authService.updateUserFields(user.uid, {
          'verification.email': true,
        });
        await _loadUserData();
        _showSuccessSnackbar('Email verified successfully!');
      } else {
        _showErrorSnackbar('Email not verified yet. Please check your inbox.');
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackbar('Error checking verification status');
    }
  }

  Future<void> _verifyPhone() async {
    _showErrorSnackbar('Phone verification coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.ngoColor),
      );
    }

    if (_currentUser == null) {
      return const Center(child: Text('User not found'));
    }

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
            _buildOrganizationDetails(),
            const SizedBox(height: 20),
            _buildHeadOfOrgSection(),
            const SizedBox(height: 20),
            _buildCompletionSection(),
            const SizedBox(height: 20),
            _buildStatisticsSection(),
            const SizedBox(height: 20),
            _buildDocumentsSection(),
            const SizedBox(height: 20),
            _buildCertificationsSection(),

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
        backgroundColor: AppTheme.ngoColor,
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
          GestureDetector(
            onTap: _isEditing ? _pickAndUploadImage : null,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.ngoColor, width: 2),
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
                          Icons.business,
                          size: 50,
                          color: AppTheme.white,
                        )
                      : null,
                ),
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
                        color: AppTheme.ngoColor,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                if (_isEditing && !_isUploadingImage)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.ngoColor,
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
          // Organization Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  TextFormField(
                    controller: _orgNameController,
                    style: AppTheme.headingSmall,
                    decoration: const InputDecoration(
                      hintText: 'Organization Name',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: UnderlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                else
                  Text(
                    _currentUser!.organizationName,
                    style: AppTheme.headingSmall,
                  ),
                const SizedBox(height: 8),
                Text(
                  _maskEmail(_currentUser!.organizationEmail),
                  style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.ngoColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.ngoColor),
                  ),
                  child: const Text(
                    'Role: NGO',
                    style: TextStyle(
                      color: AppTheme.ngoColor,
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

  // 2. Organization Details
  Widget _buildOrganizationDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Organization Details', style: AppTheme.headingSmall),
              Text(
                'View More',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.ngoColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bio
          const Text(
            'About Organization',
            style: TextStyle(
              color: AppTheme.ngoColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write about your organization...',
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

          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          // Plan of Action
          const Text(
            'Plan of Action',
            style: TextStyle(
              color: AppTheme.ngoColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            TextFormField(
              controller: _planOfActionController,
              maxLines: 4,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText:
                    'Describe your organization\'s plan of action in brief...',
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
              _currentUser!.ngoProfile.planOfAction.isNotEmpty
                  ? _currentUser!.ngoProfile.planOfAction
                  : 'No plan of action added yet.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // Contact Info
          _buildInfoRow(Icons.phone, 'Phone', _currentUser!.organizationPhone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email, 'Email', _currentUser!.organizationEmail),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Address', _currentUser!.address),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_city,
            'Location',
            _currentUser!.location,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: AppTheme.bodySmall.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  // 3. Head of Organization Section
  Widget _buildHeadOfOrgSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Head of Organization', style: AppTheme.headingSmall),
          const SizedBox(height: 16),

          if (_isEditing) ...[
            TextFormField(
              controller: _headNameController,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(Icons.person, color: AppTheme.ngoColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _headEmailController,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(Icons.email, color: AppTheme.ngoColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _headPhoneController,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(Icons.phone, color: AppTheme.ngoColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ] else ...[
            _buildInfoRow(Icons.person, 'Name', _currentUser!.headOfOrgName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, 'Email', _currentUser!.headOfOrgEmail),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Phone', _currentUser!.headOfOrgPhone),
          ],
        ],
      ),
    );
  }

  // 4. Profile Completion & Verification
  Widget _buildCompletionSection() {
    final bool emailVerified = _currentUser!.verification.email;
    final bool phoneVerified = _currentUser!.verification.phone;
    final bool govtVerified = _currentUser!.verification.governmentId;
    final bool docUploaded = _currentUser!.govtVerifiedDocUrl.isNotEmpty;

    int completedSteps = 0;
    if (emailVerified) completedSteps++;
    if (phoneVerified) completedSteps++;
    if (govtVerified) completedSteps++;
    if (docUploaded) completedSteps++;

    double completion = (completedSteps / 4);

    return Container(
      padding: const EdgeInsets.all(20),
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
              // Checklist
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
                    _buildCheckItem('Govt Document Uploaded', docUploaded),
                    if (completion < 0.7)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '⚠ 70% required for full access',
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
                  color: AppTheme.ngoColor,
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

  // 5. Statistics Section
  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Organization Statistics', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.work_outline,
                  '${_currentUser!.ngoProfile.projectsCompleted}',
                  'Projects',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.star_outline,
                  _currentUser!.ngoProfile.rating.toStringAsFixed(1),
                  'Rating',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.verified_outlined,
                  '${_currentUser!.ngoProfile.certifications.length}',
                  'Certifications',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.pending_actions,
                  '0',
                  'Active Requests',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.ngoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.ngoColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.ngoColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 6. Documents Section
  Widget _buildDocumentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documents', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          _buildDocumentLink(
            'Government Verified Document',
            _currentUser!.govtVerifiedDocUrl,
            Icons.verified_user,
          ),
          const SizedBox(height: 12),
          _buildDocumentLink(
            'Organization Verified ID',
            _currentUser!.verifiedIdUrl,
            Icons.badge,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink(String title, String url, IconData icon) {
    final bool hasDocument = url.isNotEmpty;

    return InkWell(
      onTap: hasDocument ? () => _openDocument(url) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasDocument
              ? AppTheme.ngoColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDocument
                ? AppTheme.ngoColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasDocument ? AppTheme.ngoColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDocument ? 'Tap to view' : 'Not uploaded',
                    style: TextStyle(
                      color: hasDocument ? AppTheme.ngoColor : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (hasDocument)
              const Icon(Icons.open_in_new, color: AppTheme.ngoColor, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar('Could not open document');
      }
    } catch (e) {
      _showErrorSnackbar('Error opening document: ${e.toString()}');
    }
  }

  // 7. Certifications Section
  Widget _buildCertificationsSection() {
    final certifications = _currentUser!.ngoProfile.certifications;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Certifications', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          if (certifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No certifications yet',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: certifications.map((cert) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.ngoColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.ngoColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppTheme.ngoColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cert,
                        style: const TextStyle(
                          color: AppTheme.ngoColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            _isEditing = false;
            _populateControllers(); // Reset to original values
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
