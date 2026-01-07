import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';

class DonorDonateScreen extends StatefulWidget {
  const DonorDonateScreen({super.key});

  @override
  State<DonorDonateScreen> createState() => _DonorDonateScreenState();
}

class _DonorDonateScreenState extends State<DonorDonateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDonationType = 'Money';
  String? _selectedNGO;
  String? _selectedNGOId;
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DonationService _donationService = DonationService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildDiscoverNGOs(), _buildMakeDonation()],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.donorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make a Donation',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Support causes you care about',
                  style: TextStyle(color: AppTheme.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.donorColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.donorColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppTheme.white, // Keep white for selected tab (gradient bg)
        unselectedLabelColor: AppTheme.grey,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Discover NGOs'),
          Tab(text: 'Quick Donate'),
        ],
      ),
    );
  }

  Widget _buildDiscoverNGOs() {
    // TODO: Fetch NGOs from Firestore
    // final ngos = await FirebaseFirestore.instance.collection('ngos').get();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: AppTheme.primaryDark),
                  decoration: InputDecoration(
                    hintText: 'Search NGOs by name or cause...',
                    hintStyle: TextStyle(color: AppTheme.grey, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Categories
        _buildCategoriesSection(),
        const SizedBox(height: 24),
        // Empty State
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  color: AppTheme.white.withValues(alpha: 0.3),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No NGOs Available',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NGOs will appear here once added to the platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Education', 'icon': Icons.school, 'color': AppTheme.info},
      {
        'name': 'Health',
        'icon': Icons.medical_services,
        'color': AppTheme.accent,
      },
      {'name': 'Food', 'icon': Icons.restaurant, 'color': AppTheme.gold},
      {'name': 'Environment', 'icon': Icons.eco, 'color': AppTheme.success},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: categories.map((cat) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  cat['name'] as String,
                  cat['icon'] as IconData,
                  cat['color'] as Color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNGOCard(Map<String, dynamic> ngo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showNGODetails(ngo),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // NGO Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (ngo['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (ngo['color'] as Color).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        ngo['icon'] as IconData,
                        color: ngo['color'] as Color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // NGO Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ngo['name'] as String,
                            style: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppTheme.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ngo['location'] as String,
                                style: TextStyle(
                                  color: AppTheme.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Verified Badge
                    if (ngo['verified'] == true)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: AppTheme.success,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (ngo['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (ngo['color'] as Color).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    ngo['category'] as String,
                    style: TextStyle(
                      color: ngo['color'] as Color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  ngo['description'] as String,
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                // Stats
                Row(
                  children: [
                    _buildNGOStat(Icons.people, '${ngo['donors']} donors'),
                    const SizedBox(width: 16),
                    _buildNGOStat(Icons.star, '${ngo['rating']} rating'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNGOStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: AppTheme.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMakeDonation() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Donation Type Selection
        const Text(
          'Select Donation Type',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDonationTypeSelector(),
        const SizedBox(height: 24),
        // NGO Selection
        const Text(
          'Select NGO',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildNGODropdown(),
        const SizedBox(height: 24),
        // Amount/Quantity Input
        if (_selectedDonationType == 'Money') ...[
          const Text(
            'Enter Amount',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAmountInput(),
          const SizedBox(height: 16),
          _buildQuickAmounts(),
        ] else ...[
          const Text(
            'Enter Quantity',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuantityInput(),
        ],
        const SizedBox(height: 24),
        // Description
        const Text(
          'Add Description (Optional)',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDescriptionInput(),
        const SizedBox(height: 24),
        // Pickup/Delivery (for items)
        if (_selectedDonationType != 'Money') ...[
          _buildPickupDeliveryOption(),
          const SizedBox(height: 24),
        ],
        // Summary Card
        _buildDonationSummary(),
        const SizedBox(height: 24),
        // Donate Button
        _buildDonateButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDonationTypeSelector() {
    final types = [
      {'name': 'Money', 'icon': Icons.attach_money, 'color': AppTheme.success},
      {
        'name': 'Clothes',
        'icon': Icons.checkroom,
        'color': AppTheme.volunteerColor,
      },
      {'name': 'Food', 'icon': Icons.restaurant, 'color': AppTheme.gold},
      {'name': 'Books', 'icon': Icons.menu_book, 'color': AppTheme.info},
      {
        'name': 'Medical',
        'icon': Icons.medical_services,
        'color': AppTheme.accent,
      },
      {
        'name': 'Other',
        'icon': Icons.inventory_2,
        'color': AppTheme.donorColor,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        final isSelected = _selectedDonationType == type['name'];
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedDonationType = type['name'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (type['color'] as Color).withValues(alpha: 0.15)
                  : AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (type['color'] as Color).withValues(alpha: 0.5)
                    : AppTheme.grey.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected ? type['color'] as Color : AppTheme.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  type['name'] as String,
                  style: TextStyle(
                    color: isSelected ? type['color'] as Color : AppTheme.grey,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNGODropdown() {
    // TODO: Fetch NGOs from Firestore

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, color: AppTheme.grey, size: 32),
            const SizedBox(height: 12),
            Text(
              'No NGOs available',
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please check the Discover tab',
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.currency_rupee, color: AppTheme.success),
          hintText: '0',
          hintStyle: TextStyle(color: AppTheme.grey.withValues(alpha: 0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildQuickAmounts() {
    final amounts = ['500', '1000', '2500', '5000'];

    return Wrap(
      spacing: 10,
      children: amounts.map((amount) {
        return GestureDetector(
          onTap: () => _amountController.text = amount,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '₹$amount',
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.inventory_2,
            color: _getDonationTypeColor(_selectedDonationType),
          ),
          hintText: 'Number of items',
          hintStyle: TextStyle(color: AppTheme.grey.withValues(alpha: 0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        style: const TextStyle(color: AppTheme.primaryDark),
        decoration: InputDecoration(
          hintText: 'Add details about your donation...',
          hintStyle: TextStyle(color: AppTheme.grey.withValues(alpha: 0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPickupDeliveryOption() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppTheme.info, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Pickup & Delivery',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll arrange pickup from your location. Our team will contact you within 24 hours.',
            style: TextStyle(
              color: AppTheme.primaryDark.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.donorColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.donorColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donation Summary',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Type', _selectedDonationType),
          _buildSummaryRow('NGO', _selectedNGO ?? 'Not selected'),
          if (_selectedDonationType == 'Money' &&
              _amountController.text.isNotEmpty)
            _buildSummaryRow('Amount', '₹${_amountController.text}'),
          if (_selectedDonationType != 'Money' &&
              _quantityController.text.isNotEmpty)
            _buildSummaryRow('Quantity', '${_quantityController.text} items'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitDonation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.donorColor,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 20),
            SizedBox(width: 10),
            Text(
              'Confirm Donation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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

  void _showNGODetails(Map<String, dynamic> ngo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NGO Name & Icon
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: (ngo['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: (ngo['color'] as Color).withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Icon(
                            ngo['icon'] as IconData,
                            color: ngo['color'] as Color,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ngo['name'] as String,
                                style: const TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (ngo['verified'] == true)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: AppTheme.success,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified NGO',
                                      style: TextStyle(
                                        color: AppTheme.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full Address
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.grey.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Address',
                                  style: TextStyle(
                                    color: AppTheme.primaryDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ngo['fullAddress'] as String? ??
                                      ngo['location'] as String,
                                  style: TextStyle(
                                    color: AppTheme.primaryDark.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Row (Rating, Donors, Projects)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (ngo['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (ngo['color'] as Color).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildModalStat(
                            Icons.star,
                            ngo['rating'] as String,
                            'Rating',
                            AppTheme.gold,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.grey.withValues(alpha: 0.2),
                          ),
                          _buildModalStat(
                            Icons.people,
                            ngo['donors'] as String,
                            'Donors',
                            ngo['color'] as Color,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.grey.withValues(alpha: 0.2),
                          ),
                          _buildModalStat(
                            Icons.volunteer_activism,
                            ngo['projects'] as String,
                            'Projects',
                            AppTheme.info,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Deadline/Urgency (if available)
                    if (ngo['deadline'] != null || ngo['urgency'] != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppTheme.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ngo['urgency'] != null)
                                    Text(
                                      'Urgency: ${ngo['urgency']}',
                                      style: const TextStyle(
                                        color: AppTheme.warning,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (ngo['deadline'] != null)
                                    Text(
                                      'Deadline: ${ngo['deadline']}',
                                      style: TextStyle(
                                        color: AppTheme.grey.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // About/Details
                    const Text(
                      'About This Cause',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ngo['fullDescription'] as String,
                      style: TextStyle(
                        color: AppTheme.primaryDark.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Accepted Donation Types
                    const Text(
                      'Accepted Donations',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (ngo['acceptedDonations'] as List<String>?)?.map((
                            type,
                          ) {
                            return _buildDonationTypeChip(type);
                          }).toList() ??
                          [
                            _buildDonationTypeChip('Money'),
                            _buildDonationTypeChip('Clothes'),
                            _buildDonationTypeChip('Food'),
                          ],
                    ),
                    const SizedBox(height: 24),

                    // Donate Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedNGO = ngo['name'] as String;
                            _tabController.animateTo(1);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ngo['color'] as Color,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite, size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Donate Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildModalStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
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
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDonationTypeChip(String type) {
    Color color;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'money':
        color = AppTheme.success;
        icon = Icons.attach_money;
        break;
      case 'clothes':
        color = AppTheme.volunteerColor;
        icon = Icons.checkroom;
        break;
      case 'food':
        color = AppTheme.gold;
        icon = Icons.restaurant;
        break;
      case 'books':
        color = AppTheme.info;
        icon = Icons.menu_book;
        break;
      case 'medical':
        color = AppTheme.accent;
        icon = Icons.medical_services;
        break;
      default:
        color = AppTheme.donorColor;
        icon = Icons.card_giftcard;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDonation() async {
    // Validation
    if (_selectedNGO == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an NGO'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedDonationType == 'Money') {
      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an amount'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else {
      if (_quantityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a quantity'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final quantity = int.tryParse(_quantityController.text);
      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid quantity'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // Use placeholder NGO ID (in production, this comes from selected NGO)
      final ngoId = _selectedNGOId ?? 'placeholder_ngo_id';
      final title = _selectedDonationType == 'Money'
          ? 'Money Donation'
          : '$_selectedDonationType Donation';

      await _donationService.createDonation(
        ngoId: ngoId,
        ngoName: _selectedNGO!,
        title: title,
        type: _selectedDonationType,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        amount: _selectedDonationType == 'Money'
            ? double.parse(_amountController.text)
            : null,
        quantity: _selectedDonationType != 'Money'
            ? int.parse(_quantityController.text)
            : null,
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Donation Submitted!',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you for your generous contribution!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedNGO = null;
                        _selectedNGOId = null;
                        _amountController.clear();
                        _quantityController.clear();
                        _descriptionController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Check your donation in the History tab',
                          ),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit donation: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
