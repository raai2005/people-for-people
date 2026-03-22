import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/email_service.dart';
import '../../services/notification_service.dart';
import '../../screens/auth/role_selection_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final _tabs = const ['Overview', 'Pending', 'All Users'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Admin Panel', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.white),
            onPressed: _onLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.primaryDark,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppTheme.accent : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppTheme.white : AppTheme.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildPendingNGOs();
      case 2:
        return const AdminUsersScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── OVERVIEW ──────────────────────────────────────────────────────────────

  Widget _buildOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snap.data!.docs;
        final ngos = docs.where((d) => d['role'] == 'ngo').length;
        final donors = docs.where((d) => d['role'] == 'donor').length;
        final volunteers = docs.where((d) => d['role'] == 'volunteer').length;
        final pendingNGOs = docs.where((d) => d['role'] == 'ngo' && (d['isApproved'] == false || d['isApproved'] == null)).length;
        final pendingVolunteers = docs.where((d) => d['role'] == 'volunteer' && (d['isApproved'] == false || d['isApproved'] == null)).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Platform Overview', style: AppTheme.headingMedium),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _statCard('Total Users', '${docs.length}', Icons.people_rounded, AppTheme.info),
                  _statCard('NGOs', '$ngos', Icons.business_rounded, AppTheme.ngoColor),
                  _statCard('Donors', '$donors', Icons.volunteer_activism_rounded, AppTheme.donorColor),
                  _statCard('Volunteers', '$volunteers', Icons.handshake_rounded, AppTheme.volunteerColor),
                ],
              ),
              const SizedBox(height: 16),
              if (pendingNGOs > 0)
                _alertCard(
                  '$pendingNGOs NGO${pendingNGOs > 1 ? 's' : ''} pending approval',
                  Icons.pending_actions_rounded,
                  AppTheme.warning,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              if (pendingVolunteers > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _alertCard(
                    '$pendingVolunteers Volunteer${pendingVolunteers > 1 ? 's' : ''} pending approval',
                    Icons.person_search_rounded,
                    AppTheme.volunteerColor,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDonationStats(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDonationStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('donations').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final docs = snap.data!.docs;
        double total = 0;
        for (final d in docs) {
          total += (d['amount'] ?? 0).toDouble();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Donations', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('Total Donations', '${docs.length}', Icons.receipt_long_rounded, AppTheme.success)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Total Amount', '₹${total.toStringAsFixed(0)}', Icons.currency_rupee_rounded, AppTheme.gold)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
              Text(label, style: AppTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertCard(String message, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
            if (onTap != null) Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // ── PENDING (NGOs + Volunteers) ──────────────────────────────────────────

  Widget _buildPendingNGOs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppTheme.white,
            child: TabBar(
              labelColor: AppTheme.primaryDark,
              unselectedLabelColor: AppTheme.grey,
              indicatorColor: AppTheme.accent,
              tabs: const [
                Tab(text: 'NGOs'),
                Tab(text: 'Volunteers'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPendingList('ngo'),
                _buildPendingList('volunteer'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .where('isApproved', isEqualTo: false)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 64, color: AppTheme.success),
                const SizedBox(height: 12),
                const Text('No pending approvals', style: AppTheme.headingSmall),
                const SizedBox(height: 4),
                Text('All ${role == 'ngo' ? 'NGOs' : 'Volunteers'} have been reviewed',
                    style: const TextStyle(color: AppTheme.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => role == 'ngo'
              ? _buildNGOCard(docs[i])
              : _buildVolunteerCard(docs[i]),
        );
      },
    );
  }

  Widget _buildVolunteerCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? '';
    final location = data['location'] ?? '';
    final qualification = data['qualification'] ?? '';
    final isWorkingInNGO = data['isWorkingInNGO'] ?? false;
    final ngoName = data['ngoName'] ?? '';

    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.volunteerColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.volunteerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handshake_rounded, color: AppTheme.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark)),
                      Text(email, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Pending', style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location.isNotEmpty) _infoRow(Icons.location_on_outlined, 'Location', location),
                if (qualification.isNotEmpty) _infoRow(Icons.school_outlined, 'Qualification', qualification),
                if (isWorkingInNGO && ngoName.isNotEmpty)
                  _infoRow(Icons.business_outlined, 'Works at NGO', ngoName),
                if (!isWorkingInNGO)
                  _infoRow(Icons.person_outline, 'Type', 'Independent Volunteer'),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectNGO(doc.id, name),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveNGO(doc.id, name),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNGOCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final orgName = data['organizationName'] ?? data['name'] ?? 'Unknown NGO';
    final email = data['organizationEmail'] ?? data['email'] ?? '';
    final category = data['category'] ?? 'N/A';
    final location = data['location'] ?? '';
    final description = data['description'] ?? '';
    final headName = data['headOfOrgName'] ?? '';
    final govtDoc = data['govtVerifiedDocUrl'] ?? '';
    final headIdUrl = data['headOfOrgIdUrl'] ?? '';

    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.ngoColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.ngoColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_rounded, color: AppTheme.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orgName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark)),
                      Text(email, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Pending', style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.category_outlined, 'Category', category[0].toUpperCase() + category.substring(1)),
                if (location.isNotEmpty) _infoRow(Icons.location_on_outlined, 'Location', location),
                if (headName.isNotEmpty) _infoRow(Icons.person_outline, 'Head of Org', headName),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Description', style: AppTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(description, style: AppTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (govtDoc.isNotEmpty || headIdUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Documents', style: AppTheme.labelMedium),
                  const SizedBox(height: 8),
                  if (govtDoc.isNotEmpty)
                    _buildDocumentRow('Govt Document', govtDoc, doc.id, 'govtVerifiedDoc', data),
                  if (headIdUrl.isNotEmpty)
                    _buildDocumentRow('Head of Org ID', headIdUrl, doc.id, 'headOfOrgId', data),
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDetailsDialog(data),
                        icon: const Icon(Icons.info_outline_rounded, size: 18),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.info,
                          side: const BorderSide(color: AppTheme.info),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendDocumentNotification(doc.id, orgName, data),
                        icon: const Icon(Icons.notifications_active, size: 18),
                        label: const Text('Notify'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectNGO(doc.id, orgName),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveNGO(doc.id, orgName),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: AppTheme.labelMedium),
          Expanded(child: Text(value, style: AppTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String label, String url, String userId, String docField, Map<String, dynamic> userData) {
    final verificationField = '${docField}Verified';
    final isVerified = userData[verificationField];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDocumentDialog(label, url),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: AppTheme.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.open_in_new, size: 14, color: AppTheme.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _markDocumentStatus(userId, verificationField, false, userData),
                  icon: Icon(
                    isVerified == false ? Icons.check_circle : Icons.cancel,
                    size: 16,
                  ),
                  label: const Text('Rejected', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isVerified == false ? AppTheme.error : AppTheme.grey,
                    side: BorderSide(
                      color: isVerified == false ? AppTheme.error : AppTheme.grey.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: isVerified == false ? AppTheme.error.withValues(alpha: 0.1) : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _markDocumentStatus(userId, verificationField, true, userData),
                  icon: Icon(
                    isVerified == true ? Icons.check_circle : Icons.verified,
                    size: 16,
                  ),
                  label: const Text('Verified', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified == true ? AppTheme.success : AppTheme.grey.withValues(alpha: 0.2),
                    foregroundColor: isVerified == true ? AppTheme.white : AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _markDocumentStatus(String userId, String field, bool isVerified, Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      field: isVerified,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document marked as ${isVerified ? "verified" : "rejected"}'),
          backgroundColor: isVerified ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetailsDialog(Map<String, dynamic> data) {
    final fields = [
      ['Organisation Name', data['organizationName']],
      ['Organisation Email', data['organizationEmail']],
      ['Organisation Phone', data['organizationPhone']],
      ['Address', data['address']],
      ['Location', data['location']],
      ['Category', data['category']],
      ['Description', data['description']],
      ['Head of Org Name', data['headOfOrgName']],
      ['Head of Org Email', data['headOfOrgEmail']],
      ['Head of Org Phone', data['headOfOrgPhone']],
      ['Registered Email', data['email']],
      ['Registered On', data['createdAt']?.toString()],
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.business_rounded, color: AppTheme.ngoColor, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(data['organizationName'] ?? 'NGO Details', style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...fields.where((f) => f[1] != null && f[1].toString().isNotEmpty).map((f) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f[0].toString(), style: AppTheme.labelMedium),
                        const SizedBox(height: 2),
                        Text(f[1].toString(), style: AppTheme.bodyMedium),
                        const Divider(height: 16),
                      ],
                    ),
                  ),
                ),
                if ((data['govtVerifiedDocUrl'] ?? '').isNotEmpty) ...[
                  Text('Govt Document', style: AppTheme.labelMedium),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['govtVerifiedDocUrl'],
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (_, __, ___) => const Text('Could not load image', style: TextStyle(color: AppTheme.grey)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if ((data['headOfOrgIdUrl'] ?? '').isNotEmpty) ...[
                  Text('Head of Org ID', style: AppTheme.labelMedium),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['headOfOrgIdUrl'],
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (_, __, ___) => const Text('Could not load image', style: TextStyle(color: AppTheme.grey)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showDocumentDialog(String label, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_outlined, size: 48, color: AppTheme.grey),
                const SizedBox(height: 8),
                SelectableText(url, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _approveNGO(String docId, String orgName) async {
    final confirm = await _showConfirmDialog(
      'Approve Account',
      'Approve "$orgName"? They will be notified via email.',
      AppTheme.success,
      'Approve',
    );
    if (!confirm) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
    final userData = userDoc.data();
    final email = userData?['email'] ?? userData?['organizationEmail'] ?? '';
    final role = userData?['role'] ?? 'user';

    await FirebaseFirestore.instance.collection('users').doc(docId).update({
      'isApproved': true,
      'isVerified': true,
      'approvedAt': FieldValue.serverTimestamp(),
    });

    await EmailService.sendApprovalEmail(
      toEmail: email,
      userName: orgName,
      role: role,
    );

    await NotificationService.instance.sendNotification(
      userId: docId,
      title: 'Account Approved! 🎉',
      message: 'Your account has been approved. You can now access all features.',
      type: 'approval',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$orgName approved successfully'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectNGO(String docId, String orgName) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provide a reason for rejecting "$orgName":'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Invalid documents, incomplete information...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
    final userData = userDoc.data();
    final email = userData?['email'] ?? userData?['organizationEmail'] ?? '';
    final role = userData?['role'] ?? 'user';

    await EmailService.sendRejectionEmail(
      toEmail: email,
      userName: orgName,
      role: role,
      reason: reason,
    );

    await NotificationService.instance.sendNotification(
      userId: docId,
      title: 'Account Application Update',
      message: 'Your application was not approved. Reason: $reason',
      type: 'rejection',
    );

    await FirebaseFirestore.instance.collection('users').doc(docId).delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$orgName rejected and removed'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _showConfirmDialog(String title, String message, Color color, String confirmLabel) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: AppTheme.white),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _sendDocumentNotification(String userId, String userName, Map<String, dynamic> userData) async {
    final govtDocVerified = userData['govtVerifiedDocVerified'];
    final headIdVerified = userData['headOfOrgIdVerified'];

    final documentStatus = <String, bool>{};
    if (govtDocVerified != null) {
      documentStatus['Government Document'] = govtDocVerified;
    }
    if (headIdVerified != null) {
      documentStatus['Head of Organization ID'] = headIdVerified;
    }

    if (documentStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify documents first'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    final hasRejected = documentStatus.values.any((v) => v == false);
    final email = userData['email'] ?? userData['organizationEmail'] ?? '';

    await EmailService.sendDocumentVerificationEmail(
      toEmail: email,
      userName: userName,
      documentStatus: documentStatus,
    );

    String notifMessage = '';
    if (hasRejected) {
      final rejectedDocs = documentStatus.entries.where((e) => e.value == false).map((e) => e.key).join(', ');
      notifMessage = 'Some documents were rejected: $rejectedDocs. Please re-upload correct documents.';
    } else {
      notifMessage = 'All your documents have been verified successfully!';
    }

    await NotificationService.instance.sendNotification(
      userId: userId,
      title: 'Document Verification Update',
      message: notifMessage,
      type: 'document_verification',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification sent to $userName'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onLogout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }
}
