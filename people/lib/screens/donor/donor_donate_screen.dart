import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';
import '../../models/donation_request.dart';
import '../common/public_ngo_profile_screen.dart';

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
  String _selectedCategory = 'All';
  DonationRequest? _selectedRequest;

  final DonationService _donationService = DonationService();
  bool _isSubmitting = false;
  bool _useDummyData = true; // Toggle for dummy data

  // Dummy donation requests for preview
  final List<DonationRequest> _dummyRequests = [
    DonationRequest(
      id: '1',
      ngoId: 'ngo1',
      ngoName: 'Green Earth Foundation',
      title: 'Tree Plantation Drive 2026',
      description:
          '📋 Purpose: We are organizing a massive tree plantation drive across Mumbai.\n\n🌍 ENVIRONMENTAL INITIATIVE:\n• Type: Urban Reforestation\n• Goal: Plant 10,000 trees\n\n📝 SPECIFIC ITEMS NEEDED:\n- Tree saplings\n- Gardening tools\n- Volunteers',
      category: DonationCategory.money,
      urgency: UrgencyLevel.high,
      targetAmount: 50000,
      currentAmount: 0,
      location: 'Mumbai, India',
      deadline: DateTime.now().add(const Duration(days: 25)),
      contactPerson: 'Raj Sharma',
      contactPhone: '+91 98765 43210',
    ),
    DonationRequest(
      id: '2',
      ngoId: 'ngo2',
      ngoName: 'Education For All',
      title: 'School Supplies for 500 Children',
      description:
          '📋 Purpose: Help underprivileged children start their new academic year.\n\n📚 EDUCATION REQUIREMENTS:\n• Type: Stationery\n• Level: Primary School\n\n📝 SPECIFIC ITEMS NEEDED:\n- 500 School bags\n- 1000 Notebooks\n- Geometry boxes',
      category: DonationCategory.education,
      urgency: UrgencyLevel.medium,
      targetQuantity: 500,
      currentQuantity: 0,
      location: 'Delhi, India',
      deadline: DateTime.now().add(const Duration(days: 20)),
      contactPerson: 'Priya Patel',
      contactPhone: '+91 87654 32109',
    ),
    DonationRequest(
      id: '3',
      ngoId: 'ngo3',
      ngoName: 'Food For Humanity',
      title: 'Daily Meals for 200 Homeless',
      description:
          '📋 Purpose: Provide nutritious meals to homeless individuals.\n\n🍽️ FOOD REQUIREMENTS:\n• Type: Ready-made Meals\n• Dietary: Vegetarian Only\n\n📝 SPECIFIC ITEMS NEEDED:\n- Ready-to-eat meal packets\n- Rice and dal\n- Fresh vegetables',
      category: DonationCategory.food,
      urgency: UrgencyLevel.critical,
      targetQuantity: 6000,
      currentQuantity: 0,
      location: 'Kolkata, India',
      deadline: DateTime.now().add(const Duration(days: 30)),
      contactPerson: 'Amit Das',
      contactPhone: '+91 76543 21098',
    ),
  ];

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

  // Get donation requests stream
  Stream<QuerySnapshot> _getDonationRequestsStream() {
    Query query = FirebaseFirestore.instance
        .collection('donation_requests')
        .where('status', isEqualTo: 'active');

    if (_selectedCategory != 'All') {
      query = query.where(
        'category',
        isEqualTo: _selectedCategory.toLowerCase(),
      );
    }

    return query.orderBy('createdAt', descending: true).snapshots();
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
            children: [_buildDonationRequests(), _buildMakeDonation()],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.donorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: AppTheme.donorColor,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
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
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.donorColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.grey,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Donation Requests'),
          Tab(text: 'Quick Donate'),
        ],
      ),
    );
  }

  Widget _buildDonationRequests() {
    return Column(
      children: [
        // Category Filter
        _buildCategoryFilter(),
        // Donation Requests List
        Expanded(
          child: _useDummyData
              ? _buildDummyRequestsList()
              : _buildFirestoreRequestsList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Money',
      'Food',
      'Clothes',
      'Medical',
      'Education',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.donorColor
                        : AppTheme.donorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.donorColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDummyRequestsList() {
    final filteredRequests = _selectedCategory == 'All'
        ? _dummyRequests
        : _dummyRequests
              .where(
                (r) =>
                    r.category.name.toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();

    if (filteredRequests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) =>
          _buildRequestCard(filteredRequests[index]),
    );
  }

  Widget _buildFirestoreRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getDonationRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.donorColor),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading requests',
                  style: TextStyle(color: AppTheme.grey),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final request = DonationRequest.fromMap(data);
            return _buildRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              color: AppTheme.grey.withValues(alpha: 0.5),
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Donation Requests',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Active donation requests will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(DonationRequest request) {
    final categoryColor = _getCategoryColor(request.category);
    final urgencyColor = _getUrgencyColor(request.urgency);

    return GestureDetector(
      onTap: () => _showRequestDetailsModal(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: NGO Name + Urgency Badge
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(request.category),
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.ngoName,
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.location,
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Urgency Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    request.urgency.name.toUpperCase(),
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Title
            Text(
              request.title,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Goal section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    request.category == DonationCategory.money
                        ? Icons.currency_rupee
                        : Icons.inventory_2_outlined,
                    color: categoryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.category == DonationCategory.money
                        ? 'Goal: ₹${request.targetAmount?.toStringAsFixed(0) ?? '0'}'
                        : 'Need: ${request.targetQuantity ?? 0} items',
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Footer: Deadline
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppTheme.grey),
                const SizedBox(width: 4),
                Text(
                  request.deadline != null
                      ? '${request.deadline!.difference(DateTime.now()).inDays} days left'
                      : 'No deadline',
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(DonationCategory category) {
    switch (category) {
      case DonationCategory.money:
        return AppTheme.success;
      case DonationCategory.food:
        return AppTheme.gold;
      case DonationCategory.clothes:
        return AppTheme.purple;
      case DonationCategory.medical:
        return AppTheme.error;
      case DonationCategory.education:
        return AppTheme.info;
      case DonationCategory.other:
        return AppTheme.grey;
    }
  }

  Color _getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return AppTheme.success;
      case UrgencyLevel.medium:
        return AppTheme.warning;
      case UrgencyLevel.high:
        return Colors.orange;
      case UrgencyLevel.critical:
        return AppTheme.error;
    }
  }

  IconData _getCategoryIcon(DonationCategory category) {
    switch (category) {
      case DonationCategory.money:
        return Icons.currency_rupee;
      case DonationCategory.food:
        return Icons.restaurant;
      case DonationCategory.clothes:
        return Icons.checkroom;
      case DonationCategory.medical:
        return Icons.medical_services;
      case DonationCategory.education:
        return Icons.school;
      case DonationCategory.other:
        return Icons.category;
    }
  }

  void _navigateToNGOProfile(String ngoId, String ngoName) {
    Navigator.pop(context); // Close modal first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PublicNGOProfileScreen(ngoId: ngoId, ngoName: ngoName),
      ),
    );
  }

  void _showRequestDetailsModal(DonationRequest request) {
    final categoryColor = _getCategoryColor(request.category);
    final urgencyColor = _getUrgencyColor(request.urgency);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NGO Info (Clickable)
                        GestureDetector(
                          onTap: () => _navigateToNGOProfile(
                            request.ngoId,
                            request.ngoName,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.business,
                                    color: categoryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              request.ngoName,
                                              style: const TextStyle(
                                                color: AppTheme.primaryDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: AppTheme.grey,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: AppTheme.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            request.location,
                                            style: TextStyle(
                                              color: AppTheme.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Urgency + Category Badges
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: urgencyColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.priority_high,
                                    size: 14,
                                    color: urgencyColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${request.urgency.name.toUpperCase()} PRIORITY',
                                    style: TextStyle(
                                      color: urgencyColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(request.category),
                                    size: 14,
                                    color: categoryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    request.category.name.toUpperCase(),
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          request.title,
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Goal Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: categoryColor.withValues(alpha: 0.15),
                                ),
                                child: Icon(
                                  request.category == DonationCategory.money
                                      ? Icons.currency_rupee
                                      : Icons.inventory_2_outlined,
                                  color: categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.category == DonationCategory.money
                                          ? '₹${request.targetAmount?.toStringAsFixed(0) ?? '0'}'
                                          : '${request.targetQuantity ?? 0} items',
                                      style: TextStyle(
                                        color: categoryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      request.category == DonationCategory.money
                                          ? 'Donation Goal'
                                          : 'Items Needed',
                                      style: TextStyle(
                                        color: AppTheme.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Description
                        const Text(
                          'About this Request',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          request.description,
                          style: TextStyle(
                            color: AppTheme.grey,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Deadline
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: AppTheme.grey,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Deadline: ',
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                request.deadline != null
                                    ? '${request.deadline!.day}/${request.deadline!.month}/${request.deadline!.year}'
                                    : 'No deadline',
                                style: const TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                request.deadline != null
                                    ? '${request.deadline!.difference(DateTime.now()).inDays} days left'
                                    : '',
                                style: TextStyle(
                                  color: AppTheme.warning,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedRequest = request;
                      _selectedNGO = request.ngoName;
                      _selectedNGOId = request.ngoId;
                      _selectedDonationType =
                          request.category == DonationCategory.money
                          ? 'Money'
                          : request.category.name;
                      _tabController.animateTo(1);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.donorColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volunteer_activism, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Donate Now',
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
            ),
          ],
        ),
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
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14,
                  ),
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
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  color: AppTheme.grey.withValues(alpha: 0.5),
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No NGOs Available',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'NGOs will appear here once added to the platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.grey, fontSize: 13),
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < categories.length - 1 ? 10 : 0,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
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
                            color: (ngo['color'] as Color).withValues(
                              alpha: 0.15,
                            ),
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
