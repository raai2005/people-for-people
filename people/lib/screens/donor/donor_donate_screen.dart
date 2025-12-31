import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

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
              gradient: AppTheme.donorGradient,
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
                    color: AppTheme.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Support causes you care about',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
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
        color: AppTheme.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.donorGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.donorColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.white.withValues(alpha: 0.5),
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
    final ngos = _getMockNGOs();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppTheme.white.withValues(alpha: 0.5),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'Search NGOs by name or cause...',
                    hintStyle: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
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
        // NGO List
        const Text(
          'Featured NGOs',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...ngos.map((ngo) => _buildNGOCard(ngo)),
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
            color: AppTheme.white,
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
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
        ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.white.withValues(alpha: 0.08),
            AppTheme.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.15)),
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
                        gradient: LinearGradient(
                          colors: [
                            (ngo['color'] as Color).withValues(alpha: 0.3),
                            (ngo['color'] as Color).withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (ngo['color'] as Color).withValues(alpha: 0.4),
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
                              color: AppTheme.white,
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
                    color: AppTheme.white.withValues(alpha: 0.7),
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
        Icon(icon, size: 14, color: AppTheme.white.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
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
            color: AppTheme.white,
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
            color: AppTheme.white,
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
              color: AppTheme.white,
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
              color: AppTheme.white,
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
            color: AppTheme.white,
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
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        (type['color'] as Color).withValues(alpha: 0.3),
                        (type['color'] as Color).withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              color: isSelected ? null : AppTheme.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (type['color'] as Color).withValues(alpha: 0.5)
                    : AppTheme.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected
                      ? type['color'] as Color
                      : AppTheme.white.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  type['name'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? type['color'] as Color
                        : AppTheme.white.withValues(alpha: 0.6),
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
    final ngos = _getMockNGOs();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedNGO,
          hint: Text(
            'Choose an NGO',
            style: TextStyle(color: AppTheme.white.withValues(alpha: 0.5)),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.white),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppTheme.white.withValues(alpha: 0.5),
          ),
          items: ngos.map((ngo) {
            return DropdownMenuItem<String>(
              value: ngo['name'] as String,
              child: Row(
                children: [
                  Icon(
                    ngo['icon'] as IconData,
                    color: ngo['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(ngo['name'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedNGO = value),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
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
          hintStyle: TextStyle(color: AppTheme.white.withValues(alpha: 0.3)),
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
        color: AppTheme.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
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
          hintStyle: TextStyle(color: AppTheme.white.withValues(alpha: 0.3)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        style: const TextStyle(color: AppTheme.white),
        decoration: InputDecoration(
          hintText: 'Add details about your donation...',
          hintStyle: TextStyle(color: AppTheme.white.withValues(alpha: 0.3)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPickupDeliveryOption() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.info.withValues(alpha: 0.15),
            AppTheme.info.withValues(alpha: 0.05),
          ],
        ),
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
                  color: AppTheme.white,
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
              color: AppTheme.white.withValues(alpha: 0.7),
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
        gradient: LinearGradient(
          colors: [
            AppTheme.donorColor.withValues(alpha: 0.2),
            AppTheme.donorColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.donorColor.withValues(alpha: 0.3)),
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
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.primaryDark.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (ngo['color'] as Color).withValues(alpha: 0.3),
                                (ngo['color'] as Color).withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (ngo['color'] as Color).withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Icon(
                            ngo['icon'] as IconData,
                            color: ngo['color'] as Color,
                            size: 40,
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
                                  color: AppTheme.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppTheme.white.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ngo['location'] as String,
                                    style: TextStyle(
                                      color: AppTheme.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // About
                    const Text(
                      'About',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ngo['fullDescription'] as String,
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailStat(
                            Icons.people,
                            '${ngo['donors']}',
                            'Donors',
                          ),
                        ),
                        Expanded(
                          child: _buildDetailStat(
                            Icons.star,
                            '${ngo['rating']}',
                            'Rating',
                          ),
                        ),
                        Expanded(
                          child: _buildDetailStat(
                            Icons.volunteer_activism,
                            '${ngo['projects']}',
                            'Projects',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Donate Button
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
                        ),
                        child: const Text(
                          'Donate Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.donorColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _submitDonation() {
    if (_selectedNGO == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an NGO'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    if (_selectedDonationType == 'Money' && _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter donation amount'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    if (_selectedDonationType != 'Money' && _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter quantity'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Show success
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 60,
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
                  // Reset form
                  setState(() {
                    _selectedNGO = null;
                    _amountController.clear();
                    _quantityController.clear();
                    _descriptionController.clear();
                  });
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

  List<Map<String, dynamic>> _getMockNGOs() {
    return [
      {
        'name': 'Hope Foundation',
        'category': 'Education',
        'location': 'Mumbai, India',
        'description':
            'Providing quality education to underprivileged children across India.',
        'fullDescription':
            'Hope Foundation has been working since 2010 to provide quality education to underprivileged children. We run 50+ schools across India, providing free education, meals, and healthcare to over 10,000 students.',
        'icon': Icons.school,
        'color': AppTheme.info,
        'verified': true,
        'donors': '2.5K',
        'rating': '4.8',
        'projects': '50+',
      },
      {
        'name': 'Care India',
        'category': 'Health',
        'location': 'Delhi, India',
        'description':
            'Healthcare services and medical support for rural communities.',
        'fullDescription':
            'Care India focuses on providing accessible healthcare to rural and underserved communities. We operate mobile clinics, health camps, and awareness programs reaching over 100,000 people annually.',
        'icon': Icons.medical_services,
        'color': AppTheme.accent,
        'verified': true,
        'donors': '3.2K',
        'rating': '4.9',
        'projects': '75+',
      },
      {
        'name': 'Feeding India',
        'category': 'Food',
        'location': 'Bangalore, India',
        'description': 'Fighting hunger by providing meals to those in need.',
        'fullDescription':
            'Feeding India works to eliminate hunger by collecting surplus food from restaurants and events, and distributing it to the hungry. We serve over 5,000 meals daily across 10 cities.',
        'icon': Icons.restaurant,
        'color': AppTheme.gold,
        'verified': true,
        'donors': '1.8K',
        'rating': '4.7',
        'projects': '30+',
      },
      {
        'name': 'Green Earth',
        'category': 'Environment',
        'location': 'Pune, India',
        'description':
            'Environmental conservation and sustainability initiatives.',
        'fullDescription':
            'Green Earth is dedicated to environmental conservation through tree plantation drives, waste management programs, and sustainability education. We\'ve planted over 100,000 trees and cleaned 50+ water bodies.',
        'icon': Icons.eco,
        'color': AppTheme.success,
        'verified': true,
        'donors': '1.5K',
        'rating': '4.6',
        'projects': '40+',
      },
      {
        'name': 'Shelter Home',
        'category': 'Welfare',
        'location': 'Chennai, India',
        'description': 'Providing shelter and support to homeless individuals.',
        'fullDescription':
            'Shelter Home provides safe accommodation, food, and rehabilitation services to homeless individuals. We currently house 500+ people and provide vocational training for sustainable livelihoods.',
        'icon': Icons.home,
        'color': AppTheme.volunteerColor,
        'verified': false,
        'donors': '900',
        'rating': '4.5',
        'projects': '15+',
      },
    ];
  }
}
