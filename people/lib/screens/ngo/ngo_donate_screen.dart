import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/donation_request.dart';
import 'create_donation_request_screen.dart';
import '../common/public_ngo_profile_screen.dart';

class NGODonateScreen extends StatefulWidget {
  const NGODonateScreen({super.key});

  @override
  State<NGODonateScreen> createState() => _NGODonateScreenState();
}

class _NGODonateScreenState extends State<NGODonateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDonationType = 'Money';
  DonationRequest? _selectedRequest;
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'All';
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _useDummyData = true; // Toggle for dummy data

  // Dummy donation requests for preview
  final List<DonationRequest> _dummyRequests = [
    DonationRequest(
      id: '1',
      ngoId: 'ngo1',
      ngoName: 'Green Earth Foundation',
      title: 'Tree Plantation Drive 2026',
      description:
          'We are organizing a massive tree plantation drive across Mumbai to combat air pollution. Your contribution will help us plant 10,000 trees in urban areas and make our city greener.',
      category: DonationCategory.money,
      urgency: UrgencyLevel.high,
      targetAmount: 50000,
      currentAmount: 32500,
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
          'Help us provide school bags, notebooks, and stationery to 500 underprivileged children starting their new academic year. Every child deserves access to education.',
      category: DonationCategory.education,
      urgency: UrgencyLevel.medium,
      targetQuantity: 500,
      currentQuantity: 234,
      location: 'Delhi, India',
      deadline: DateTime.now().add(const Duration(days: 20)),
      contactPerson: 'Priya Patel',
      contactPhone: '+91 87654 32109',
    ),
    DonationRequest(
      id: '3',
      ngoId: 'ngo3',
      ngoName: 'Health First Initiative',
      title: 'Medical Camp Equipment',
      description:
          'We need funds to purchase essential medical equipment for our free health camps in rural Karnataka. Help us serve communities without access to healthcare.',
      category: DonationCategory.medical,
      urgency: UrgencyLevel.critical,
      targetAmount: 75000,
      currentAmount: 15000,
      location: 'Bangalore, India',
      deadline: DateTime.now().add(const Duration(days: 45)),
      contactPerson: 'Dr. Anita Rao',
      contactPhone: '+91 76543 21098',
    ),
    DonationRequest(
      id: '4',
      ngoId: 'ngo4',
      ngoName: 'Food Bank India',
      title: 'Daily Meals for Homeless',
      description:
          'Support our mission to provide nutritious meals to 200 homeless people daily. Every meal brings hope and nourishment to those in need.',
      category: DonationCategory.food,
      urgency: UrgencyLevel.high,
      targetQuantity: 6000,
      currentQuantity: 4200,
      location: 'Chennai, India',
      deadline: DateTime.now().add(const Duration(days: 15)),
      contactPerson: 'Vijay Kumar',
      contactPhone: '+91 65432 10987',
    ),
    DonationRequest(
      id: '5',
      ngoId: 'ngo5',
      ngoName: 'Clothes for Care',
      title: 'Winter Clothing Drive',
      description:
          'Collect warm clothes for families in need during the harsh winter months. We need blankets, sweaters, and jackets to keep people warm.',
      category: DonationCategory.clothes,
      urgency: UrgencyLevel.medium,
      targetQuantity: 1000,
      currentQuantity: 450,
      location: 'Kolkata, India',
      deadline: DateTime.now().add(const Duration(days: 30)),
      contactPerson: 'Meera Sen',
      contactPhone: '+91 54321 09876',
    ),
  ];

  List<DonationRequest> get _filteredDummyRequests {
    if (_selectedCategory == 'All') return _dummyRequests;
    return _dummyRequests
        .where(
          (r) =>
              r.category.name.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

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

  // Get donation requests stream (exclude current NGO's own requests)
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

  void _navigateToCreateRequest() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateDonationRequestScreen(),
      ),
    );
    // If a request was created, refresh (setState will trigger rebuild)
    if (result == true) {
      setState(() {});
    }
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
              color: AppTheme.ngoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: AppTheme.ngoColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support NGOs',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Donate to active requests',
                  style: TextStyle(color: AppTheme.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          // Create Request Button
          GestureDetector(
            onTap: _navigateToCreateRequest,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.ngoColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
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
          color: AppTheme.ngoColor,
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
        // Search & Filter Section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                          hintText: 'Search donation requests...',
                          hintStyle: TextStyle(
                            color: AppTheme.grey,
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
              const SizedBox(height: 16),
              // Category Filter
              _buildCategoryFilter(),
            ],
          ),
        ),
        // Requests List
        Expanded(
          child: _useDummyData
              ? _buildDummyRequestsList()
              : StreamBuilder<QuerySnapshot>(
                  stream: _getDonationRequestsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.ngoColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Error loading requests',
                              style: TextStyle(color: AppTheme.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    // Filter out current user's own requests
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['ngoId'] != _currentUserId;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            filteredDocs[index].data() as Map<String, dynamic>;
                        final request = DonationRequest.fromMap(data);
                        return _buildRequestCard(request);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDummyRequestsList() {
    final requests = _filteredDummyRequests;

    if (requests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(requests[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.ngoColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volunteer_activism,
              size: 48,
              color: AppTheme.ngoColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Active Requests',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no donation requests\navailable at the moment',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'name': 'All', 'icon': Icons.apps, 'color': AppTheme.ngoColor},
      {'name': 'Money', 'icon': Icons.attach_money, 'color': AppTheme.success},
      {'name': 'Food', 'icon': Icons.restaurant, 'color': AppTheme.gold},
      {'name': 'Clothes', 'icon': Icons.checkroom, 'color': AppTheme.info},
      {
        'name': 'Medical',
        'icon': Icons.medical_services,
        'color': AppTheme.accent,
      },
      {
        'name': 'Education',
        'icon': Icons.school,
        'color': AppTheme.volunteerColor,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedCategory = cat['name'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (cat['color'] as Color)
                    : (cat['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : cat['color'] as Color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : cat['color'] as Color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            request.location,
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
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
                      fontSize: 9,
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
            const SizedBox(height: 8),
            // Description
            Text(
              request.description,
              style: TextStyle(color: AppTheme.grey, fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Goal section (progress hidden - only visible to request owner)
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
                        // Urgency Badge
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
                        // Goal Card (progress hidden - only visible to request owner)
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
                        // Details Grid
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                Icons.calendar_today,
                                'Created',
                                _formatDate(request.createdAt),
                              ),
                              const Divider(height: 20),
                              _buildDetailRow(
                                Icons.access_time,
                                'Deadline',
                                request.deadline != null
                                    ? _formatDate(request.deadline!)
                                    : 'No deadline',
                              ),
                              if (request.deadline != null) ...[
                                const Divider(height: 20),
                                _buildDetailRow(
                                  Icons.hourglass_bottom,
                                  'Days Left',
                                  '${request.deadline!.difference(DateTime.now()).inDays} days',
                                ),
                              ],
                              if (request.contactPerson != null) ...[
                                const Divider(height: 20),
                                _buildDetailRow(
                                  Icons.person,
                                  'Contact',
                                  request.contactPerson!,
                                ),
                              ],
                              if (request.contactPhone != null) ...[
                                const Divider(height: 20),
                                _buildDetailRow(
                                  Icons.phone,
                                  'Phone',
                                  request.contactPhone!,
                                ),
                              ],
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
            // Floating Donate Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedRequest = request;
                    _selectedDonationType =
                        request.category == DonationCategory.money
                        ? 'Money'
                        : request.category.name;
                    _tabController.animateTo(1);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ngoColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.send_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Request to Contribute',
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
          ],
        ),
      ),
    );
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.grey),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getCategoryColor(DonationCategory category) {
    switch (category) {
      case DonationCategory.money:
        return AppTheme.success;
      case DonationCategory.food:
        return AppTheme.gold;
      case DonationCategory.clothes:
        return AppTheme.info;
      case DonationCategory.medical:
        return AppTheme.accent;
      case DonationCategory.education:
        return AppTheme.volunteerColor;
      case DonationCategory.other:
        return AppTheme.ngoColor;
    }
  }

  IconData _getCategoryIcon(DonationCategory category) {
    switch (category) {
      case DonationCategory.money:
        return Icons.attach_money;
      case DonationCategory.food:
        return Icons.restaurant;
      case DonationCategory.clothes:
        return Icons.checkroom;
      case DonationCategory.medical:
        return Icons.medical_services;
      case DonationCategory.education:
        return Icons.school;
      case DonationCategory.other:
        return Icons.inventory_2;
    }
  }

  Color _getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return AppTheme.success;
      case UrgencyLevel.medium:
        return AppTheme.gold;
      case UrgencyLevel.high:
        return AppTheme.accent;
      case UrgencyLevel.critical:
        return AppTheme.error;
    }
  }

  Widget _buildMakeDonation() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Selected Request Info (if any)
        if (_selectedRequest != null) ...[
          _buildSelectedRequestCard(),
          const SizedBox(height: 20),
        ],
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
        // Summary Card
        _buildDonationSummary(),
        const SizedBox(height: 24),
        // Donate Button
        _buildDonateButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSelectedRequestCard() {
    final request = _selectedRequest!;
    final categoryColor = _getCategoryColor(request.category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(request.category),
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'by ${request.ngoName}',
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedRequest = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.close, size: 16, color: AppTheme.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTypeSelector() {
    final types = [
      {'name': 'Money', 'icon': Icons.attach_money, 'color': AppTheme.success},
      {'name': 'Clothes', 'icon': Icons.checkroom, 'color': AppTheme.info},
      {'name': 'Food', 'icon': Icons.restaurant, 'color': AppTheme.gold},
      {
        'name': 'Medical',
        'icon': Icons.medical_services,
        'color': AppTheme.accent,
      },
      {
        'name': 'Education',
        'icon': Icons.school,
        'color': AppTheme.volunteerColor,
      },
      {'name': 'Other', 'icon': Icons.inventory_2, 'color': AppTheme.ngoColor},
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

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: AppTheme.primaryDark,
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
                fontWeight: FontWeight.w600,
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
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: AppTheme.primaryDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.inventory_2, color: AppTheme.info),
          hintText: '0 items',
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
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(14),
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

  Widget _buildDonationSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.ngoColor,
        borderRadius: BorderRadius.circular(16),
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
          _buildSummaryRow('To', _selectedRequest?.ngoName ?? 'Not selected'),
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
              color: AppTheme.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonateButton() {
    final isValid =
        _selectedRequest != null &&
        ((_selectedDonationType == 'Money' &&
                _amountController.text.isNotEmpty) ||
            (_selectedDonationType != 'Money' &&
                _quantityController.text.isNotEmpty));

    return ElevatedButton(
      onPressed: isValid ? _processDonation : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isValid ? AppTheme.success : AppTheme.grey,
        disabledBackgroundColor: AppTheme.grey.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            color: isValid ? Colors.white : AppTheme.grey,
          ),
          const SizedBox(width: 10),
          Text(
            'Complete Donation',
            style: TextStyle(
              color: isValid ? Colors.white : AppTheme.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _processDonation() {
    // TODO: Implement actual donation processing with Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donation submitted to ${_selectedRequest?.ngoName}'),
        backgroundColor: AppTheme.success,
      ),
    );

    // Reset form
    setState(() {
      _selectedRequest = null;
      _amountController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      _tabController.animateTo(0);
    });
  }
}
