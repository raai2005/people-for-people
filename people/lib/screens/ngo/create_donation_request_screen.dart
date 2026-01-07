import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/donation_request.dart';

class CreateDonationRequestScreen extends StatefulWidget {
  const CreateDonationRequestScreen({super.key});

  @override
  State<CreateDonationRequestScreen> createState() =>
      _CreateDonationRequestScreenState();
}

class _CreateDonationRequestScreenState
    extends State<CreateDonationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _targetQuantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _specificItemsController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  DonationCategory _selectedCategory = DonationCategory.money;
  UrgencyLevel _selectedUrgency = UrgencyLevel.medium;
  DateTime? _deadline;
  bool _isLoading = false;

  // Food specific
  String _foodType = 'packaged'; // packaged, raw, readymade
  bool _vegOnly = true;

  // Clothes specific
  String _clothesCondition = 'both'; // new, used, both
  List<String> _clothesFor = []; // men, women, children
  String _clothesSeason = 'all'; // winter, summer, all

  // Medical specific
  String _medicalType = 'medicines'; // medicines, equipment, supplies

  // Education specific
  String _educationType = 'stationery'; // books, stationery, bags, uniforms
  String _educationLevel = 'all'; // primary, secondary, college, all

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _targetQuantityController.dispose();
    _locationController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _specificItemsController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  // Build structured description from category-specific fields
  String _buildStructuredDescription() {
    final buffer = StringBuffer();

    // Add main description
    buffer.writeln('📋 Purpose: ${_descriptionController.text.trim()}');
    buffer.writeln('');

    // Add category-specific details
    switch (_selectedCategory) {
      case DonationCategory.food:
        buffer.writeln('🍽️ FOOD REQUIREMENTS:');
        buffer.writeln('• Type: ${_getFoodTypeLabel(_foodType)}');
        buffer.writeln(
          '• Dietary: ${_vegOnly ? 'Vegetarian Only' : 'Veg & Non-Veg Accepted'}',
        );
        break;

      case DonationCategory.clothes:
        buffer.writeln('👕 CLOTHING REQUIREMENTS:');
        buffer.writeln(
          '• Condition: ${_getClothesConditionLabel(_clothesCondition)}',
        );
        buffer.writeln(
          '• For: ${_clothesFor.isEmpty ? 'All' : _clothesFor.join(', ')}',
        );
        buffer.writeln('• Season: ${_getClothesSeason(_clothesSeason)}');
        break;

      case DonationCategory.medical:
        buffer.writeln('🏥 MEDICAL REQUIREMENTS:');
        buffer.writeln('• Type: ${_getMedicalTypeLabel(_medicalType)}');
        break;

      case DonationCategory.education:
        buffer.writeln('📚 EDUCATION REQUIREMENTS:');
        buffer.writeln('• Type: ${_getEducationTypeLabel(_educationType)}');
        buffer.writeln('• Level: ${_getEducationLevel(_educationLevel)}');
        break;

      case DonationCategory.money:
        buffer.writeln('💰 MONETARY DONATION');
        break;

      case DonationCategory.other:
        buffer.writeln('📦 OTHER ITEMS');
        break;
    }

    // Add specific items if provided
    if (_specificItemsController.text.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📝 SPECIFIC ITEMS NEEDED:');
      buffer.writeln(_specificItemsController.text.trim());
    }

    // Add additional notes if provided
    if (_additionalNotesController.text.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⚠️ IMPORTANT NOTES:');
      buffer.writeln(_additionalNotesController.text.trim());
    }

    return buffer.toString();
  }

  String _getFoodTypeLabel(String type) {
    switch (type) {
      case 'packaged':
        return 'Packaged Food (Biscuits, Snacks, etc.)';
      case 'raw':
        return 'Raw Ingredients (Rice, Vegetables, Dal, etc.)';
      case 'readymade':
        return 'Ready-made Meals / Food Packets';
      default:
        return type;
    }
  }

  String _getClothesConditionLabel(String condition) {
    switch (condition) {
      case 'new':
        return 'New Clothes Only';
      case 'used':
        return 'Gently Used Accepted';
      case 'both':
        return 'New & Gently Used Both Accepted';
      default:
        return condition;
    }
  }

  String _getClothesSeason(String season) {
    switch (season) {
      case 'winter':
        return 'Winter Wear';
      case 'summer':
        return 'Summer Wear';
      case 'all':
        return 'All Season';
      default:
        return season;
    }
  }

  String _getMedicalTypeLabel(String type) {
    switch (type) {
      case 'medicines':
        return 'Medicines';
      case 'equipment':
        return 'Medical Equipment';
      case 'supplies':
        return 'Medical Supplies (Bandages, Masks, etc.)';
      default:
        return type;
    }
  }

  String _getEducationTypeLabel(String type) {
    switch (type) {
      case 'books':
        return 'Books & Textbooks';
      case 'stationery':
        return 'Stationery (Notebooks, Pens, etc.)';
      case 'bags':
        return 'School Bags';
      case 'uniforms':
        return 'School Uniforms';
      default:
        return type;
    }
  }

  String _getEducationLevel(String level) {
    switch (level) {
      case 'primary':
        return 'Primary School (Class 1-5)';
      case 'secondary':
        return 'Secondary School (Class 6-12)';
      case 'college':
        return 'College/Higher Education';
      case 'all':
        return 'All Levels';
      default:
        return level;
    }
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.ngoColor,
              onPrimary: Colors.white,
              surface: AppTheme.white,
              onSurface: AppTheme.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _createRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate deadline
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 10),
              Text('Please select a deadline'),
            ],
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get NGO profile data
      final ngoDoc = await FirebaseFirestore.instance
          .collection('ngos')
          .doc(user.uid)
          .get();

      final ngoData = ngoDoc.data();
      final ngoName = ngoData?['organizationName'] ?? 'Unknown NGO';
      final location = _locationController.text.isNotEmpty
          ? _locationController.text
          : ngoData?['location'] ?? 'Unknown Location';

      // Use NGO contact info if not provided
      final contactPerson = _contactPersonController.text.isNotEmpty
          ? _contactPersonController.text.trim()
          : ngoData?['contactPerson'] ?? ngoData?['representativeName'];
      final contactPhone = _contactPhoneController.text.isNotEmpty
          ? _contactPhoneController.text.trim()
          : ngoData?['phone'] ?? ngoData?['contactPhone'];
      final contactEmail = _contactEmailController.text.isNotEmpty
          ? _contactEmailController.text.trim()
          : ngoData?['email'] ?? user.email;

      // Generate unique ID
      final requestId = FirebaseFirestore.instance
          .collection('donation_requests')
          .doc()
          .id;

      // Build structured description
      final structuredDescription = _buildStructuredDescription();

      final request = DonationRequest(
        id: requestId,
        ngoId: user.uid,
        ngoName: ngoName,
        title: _titleController.text.trim(),
        description: structuredDescription,
        category: _selectedCategory,
        urgency: _selectedUrgency,
        status: RequestStatus.active,
        targetAmount: _selectedCategory == DonationCategory.money
            ? double.tryParse(_targetAmountController.text)
            : null,
        targetQuantity: _selectedCategory != DonationCategory.money
            ? int.tryParse(_targetQuantityController.text)
            : null,
        location: location,
        deadline: _deadline,
        contactPerson: contactPerson,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('donation_requests')
          .doc(requestId)
          .set(request.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Donation request created successfully!'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Donation Request',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              _buildSectionTitle('Category', Icons.category_outlined),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 24),

              // Title
              _buildSectionTitle('Request Title', Icons.title),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                hint: 'e.g., Winter Clothes for Orphanage Children',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 10) {
                    return 'Title should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description - Purpose
              _buildSectionTitle(
                'Purpose / Why You Need This',
                Icons.description_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                hint:
                    'Explain why you need this donation and how it will help...',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose';
                  }
                  if (value.length < 20) {
                    return 'Please provide more details (at least 20 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category-specific requirements
              _buildCategorySpecificFields(),

              // Specific Items Needed
              _buildSectionTitle('Specific Items Needed', Icons.list_alt),
              const SizedBox(height: 8),
              Text(
                'List the exact items you need (one per line)',
                style: TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _specificItemsController,
                hint: _getCategoryItemHint(),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Important Notes
              _buildSectionTitle(
                'Important Notes (Optional)',
                Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 8),
              Text(
                'Any special requirements or restrictions donors should know',
                style: TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _additionalNotesController,
                hint:
                    'e.g., No expired items, Only sealed packages accepted...',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Target Amount/Quantity
              _buildSectionTitle(
                _selectedCategory == DonationCategory.money
                    ? 'Target Amount (₹)'
                    : 'Target Quantity',
                _selectedCategory == DonationCategory.money
                    ? Icons.currency_rupee
                    : Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _selectedCategory == DonationCategory.money
                    ? _targetAmountController
                    : _targetQuantityController,
                hint: _selectedCategory == DonationCategory.money
                    ? 'e.g., 50000'
                    : 'e.g., 100',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Urgency Level
              _buildSectionTitle('Urgency Level', Icons.priority_high),
              const SizedBox(height: 12),
              _buildUrgencySelector(),
              const SizedBox(height: 24),

              // Deadline
              _buildSectionTitle('Deadline', Icons.calendar_today),
              const SizedBox(height: 12),
              _buildDeadlineSelector(),
              const SizedBox(height: 24),

              // Location
              _buildSectionTitle('Location', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                hint: 'e.g., Mumbai, Maharashtra',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Contact Information (Optional)
              _buildSectionTitle(
                'Contact Information (Optional)',
                Icons.contact_phone_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _contactPersonController,
                hint: 'Contact Person Name',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _contactPhoneController,
                hint: 'Contact Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _contactEmailController,
                hint: 'Contact Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ngoColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Create Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.ngoColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppTheme.primaryDark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.grey.withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.ngoColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      (DonationCategory.money, 'Money', Icons.currency_rupee),
      (DonationCategory.food, 'Food', Icons.restaurant),
      (DonationCategory.clothes, 'Clothes', Icons.checkroom),
      (DonationCategory.medical, 'Medical', Icons.medical_services),
      (DonationCategory.education, 'Education', Icons.school),
      (DonationCategory.other, 'Other', Icons.more_horiz),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat.$1;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.ngoColor.withValues(alpha: 0.1)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.ngoColor : AppTheme.borderGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.$3,
                  size: 18,
                  color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  cat.$2,
                  style: TextStyle(
                    color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUrgencySelector() {
    final urgencies = [
      (UrgencyLevel.low, 'Low', AppTheme.success),
      (UrgencyLevel.medium, 'Medium', AppTheme.warning),
      (UrgencyLevel.high, 'High', Colors.orange),
      (UrgencyLevel.critical, 'Critical', AppTheme.error),
    ];

    return Row(
      children: urgencies.map((urg) {
        final isSelected = _selectedUrgency == urg.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedUrgency = urg.$1),
            child: Container(
              margin: EdgeInsets.only(
                right: urg.$1 != UrgencyLevel.critical ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? urg.$3.withValues(alpha: 0.15)
                    : AppTheme.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? urg.$3 : AppTheme.borderGrey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  urg.$2,
                  style: TextStyle(
                    color: isSelected ? urg.$3 : AppTheme.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeadlineSelector() {
    return GestureDetector(
      onTap: _selectDeadline,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _deadline != null
                ? AppTheme.borderGrey
                : AppTheme.borderGrey,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: _deadline != null ? AppTheme.ngoColor : AppTheme.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _deadline != null
                    ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                    : 'Select a deadline *',
                style: TextStyle(
                  color: _deadline != null
                      ? AppTheme.primaryDark
                      : AppTheme.grey,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppTheme.grey),
          ],
        ),
      ),
    );
  }

  String _getCategoryItemHint() {
    switch (_selectedCategory) {
      case DonationCategory.food:
        return 'e.g.,\n- 50 kg Rice\n- 20 packets of Biscuits\n- 100 Ready-to-eat meal packets';
      case DonationCategory.clothes:
        return 'e.g.,\n- 50 Winter jackets\n- 100 Sweaters\n- 30 Blankets';
      case DonationCategory.medical:
        return 'e.g.,\n- Paracetamol tablets\n- First aid kits\n- Blood pressure monitors';
      case DonationCategory.education:
        return 'e.g.,\n- 100 Notebooks\n- 50 School bags\n- Geometry boxes';
      default:
        return 'List the items you need...';
    }
  }

  Widget _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case DonationCategory.food:
        return _buildFoodFields();
      case DonationCategory.clothes:
        return _buildClothesFields();
      case DonationCategory.medical:
        return _buildMedicalFields();
      case DonationCategory.education:
        return _buildEducationFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFoodFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Food Type', Icons.restaurant),
        const SizedBox(height: 12),
        _buildOptionSelector(
          options: [
            ('packaged', 'Packaged Food', Icons.inventory_2),
            ('raw', 'Raw Ingredients', Icons.grass),
            ('readymade', 'Ready-made Meals', Icons.lunch_dining),
          ],
          selectedValue: _foodType,
          onSelect: (value) => setState(() => _foodType = value),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Dietary Preference', Icons.eco),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildToggleOption(
                label: 'Vegetarian Only',
                isSelected: _vegOnly,
                onTap: () => setState(() => _vegOnly = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleOption(
                label: 'Veg & Non-Veg',
                isSelected: !_vegOnly,
                onTap: () => setState(() => _vegOnly = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildClothesFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Acceptable Condition', Icons.checkroom),
        const SizedBox(height: 12),
        _buildOptionSelector(
          options: [
            ('new', 'New Only', Icons.new_releases),
            ('used', 'Gently Used', Icons.recycling),
            ('both', 'Both Accepted', Icons.check_circle),
          ],
          selectedValue: _clothesCondition,
          onSelect: (value) => setState(() => _clothesCondition = value),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Clothes For', Icons.people),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Men', 'Women', 'Children'].map((item) {
            final isSelected = _clothesFor.contains(item);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _clothesFor.remove(item);
                  } else {
                    _clothesFor.add(item);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.ngoColor.withValues(alpha: 0.1)
                      : AppTheme.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.ngoColor : AppTheme.borderGrey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Season', Icons.wb_sunny),
        const SizedBox(height: 12),
        _buildOptionSelector(
          options: [
            ('winter', 'Winter', Icons.ac_unit),
            ('summer', 'Summer', Icons.wb_sunny),
            ('all', 'All Season', Icons.calendar_today),
          ],
          selectedValue: _clothesSeason,
          onSelect: (value) => setState(() => _clothesSeason = value),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMedicalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Medical Supply Type', Icons.medical_services),
        const SizedBox(height: 12),
        _buildOptionSelector(
          options: [
            ('medicines', 'Medicines', Icons.medication),
            ('equipment', 'Equipment', Icons.monitor_heart),
            ('supplies', 'Supplies', Icons.medical_information),
          ],
          selectedValue: _medicalType,
          onSelect: (value) => setState(() => _medicalType = value),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEducationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Education Material Type', Icons.school),
        const SizedBox(height: 12),
        _buildOptionSelector(
          options: [
            ('books', 'Books', Icons.menu_book),
            ('stationery', 'Stationery', Icons.edit),
            ('bags', 'School Bags', Icons.backpack),
            ('uniforms', 'Uniforms', Icons.checkroom),
          ],
          selectedValue: _educationType,
          onSelect: (value) => setState(() => _educationType = value),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Education Level', Icons.school),
        const SizedBox(height: 12),
        _buildOptionSelector(
          options: [
            ('primary', 'Primary', Icons.child_care),
            ('secondary', 'Secondary', Icons.person),
            ('college', 'College', Icons.school),
            ('all', 'All Levels', Icons.groups),
          ],
          selectedValue: _educationLevel,
          onSelect: (value) => setState(() => _educationLevel = value),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOptionSelector({
    required List<(String, String, IconData)> options,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selectedValue == opt.$1;
        return GestureDetector(
          onTap: () => onSelect(opt.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.ngoColor.withValues(alpha: 0.1)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTheme.ngoColor : AppTheme.borderGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opt.$3,
                  size: 18,
                  color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  opt.$2,
                  style: TextStyle(
                    color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.ngoColor.withValues(alpha: 0.1)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.ngoColor : AppTheme.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
