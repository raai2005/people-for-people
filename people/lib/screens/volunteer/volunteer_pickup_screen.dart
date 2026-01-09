import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../common/public_ngo_profile_screen.dart';
import '../common/public_donor_profile_screen.dart';

class VolunteerPickupScreen extends StatefulWidget {
  const VolunteerPickupScreen({super.key});

  @override
  State<VolunteerPickupScreen> createState() => _VolunteerPickupScreenState();
}

class _VolunteerPickupScreenState extends State<VolunteerPickupScreen> {
  // Toggle for dummy data vs Firestore
  final bool _useDummyData = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Pickups',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Help deliver donations to NGOs',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _useDummyData ? _buildDummyContent() : _buildFirestoreContent(),
        ),
      ],
    );
  }

  Widget _buildDummyContent() {
    final dummyPickups = _getDummyPickups();

    if (dummyPickups.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: dummyPickups.length,
      itemBuilder: (context, index) {
        return _buildPickupCard(dummyPickups[index]);
      },
    );
  }

  Widget _buildFirestoreContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('status', isEqualTo: 'needsVolunteer')
          .where('isDonorDelivering', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.volunteerColor),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading pickups',
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
            final pickup = _mapFirestoreToPickup(docs[index].id, data);
            return _buildPickupCard(pickup);
          },
        );
      },
    );
  }

  List<PickupRequest> _getDummyPickups() {
    return [
      PickupRequest(
        id: '1',
        donorId: 'donor_001',
        donorName: 'John Doe',
        donorAddress: '123 Main Street, Andheri West, Mumbai',
        ngoId: 'ngo_001',
        ngoName: 'Hope Foundation',
        ngoAddress: '456 NGO Lane, Bandra East, Mumbai',
        itemName: 'Winter Clothes',
        quantity: '50 Pcs',
        category: 'Clothes',
        urgency: 'Urgent',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        distance: 5.2,
      ),
      PickupRequest(
        id: '2',
        donorId: 'donor_002',
        donorName: 'Sarah Smith',
        donorAddress: '789 Park Avenue, Powai, Mumbai',
        ngoId: 'ngo_002',
        ngoName: 'Food For All',
        ngoAddress: '321 Charity Road, Dadar, Mumbai',
        itemName: 'Rice & Groceries',
        quantity: '100 Kg',
        category: 'Food',
        urgency: 'Today',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        distance: 8.7,
      ),
      PickupRequest(
        id: '3',
        donorId: 'donor_003',
        donorName: 'Mike Johnson',
        donorAddress: '555 Corporate Park, BKC, Mumbai',
        ngoId: 'ngo_003',
        ngoName: 'Education First',
        ngoAddress: '111 School Street, Kurla, Mumbai',
        itemName: 'School Books & Supplies',
        quantity: '200 Sets',
        category: 'Education',
        urgency: 'This Week',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        distance: 12.3,
      ),
    ];
  }

  PickupRequest _mapFirestoreToPickup(String id, Map<String, dynamic> data) {
    return PickupRequest(
      id: id,
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? 'Unknown Donor',
      donorAddress: data['donorAddress'] ?? 'Address not provided',
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? 'Unknown NGO',
      ngoAddress: data['ngoAddress'] ?? 'Address not provided',
      itemName: data['itemName'] ?? 'Donation',
      quantity: data['quantity'] ?? '',
      category: data['category'] ?? 'Other',
      urgency: _calculateUrgency(data['createdAt']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      distance: data['distance']?.toDouble() ?? 0.0,
    );
  }

  String _calculateUrgency(Timestamp? createdAt) {
    if (createdAt == null) return 'Normal';
    final hours = DateTime.now().difference(createdAt.toDate()).inHours;
    if (hours < 6) return 'Urgent';
    if (hours < 24) return 'Today';
    return 'This Week';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.volunteerColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.volunteerColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Pickups Available',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new pickup opportunities',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupCard(PickupRequest pickup) {
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
          // Header with category and urgency
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getCategoryColor(pickup.category).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(pickup.category),
                  color: _getCategoryColor(pickup.category),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  pickup.itemName,
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(pickup.urgency),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pickup.urgency,
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
                      'Quantity: ${pickup.quantity}',
                      style: TextStyle(color: AppTheme.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    if (pickup.distance > 0)
                      Row(
                        children: [
                          Icon(Icons.navigation, color: AppTheme.volunteerColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${pickup.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: AppTheme.volunteerColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Pickup From (Donor)
                _buildLocationRow(
                  icon: Icons.arrow_upward,
                  iconColor: AppTheme.success,
                  label: 'PICKUP FROM',
                  name: pickup.donorName,
                  address: pickup.donorAddress,
                  onTap: () => _navigateToDonorProfile(pickup.donorId, pickup.donorName),
                ),
                const SizedBox(height: 12),
                // Dotted line
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      children: List.generate(3, (i) => Container(
                        width: 2,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: AppTheme.grey.withValues(alpha: 0.3),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Deliver To (NGO)
                _buildLocationRow(
                  icon: Icons.arrow_downward,
                  iconColor: AppTheme.ngoColor,
                  label: 'DELIVER TO',
                  name: pickup.ngoName,
                  address: pickup.ngoAddress,
                  onTap: () => _navigateToNGOProfile(pickup.ngoId, pickup.ngoName),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDetailsModal(pickup),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.volunteerColor,
                          side: const BorderSide(color: AppTheme.volunteerColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptPickup(pickup),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.volunteerColor,
                          foregroundColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String name,
    required String address,
    required VoidCallback onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new, color: iconColor, size: 12),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(color: AppTheme.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
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

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return AppTheme.error;
      case 'today':
        return AppTheme.gold;
      default:
        return AppTheme.success;
    }
  }

  void _navigateToDonorProfile(String donorId, String donorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicDonorProfileScreen(
          donorId: donorId,
          donorName: donorName,
        ),
      ),
    );
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

  void _showDetailsModal(PickupRequest pickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(pickup.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(pickup.category),
                      color: _getCategoryColor(pickup.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup.itemName,
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          pickup.quantity,
                          style: TextStyle(color: AppTheme.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppTheme.grey,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Category', pickup.category),
                    _buildDetailSection('Posted', _formatDate(pickup.createdAt)),
                    const SizedBox(height: 20),
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationCard(
                      name: pickup.donorName,
                      address: pickup.donorAddress,
                      color: AppTheme.success,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToDonorProfile(pickup.donorId, pickup.donorName);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Delivery Location',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationCard(
                      name: pickup.ngoName,
                      address: pickup.ngoAddress,
                      color: AppTheme.ngoColor,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToNGOProfile(pickup.ngoId, pickup.ngoName);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Action button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _acceptPickup(pickup);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accept This Pickup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.volunteerColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String name,
    required String address,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.open_in_new, color: color, size: 18),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _acceptPickup(PickupRequest pickup) {
    // TODO: Update Firestore to assign this volunteer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success),
            const SizedBox(width: 12),
            const Text('Pickup Accepted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have accepted to pickup:'),
            const SizedBox(height: 8),
            Text(
              pickup.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('From: ${pickup.donorName}'),
            Text('To: ${pickup.ngoName}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.volunteerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

// Model for pickup requests shown to volunteers
class PickupRequest {
  final String id;
  final String donorId;
  final String donorName;
  final String donorAddress;
  final String ngoId;
  final String ngoName;
  final String ngoAddress;
  final String itemName;
  final String quantity;
  final String category;
  final String urgency;
  final DateTime createdAt;
  final double distance;

  PickupRequest({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorAddress,
    required this.ngoId,
    required this.ngoName,
    required this.ngoAddress,
    required this.itemName,
    required this.quantity,
    required this.category,
    required this.urgency,
    required this.createdAt,
    required this.distance,
  });
}
