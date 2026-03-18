import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class PublicNGOProfileScreen extends StatefulWidget {
  final String ngoId;
  final String? ngoName; // Optional - if provided, shows while loading

  const PublicNGOProfileScreen({super.key, required this.ngoId, this.ngoName});

  @override
  State<PublicNGOProfileScreen> createState() => _PublicNGOProfileScreenState();
}

class _PublicNGOProfileScreenState extends State<PublicNGOProfileScreen> {
  Map<String, dynamic>? _ngoData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNGOProfile();
  }

  Future<void> _loadNGOProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ngoId)
          .get();

      if (doc.exists) {
        setState(() {
          _ngoData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'NGO not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
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
        _buildAppBar(widget.ngoName ?? 'Loading...'),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.ngoColor),
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
                    backgroundColor: AppTheme.ngoColor,
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
      backgroundColor: AppTheme.ngoColor,
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
                AppTheme.ngoColor,
                AppTheme.ngoColor.withValues(alpha: 0.8),
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
                    Icons.business,
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
    final name = _ngoData?['organizationName'] ?? 'Unknown NGO';
    final email = _ngoData?['email'] ?? '';
    final phone = _ngoData?['phone'] ?? '';
    final location = _ngoData?['location'] ?? _ngoData?['address'] ?? '';
    final description = _ngoData?['description'] ?? _ngoData?['about'] ?? '';
    final registrationNumber = _ngoData?['registrationNumber'] ?? '';
    final website = _ngoData?['website'] ?? '';
    final focusAreas = _ngoData?['focusAreas'] ?? [];
    final isVerified = _ngoData?['isVerified'] ?? false;

    return CustomScrollView(
      slivers: [
        _buildAppBar(name),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verification Badge
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.success),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 18, color: AppTheme.success),
                        SizedBox(width: 6),
                        Text(
                          'Verified NGO',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // About Section
                if (description.isNotEmpty) ...[
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
                      description,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Focus Areas
                if (focusAreas.isNotEmpty) ...[
                  _buildSectionTitle('Focus Areas'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (focusAreas as List).map<Widget>((area) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.ngoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          area.toString(),
                          style: const TextStyle(
                            color: AppTheme.ngoColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Contact Information
                _buildSectionTitle('Contact Information'),
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
                      if (email.isNotEmpty)
                        _buildContactRow(Icons.email_outlined, 'Email', email),
                      if (phone.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildContactRow(Icons.phone_outlined, 'Phone', phone),
                      ],
                      if (location.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildContactRow(
                          Icons.location_on_outlined,
                          'Location',
                          location,
                        ),
                      ],
                      if (website.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildContactRow(Icons.language, 'Website', website),
                      ],
                      if (registrationNumber.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildContactRow(
                          Icons.badge_outlined,
                          'Registration',
                          registrationNumber,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // View Active Requests Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showActiveRequests(),
                    icon: const Icon(
                      Icons.volunteer_activism,
                      color: AppTheme.ngoColor,
                    ),
                    label: const Text(
                      'View Active Donation Requests',
                      style: TextStyle(color: AppTheme.ngoColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.ngoColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
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

  void _showActiveRequests() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism, color: AppTheme.ngoColor),
                  const SizedBox(width: 12),
                  const Text(
                    'Active Donation Requests',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('donation_requests')
                    .where('ngoId', isEqualTo: widget.ngoId)
                    .where('status', isEqualTo: 'active')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.ngoColor));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: AppTheme.grey.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No active requests', style: TextStyle(color: AppTheme.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final category = data['category'] ?? 'other';
                      final targetAmount = data['targetAmount'];
                      final targetQuantity = data['targetQuantity'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Untitled',
                              style: const TextStyle(
                                color: AppTheme.primaryDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['description'] ?? '',
                              style: TextStyle(color: AppTheme.grey, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.ngoColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    category.toString().toUpperCase(),
                                    style: const TextStyle(color: AppTheme.ngoColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                if (targetAmount != null)
                                  Text('Goal: ₹$targetAmount', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13))
                                else if (targetQuantity != null)
                                  Text('Need: $targetQuantity items', style: const TextStyle(color: AppTheme.info, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.ngoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.ngoColor),
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
}
