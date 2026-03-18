import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../common/public_ngo_profile_screen.dart';

class DonorDiscoverScreen extends StatefulWidget {
  const DonorDiscoverScreen({super.key});

  @override
  State<DonorDiscoverScreen> createState() => _DonorDiscoverScreenState();
}

class _DonorDiscoverScreenState extends State<DonorDiscoverScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getNGOsStream() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'ngo')
        .where('isApproved', isEqualTo: true);

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory.toLowerCase());
    }

    return query.snapshots();
  }

  List<QueryDocumentSnapshot> _filterBySearch(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;
    
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['organizationName'] ?? '').toString().toLowerCase();
      final description = (data['description'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(child: _buildNGOGrid()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.donorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.explore_rounded,
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
                  'Discover NGOs',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Find causes you care about',
                  style: TextStyle(color: AppTheme.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppTheme.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: AppTheme.primaryDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search NGOs...',
                hintStyle: TextStyle(color: AppTheme.grey.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(Icons.clear, color: AppTheme.grey, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Education',
      'Health',
      'Environment',
      'Animals',
      'Poverty',
      'Disaster',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.donorColor
                        : AppTheme.donorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.donorColor
                          : AppTheme.donorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.donorColor,
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

  Widget _buildNGOGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getNGOsStream(),
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
                  'Error loading NGOs',
                  style: TextStyle(color: AppTheme.grey),
                ),
              ],
            ),
          );
        }

        final allDocs = snapshot.data?.docs ?? [];
        final filteredDocs = _filterBySearch(allDocs);

        if (filteredDocs.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            final ngoId = filteredDocs[index].id;
            return _buildNGOCard(ngoId, data);
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
              Icons.search_off_rounded,
              color: AppTheme.grey.withValues(alpha: 0.5),
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'No NGOs Found',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'No NGOs in this category yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNGOCard(String ngoId, Map<String, dynamic> data) {
    final name = data['organizationName'] ?? 'Unknown NGO';
    final description = data['description'] ?? 'No description available';
    final category = data['category'] ?? 'other';
    final verified = data['isVerified'] ?? false;

    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicNGOProfileScreen(
              ngoId: ngoId,
              ngoName: name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey),
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
            // Header with icon
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: categoryColor,
                    size: 32,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (verified)
                          const Icon(
                            Icons.verified,
                            color: AppTheme.success,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return AppTheme.info;
      case 'health':
        return AppTheme.accent;
      case 'environment':
        return AppTheme.success;
      case 'animals':
        return AppTheme.volunteerColor;
      case 'poverty':
        return AppTheme.warning;
      case 'disaster':
        return AppTheme.error;
      default:
        return AppTheme.donorColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.medical_services;
      case 'environment':
        return Icons.eco;
      case 'animals':
        return Icons.pets;
      case 'poverty':
        return Icons.volunteer_activism;
      case 'disaster':
        return Icons.warning_amber_rounded;
      default:
        return Icons.business;
    }
  }
}
