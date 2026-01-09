import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../common/public_ngo_profile_screen.dart';

class DonorDeliveriesScreen extends StatefulWidget {
  const DonorDeliveriesScreen({super.key});

  @override
  State<DonorDeliveriesScreen> createState() => _DonorDeliveriesScreenState();
}

class _DonorDeliveriesScreenState extends State<DonorDeliveriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Toggle for dummy data vs Firestore
  final bool _useDummyData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.grey,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _useDummyData ? _buildDummyPendingList() : _buildFirestorePendingList(),
              _useDummyData ? _buildDummyCompletedList() : _buildFirestoreCompletedList(),
            ],
          ),
        ),
      ],
    );
  }

  // Dummy data for testing
  List<DonorDelivery> _getDummyPendingDeliveries() {
    return [
      DonorDelivery(
        id: '1',
        ngoId: 'ngo_001',
        ngoName: 'Hope Foundation',
        ngoAddress: '456 NGO Lane, Bandra East, Mumbai',
        ngoPhone: '+91 98765 43210',
        itemName: 'Winter Clothes',
        quantity: '50 Pcs',
        category: 'Clothes',
        status: DeliveryStatus.approved,
        verificationCode: 'HF-2847',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        approvedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      DonorDelivery(
        id: '2',
        ngoId: 'ngo_002',
        ngoName: 'Food For All',
        ngoAddress: '321 Charity Road, Dadar, Mumbai',
        ngoPhone: '+91 98765 12345',
        itemName: 'Rice & Groceries',
        quantity: '100 Kg',
        category: 'Food',
        status: DeliveryStatus.onTheWay,
        verificationCode: 'FFA-9123',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        approvedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<DonorDelivery> _getDummyCompletedDeliveries() {
    return [
      DonorDelivery(
        id: '3',
        ngoId: 'ngo_003',
        ngoName: 'Education First',
        ngoAddress: '111 School Street, Kurla, Mumbai',
        ngoPhone: '+91 98765 67890',
        itemName: 'School Books & Supplies',
        quantity: '200 Sets',
        category: 'Education',
        status: DeliveryStatus.completed,
        verificationCode: 'EF-5632',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        approvedAt: DateTime.now().subtract(const Duration(days: 4)),
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Widget _buildDummyPendingList() {
    final pending = _getDummyPendingDeliveries();
    if (pending.isEmpty) return _buildEmptyState('No pending deliveries');
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildDeliveryCard(pending[index]),
    );
  }

  Widget _buildDummyCompletedList() {
    final completed = _getDummyCompletedDeliveries();
    if (completed.isEmpty) return _buildEmptyState('No completed deliveries');
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: completed.length,
      itemBuilder: (context, index) => _buildDeliveryCard(completed[index]),
    );
  }

  Widget _buildFirestorePendingList() {
    // TODO: Get current user ID
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('donorId', isEqualTo: 'CURRENT_USER_ID')
          .where('isDonorDelivering', isEqualTo: true)
          .where('status', whereIn: ['approved', 'pendingDelivery', 'onTheWay'])
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.donorColor),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildEmptyState('No pending deliveries');

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final delivery = _mapFirestoreToDelivery(docs[index].id, data);
            return _buildDeliveryCard(delivery);
          },
        );
      },
    );
  }

  Widget _buildFirestoreCompletedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('donorId', isEqualTo: 'CURRENT_USER_ID')
          .where('isDonorDelivering', isEqualTo: true)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.donorColor),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildEmptyState('No completed deliveries');

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final delivery = _mapFirestoreToDelivery(docs[index].id, data);
            return _buildDeliveryCard(delivery);
          },
        );
      },
    );
  }

  DonorDelivery _mapFirestoreToDelivery(String id, Map<String, dynamic> data) {
    return DonorDelivery(
      id: id,
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? 'Unknown NGO',
      ngoAddress: data['ngoAddress'] ?? 'Address not provided',
      ngoPhone: data['ngoPhone'] ?? '',
      itemName: data['itemName'] ?? 'Donation',
      quantity: data['quantity'] ?? '',
      category: data['category'] ?? 'Other',
      status: _parseStatus(data['status']),
      verificationCode: data['verificationCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  DeliveryStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
      case 'pendingDelivery':
        return DeliveryStatus.approved;
      case 'onTheWay':
        return DeliveryStatus.onTheWay;
      case 'completed':
        return DeliveryStatus.completed;
      default:
        return DeliveryStatus.approved;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.donorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.donorColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your deliveries will appear here',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(DonorDelivery delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(delivery.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(delivery.category),
                  color: _getCategoryColor(delivery.category),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.itemName,
                    style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(delivery.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(delivery.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: AppTheme.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Quantity: ${delivery.quantity}',
                      style: TextStyle(color: AppTheme.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // NGO Info
                GestureDetector(
                  onTap: () => _navigateToNGOProfile(delivery.ngoId, delivery.ngoName),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.ngoColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.ngoColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'DELIVER TO',
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.open_in_new, color: AppTheme.ngoColor, size: 14),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          delivery.ngoName,
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: AppTheme.grey, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                delivery.ngoAddress,
                                style: TextStyle(color: AppTheme.grey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (delivery.ngoPhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, color: AppTheme.grey, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                delivery.ngoPhone,
                                style: TextStyle(color: AppTheme.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Verification Code (for pending deliveries)
                if (delivery.status != DeliveryStatus.completed) ...[
                  const SizedBox(height: 16),
                  _buildVerificationCodeSection(delivery),
                ],
                
                // Action buttons (for pending deliveries)
                if (delivery.status != DeliveryStatus.completed) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(delivery),
                ],
                
                // Completed info
                if (delivery.status == DeliveryStatus.completed && delivery.completedAt != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Delivered on ${_formatDate(delivery.completedAt!)}',
                        style: TextStyle(color: AppTheme.success, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCodeSection(DonorDelivery delivery) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: AppTheme.gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Verification Code',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Show this code to the NGO when you deliver:',
            style: TextStyle(color: AppTheme.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.gold),
                  ),
                  child: Center(
                    child: Text(
                      delivery.verificationCode,
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: delivery.verificationCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copied to clipboard'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
                icon: Icon(Icons.copy, color: AppTheme.gold),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DonorDelivery delivery) {
    if (delivery.status == DeliveryStatus.approved) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _markOnTheWay(delivery),
          icon: const Icon(Icons.directions_car),
          label: const Text('I\'m On My Way'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.donorColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    } else if (delivery.status == DeliveryStatus.onTheWay) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Show the verification code to the NGO. They will confirm receipt.',
                    style: TextStyle(color: AppTheme.info, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMaps(delivery.ngoAddress),
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.donorColor,
                    side: const BorderSide(color: AppTheme.donorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callNGO(delivery.ngoPhone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call NGO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ngoColor,
                    side: const BorderSide(color: AppTheme.ngoColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _navigateToNGOProfile(String ngoId, String ngoName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicNGOProfileScreen(
          ngoId: ngoId,
          ngoName: ngoName,
        ),
      ),
    );
  }

  void _markOnTheWay(DonorDelivery delivery) {
    // TODO: Update Firestore
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: AppTheme.donorColor),
            const SizedBox(width: 12),
            const Text('On Your Way!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The NGO has been notified that you\'re on your way.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: AppTheme.gold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Code:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          delivery.verificationCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.donorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
    
    // Update local state for dummy data
    setState(() {});
  }

  void _openMaps(String address) {
    // TODO: Open maps app with address
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening maps for: $address')),
    );
  }

  void _callNGO(String phone) {
    // TODO: Open phone dialer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling: $phone')),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.approved:
        return AppTheme.warning;
      case DeliveryStatus.onTheWay:
        return AppTheme.info;
      case DeliveryStatus.completed:
        return AppTheme.success;
    }
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.approved:
        return 'Ready to Deliver';
      case DeliveryStatus.onTheWay:
        return 'On the Way';
      case DeliveryStatus.completed:
        return 'Completed';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return AppTheme.gold;
      case 'clothes':
        return AppTheme.volunteerColor;
      case 'medical':
        return AppTheme.error;
      case 'education':
        return AppTheme.ngoColor;
      default:
        return AppTheme.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'clothes':
        return Icons.checkroom;
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.inventory_2;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Delivery status enum
enum DeliveryStatus {
  approved,   // NGO approved, ready for donor to deliver
  onTheWay,   // Donor marked they're delivering
  completed,  // NGO confirmed receipt
}

// Model for donor deliveries
class DonorDelivery {
  final String id;
  final String ngoId;
  final String ngoName;
  final String ngoAddress;
  final String ngoPhone;
  final String itemName;
  final String quantity;
  final String category;
  final DeliveryStatus status;
  final String verificationCode;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;

  DonorDelivery({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.ngoAddress,
    required this.ngoPhone,
    required this.itemName,
    required this.quantity,
    required this.category,
    required this.status,
    required this.verificationCode,
    required this.createdAt,
    this.approvedAt,
    this.completedAt,
  });
}
