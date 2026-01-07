import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/user_models.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';
import '../../services/file_picker_helper.dart';
import '../../services/cloudinary_service.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole selectedRole;

  const RegisterScreen({super.key, required this.selectedRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Common Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();

  // NGO Specific Controllers
  final _orgNameController = TextEditingController();
  final _orgPhoneController = TextEditingController();
  final _orgEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _headOfOrgNameController = TextEditingController();
  final _headOfOrgEmailController = TextEditingController();
  final _headOfOrgPhoneController = TextEditingController();

  // Donor/Volunteer Specific Controllers
  final _qualificationController = TextEditingController();

  // Volunteer Specific Controllers
  final _ngoNameController = TextEditingController();
  final _ngoPhoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  bool _isWorkingInNGO = false;

  // File uploads (simulated)
  String? _verifiedIdFile;
  String? _govtDocFile;
  String? _headIdFile;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _orgNameController.dispose();
    _orgPhoneController.dispose();
    _orgEmailController.dispose();
    _addressController.dispose();
    _headOfOrgNameController.dispose();
    _headOfOrgEmailController.dispose();
    _headOfOrgPhoneController.dispose();
    _qualificationController.dispose();
    _ngoNameController.dispose();
    _ngoPhoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  String get _roleTitle {
    switch (widget.selectedRole) {
      case UserRole.ngo:
        return 'NGO / Organisation';
      case UserRole.donor:
        return 'Donor';
      case UserRole.volunteer:
        return 'Volunteer';
    }
  }

  Color get _roleColor {
    switch (widget.selectedRole) {
      case UserRole.ngo:
        return AppTheme.ngoColor;
      case UserRole.donor:
        return AppTheme.donorColor;
      case UserRole.volunteer:
        return AppTheme.volunteerColor;
    }
  }

  IconData get _roleIcon {
    switch (widget.selectedRole) {
      case UserRole.ngo:
        return Icons.business_rounded;
      case UserRole.donor:
        return Icons.volunteer_activism_rounded;
      case UserRole.volunteer:
        return Icons.people_alt_rounded;
    }
  }

  List<String> get _stepTitles {
    switch (widget.selectedRole) {
      case UserRole.ngo:
        return ['Organisation Info', 'Head of Org', 'Documents', 'Security'];
      case UserRole.donor:
        return ['Basic Info', 'Details', 'Documents', 'Security'];
      case UserRole.volunteer:
        return ['Basic Info', 'Details', 'NGO Info', 'Documents', 'Security'];
    }
  }

  int get _totalSteps => _stepTitles.length;

  Future<void> _uploadFile(String fieldName) async {
    try {
      // Show loading indicator
      setState(() => _isLoading = true);

      // Pick document
      final result = await FilePickerHelper.pickDocument();

      if (result == null) {
        setState(() => _isLoading = false);
        return; // User cancelled
      }

      // Upload to Cloudinary
      final cloudinaryService = CloudinaryService();
      final uploadedUrl = await cloudinaryService.uploadDocument(
        result.bytes,
        result.filename,
      );

      // Update state with uploaded URL
      setState(() {
        switch (fieldName) {
          case 'verifiedId':
            _verifiedIdFile = uploadedUrl;
            break;
          case 'govtDoc':
            _govtDocFile = uploadedUrl;
            break;
          case 'headId':
            _headIdFile = uploadedUrl;
            break;
        }
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Document uploaded successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Failed to upload document: ${e.toString()}');
      }
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateCurrentStep() {
    // Validate Form Fields
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Validate File Uploads based on Role and Step
    if (widget.selectedRole == UserRole.ngo && _currentStep == 2) {
      if (_govtDocFile == null ||
          _headIdFile == null ||
          _verifiedIdFile == null) {
        _showErrorSnackBar('Please upload all required documents');
        return false;
      }
    } else if (widget.selectedRole == UserRole.donor && _currentStep == 2) {
      if (_verifiedIdFile == null) {
        _showErrorSnackBar('Please upload verified ID proof');
        return false;
      }
    } else if (widget.selectedRole == UserRole.volunteer && _currentStep == 3) {
      if (_verifiedIdFile == null) {
        _showErrorSnackBar('Please upload verified ID proof');
        return false;
      }
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onRegister() async {
    if (!_validateCurrentStep()) return;

    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to the Terms and Conditions');
      return;
    }

    setState(() => _isLoading = true);

    try {
      BaseUser userDetails;
      // Fix: NGO registration uses _orgEmailController, others use _emailController
      final String email = widget.selectedRole == UserRole.ngo
          ? _orgEmailController.text.trim()
          : _emailController.text.trim();

      final String password = _passwordController.text.trim();

      if (email.isEmpty) {
        _showErrorSnackBar('Email address is missing');
        setState(() => _isLoading = false);
        return;
      }

      // Create specific user model based on role
      switch (widget.selectedRole) {
        case UserRole.ngo:
          userDetails = NGOUser(
            id: '', // Will be set by AuthService
            name: _orgNameController.text.trim(), // Use org name
            phone: _orgPhoneController.text.trim(), // Use org phone
            email: email, // This will be org email from security step
            location: _locationController.text.trim(),
            verifiedIdUrl: _verifiedIdFile ?? '', // In real app, upload first
            organizationName: _orgNameController.text.trim(),
            organizationPhone: _orgPhoneController.text.trim(),
            organizationEmail: _orgEmailController.text.trim(),
            address: _addressController.text.trim(),
            govtVerifiedDocUrl: _govtDocFile ?? '',
            headOfOrgName: _headOfOrgNameController.text.trim(),
            headOfOrgEmail: _headOfOrgEmailController.text.trim(),
            headOfOrgPhone: _headOfOrgPhoneController.text.trim(),
            headOfOrgId: '', // No longer collected via text field
            headOfOrgIdUrl: _headIdFile ?? '',
            headOfOrgEmployeeId: '', // No longer collected via text field
          );
          break;
        case UserRole.donor:
          userDetails = DonorUser(
            id: '',
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: email,
            location: _locationController.text.trim(),
            verifiedIdUrl: _verifiedIdFile ?? '',
            qualification: _qualificationController.text.trim(),
          );
          break;
        case UserRole.volunteer:
          userDetails = VolunteerUser(
            id: '',
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: email,
            location: _locationController.text.trim(),
            verifiedIdUrl: _verifiedIdFile ?? '',
            qualification: _qualificationController.text.trim(),
            isWorkingInNGO: _isWorkingInNGO,
            ngoName: _isWorkingInNGO ? _ngoNameController.text.trim() : null,
            ngoPhone: _isWorkingInNGO ? _ngoPhoneController.text.trim() : null,
            employeeId: _isWorkingInNGO
                ? _employeeIdController.text.trim()
                : null,
          );
          break;
      }

      // Call AuthService
      await AuthService().signUp(
        email: email,
        password: password,
        userDetails: userDetails,
      );

      if (mounted) {
        _showRegistrationSuccessDialog();
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
      // Show the full error message if possible, or a more descriptive fallback
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.trim().isEmpty || errorMessage == 'Error') {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: _roleColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registration Successful!',
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.selectedRole == UserRole.volunteer
                    ? 'Your account is pending admin approval. You will be notified once approved.'
                    : 'Your account has been created successfully. You can now login.',
                style: TextStyle(color: AppTheme.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (widget.selectedRole == UserRole.volunteer) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You cannot perform any actions until admin approval.',
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleColor,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.white, // Replaced gradient with solid white
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Progress Indicator
                _buildProgressIndicator(),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(key: _formKey, child: _buildCurrentStepForm()),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.primaryDark,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _roleColor,
            ),
            child: Icon(_roleIcon, color: AppTheme.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register as $_roleTitle',
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps: ${_stepTitles[_currentStep]}',
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted || isCurrent
                    ? _roleColor
                    : AppTheme.grey.withValues(alpha: 0.2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepForm() {
    switch (widget.selectedRole) {
      case UserRole.ngo:
        return _buildNGOForm();
      case UserRole.donor:
        return _buildDonorForm();
      case UserRole.volunteer:
        return _buildVolunteerForm();
    }
  }

  // NGO Form Steps
  Widget _buildNGOForm() {
    switch (_currentStep) {
      case 0:
        return _buildNGOOrganisationStep();
      case 1:
        return _buildNGOHeadOfOrgStep();
      case 2:
        return _buildNGODocumentsStep();
      case 3:
        return _buildSecurityStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Donor Form Steps
  Widget _buildDonorForm() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildDonorDetailsStep();
      case 2:
        return _buildDonorDocumentsStep();
      case 3:
        return _buildSecurityStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Volunteer Form Steps
  Widget _buildVolunteerForm() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildVolunteerDetailsStep();
      case 2:
        return _buildVolunteerNGOInfoStep();
      case 3:
        return _buildVolunteerDocumentsStep();
      case 4:
        return _buildSecurityStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Common Basic Info Step
  Widget _buildBasicInfoStep() {
    final isNGO = widget.selectedRole == UserRole.ngo;
    return _buildFormCard(
      title: isNGO ? 'Account Information' : 'Personal Information',
      icon: Icons.person_outline,
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          hint: 'Enter your full name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _locationController,
          label: 'Location',
          icon: Icons.location_on_outlined,
          hint: 'Enter your city/area',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your location';
            }
            return null;
          },
        ),
      ],
    );
  }

  // NGO Organisation Step
  Widget _buildNGOOrganisationStep() {
    return _buildFormCard(
      title: 'Organisation Details',
      icon: Icons.business_outlined,
      children: [
        CustomTextField(
          controller: _orgNameController,
          label: 'Organisation Name',
          icon: Icons.business_center_outlined,
          hint: 'Enter organisation name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter organisation name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _orgPhoneController,
          label: 'Organisation Phone Number',
          icon: Icons.phone_outlined,
          hint: 'Enter organisation phone',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter organisation phone';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _orgEmailController,
          label: 'Organisation Email',
          icon: Icons.email_outlined,
          hint: 'Enter organisation email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter organisation email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Complete Address',
          icon: Icons.location_city_outlined,
          hint: 'Enter full address',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _locationController,
          label: 'City/Location',
          icon: Icons.location_on_outlined,
          hint: 'Enter city or area',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter location';
            }
            return null;
          },
        ),
      ],
    );
  }

  // NGO Head of Organisation Step
  Widget _buildNGOHeadOfOrgStep() {
    return _buildFormCard(
      title: 'Head of Organisation Details',
      icon: Icons.person_outline,
      children: [
        CustomTextField(
          controller: _headOfOrgNameController,
          label: 'Head of Organisation Name',
          icon: Icons.person_outlined,
          hint: 'Enter full name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter head of organisation name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _headOfOrgEmailController,
          label: 'Head of Organisation Email',
          icon: Icons.email_outlined,
          hint: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _headOfOrgPhoneController,
          label: 'Head of Organisation Phone',
          icon: Icons.phone_outlined,
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  // NGO Documents Step
  Widget _buildNGODocumentsStep() {
    return _buildFormCard(
      title: 'Upload Documents',
      icon: Icons.upload_file,
      children: [
        _buildInfoBox(
          'Please upload clear, readable copies of all documents',
          Icons.info_outline,
          AppTheme.info,
        ),
        const SizedBox(height: 20),
        FileUploadField(
          label: 'Government Verified Organisation Document',
          icon: Icons.verified_outlined,
          fileName: _govtDocFile,
          onTap: () => _uploadFile('govtDoc'),
        ),
        const SizedBox(height: 16),
        FileUploadField(
          label: 'Head of Organisation Government ID',
          icon: Icons.badge_outlined,
          fileName: _headIdFile,
          onTap: () => _uploadFile('headId'),
        ),
        const SizedBox(height: 16),
        FileUploadField(
          label: 'Verified ID Proof',
          icon: Icons.credit_card_outlined,
          fileName: _verifiedIdFile,
          onTap: () => _uploadFile('verifiedId'),
        ),
      ],
    );
  }

  // Donor Details Step
  Widget _buildDonorDetailsStep() {
    return _buildFormCard(
      title: 'Additional Details',
      icon: Icons.info_outline,
      children: [
        CustomTextField(
          controller: _qualificationController,
          label: 'Qualification',
          icon: Icons.school_outlined,
          hint: 'Enter your qualification',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your qualification';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInfoBox(
          'Your information helps us connect you with the right causes',
          Icons.lightbulb_outline,
          AppTheme.gold,
        ),
      ],
    );
  }

  // Donor Documents Step
  Widget _buildDonorDocumentsStep() {
    return _buildFormCard(
      title: 'Upload Documents',
      icon: Icons.upload_file,
      children: [
        _buildInfoBox(
          'Please upload a clear copy of your government ID',
          Icons.info_outline,
          AppTheme.info,
        ),
        const SizedBox(height: 20),
        FileUploadField(
          label: 'Verified ID Proof (Aadhaar/PAN/Passport)',
          icon: Icons.credit_card_outlined,
          fileName: _verifiedIdFile,
          onTap: () => _uploadFile('verifiedId'),
        ),
      ],
    );
  }

  // Volunteer Details Step
  Widget _buildVolunteerDetailsStep() {
    return _buildFormCard(
      title: 'Additional Details',
      icon: Icons.info_outline,
      children: [
        CustomTextField(
          controller: _qualificationController,
          label: 'Qualification',
          icon: Icons.school_outlined,
          hint: 'Enter your qualification',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your qualification';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInfoBox(
          'Note: Your account will require admin approval before you can perform any actions.',
          Icons.warning_amber_rounded,
          AppTheme.warning,
        ),
      ],
    );
  }

  // Volunteer NGO Info Step
  Widget _buildVolunteerNGOInfoStep() {
    return _buildFormCard(
      title: 'NGO Association',
      icon: Icons.business_outlined,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.work_outline, color: AppTheme.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Are you working in any NGO?',
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
              Switch(
                value: _isWorkingInNGO,
                onChanged: (value) {
                  setState(() => _isWorkingInNGO = value);
                },
                activeTrackColor: _roleColor,
              ),
            ],
          ),
        ),
        if (_isWorkingInNGO) ...[
          const SizedBox(height: 20),
          CustomTextField(
            controller: _ngoNameController,
            label: 'NGO Name',
            icon: Icons.business_center_outlined,
            hint: 'Enter NGO name',
            validator: _isWorkingInNGO
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter NGO name';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _ngoPhoneController,
            label: 'NGO Phone Number',
            icon: Icons.phone_outlined,
            hint: 'Enter NGO contact number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: _isWorkingInNGO
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter NGO phone number';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _employeeIdController,
            label: 'Employee ID',
            icon: Icons.badge_outlined,
            hint: 'Enter your employee ID',
            validator: _isWorkingInNGO
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee ID';
                    }
                    return null;
                  }
                : null,
          ),
        ] else ...[
          const SizedBox(height: 20),
          _buildInfoBox(
            'You can register as an independent volunteer and help bridge donors with NGOs.',
            Icons.volunteer_activism,
            _roleColor,
          ),
        ],
      ],
    );
  }

  // Volunteer Documents Step
  Widget _buildVolunteerDocumentsStep() {
    return _buildFormCard(
      title: 'Upload Documents',
      icon: Icons.upload_file,
      children: [
        _buildInfoBox(
          'Please upload a clear copy of your government ID',
          Icons.info_outline,
          AppTheme.info,
        ),
        const SizedBox(height: 20),
        FileUploadField(
          label: 'Verified ID Proof (Aadhaar/PAN/Passport)',
          icon: Icons.credit_card_outlined,
          fileName: _verifiedIdFile,
          onTap: () => _uploadFile('verifiedId'),
        ),
      ],
    );
  }

  // Security Step (Common)
  Widget _buildSecurityStep() {
    return _buildFormCard(
      title: 'Create Password',
      icon: Icons.lock_outline,
      children: [
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          hint: 'Create a strong password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppTheme.white.withValues(alpha: 0.6),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          hint: 'Re-enter your password',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppTheme.white.withValues(alpha: 0.6),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildTermsCheckbox(),
      ],
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cleanCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _roleColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _roleColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoBox(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () {
        setState(() => _agreeToTerms = !_agreeToTerms);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _agreeToTerms
                ? _roleColor.withValues(alpha: 0.5)
                : AppTheme.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _agreeToTerms ? _roleColor : Colors.transparent,
                border: Border.all(
                  color: _agreeToTerms
                      ? _roleColor
                      : AppTheme.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: _agreeToTerms
                  ? const Icon(Icons.check, color: AppTheme.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(
                        color: _roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.7),
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: _roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: AppTheme.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(
                    color: AppTheme.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Back', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (isLastStep ? _onRegister : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: _roleColor,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: _roleColor.withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Register' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastStep
                              ? Icons.check_circle_outline
                              : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
