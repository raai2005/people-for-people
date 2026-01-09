import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class PublicDonorProfileScreen extends StatefulWidget {
  final String donorId;
  final String? donorName; // Optional - if provided, shows while loading

  const PublicDonorProfileScreen({
    super.key,
    required this.donorId,
    this.donorName,
  });

  @override
  State<PublicDonorProfileScreen> createState() =>
      _PublicDonorProfileScreenState();
}

class _PublicDonorProfileScreenState extends State<PublicDonorProfileScreen> {
  Map<String, dynamic>? _donorData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDonorProfile();
  }

  Future<void> _loadDonorProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('donors')
          .doc(widget.donorId)
          .get();

      if (doc.exists) {
        setState(() {
          _donorData = doc.data();
          _isLoading = false;
        });
      } else {
        // Use mock data for testing when donor not found in Firestore
        setState(() {
          _donorData = _getMockDonorData();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Use mock data for testing on error
      setState(() {
        _donorData = _getMockDonorData();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getMockDonorData() {
    return {
      'name': widget.donorName ?? 'Anonymous Donor',
      'email': 'donor@example.com',
      'phone': '+1 234 567 8900',
      'profileImageUrl': null,
      'isAnonymous': false,
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 180)),
      ),
      'totalDonations': 12,
      'totalItemsDonated': 156,
      'categoriesDonated': ['Food', 'Clothes', 'Education'],
      'bio':
          'Passionate about helping communities in need. Every small contribution makes a difference!',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildProfileContent(),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(widget.donorName ?? 'Loading...'),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.donorColor),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Error'),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.grey),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Something went wrong',
                  style: TextStyle(color: AppTheme.grey, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.donorColor,
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.donorColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.donorColor,
                AppTheme.donorColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final name =
        _donorData?['name'] ?? _donorData?['fullName'] ?? 'Anonymous Donor';
    final email = _donorData?['email'] ?? '';
    final location = _donorData?['location'] ?? _donorData?['city'] ?? '';
    final bio = _donorData?['bio'] ?? '';
    final isAnonymous = _donorData?['isAnonymous'] ?? false;
    final totalDonations = _donorData?['totalDonations'] ?? 0;
    final donationCount = _donorData?['donationCount'] ?? 0;

    return CustomScrollView(
      slivers: [
        _buildAppBar(isAnonymous ? 'Anonymous Donor' : name),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donor Stats Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.volunteer_activism,
                          donationCount.toString(),
                          'Donations',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppTheme.borderGrey,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.currency_rupee,
                          '₹${_formatAmount(totalDonations)}',
                          'Contributed',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Donor Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 18, color: AppTheme.gold),
                      const SizedBox(width: 6),
                      Text(
                        _getDonorBadge(totalDonations),
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bio Section
                if (bio.isNotEmpty && !isAnonymous) ...[
                  _buildSectionTitle('About'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Text(
                      bio,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Contact Information (only if not anonymous)
                if (!isAnonymous) ...[
                  _buildSectionTitle('Information'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Column(
                      children: [
                        if (location.isNotEmpty)
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            'Location',
                            location,
                          ),
                        if (email.isNotEmpty) ...[
                          const Divider(height: 20),
                          _buildInfoRow(Icons.email_outlined, 'Email', email),
                        ],
                      ],
                    ),
                  ),
                ],

                // Anonymous Notice
                if (isAnonymous) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, color: AppTheme.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This donor prefers to remain anonymous',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.primaryDark,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.donorColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.donorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.donorColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final num = amount is int ? amount.toDouble() : amount as double;
    if (num >= 100000) {
      return '${(num / 100000).toStringAsFixed(1)}L';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toStringAsFixed(0);
  }

  String _getDonorBadge(dynamic amount) {
    if (amount == null) return 'New Donor';
    final num = amount is int ? amount.toDouble() : amount as double;
    if (num >= 100000) return 'Platinum Donor';
    if (num >= 50000) return 'Gold Donor';
    if (num >= 10000) return 'Silver Donor';
    if (num >= 1000) return 'Bronze Donor';
    return 'Supporter';
  }
}
