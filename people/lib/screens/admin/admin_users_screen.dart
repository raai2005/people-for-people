import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedRole = 'all';

  final _roles = ['all', 'ngo', 'donor', 'volunteer'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRoleFilter(),
        Expanded(child: _buildUserList()),
      ],
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _roles.map((role) {
            final selected = role == _selectedRole;
            final color = _roleColor(role);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = role),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? color : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role[0].toUpperCase() + role.substring(1),
                    style: TextStyle(
                      color: selected ? AppTheme.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

  Widget _buildUserList() {
    Query query = FirebaseFirestore.instance.collection('users');
    if (_selectedRole != 'all') {
      query = query.where('role', isEqualTo: _selectedRole);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        // Filter out admin accounts from the list
        final docs = snap.data!.docs.where((d) => d['role'] != 'admin').toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 56, color: AppTheme.grey),
                const SizedBox(height: 12),
                Text('No ${_selectedRole == 'all' ? 'users' : _selectedRole + 's'} found', style: AppTheme.headingSmall),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _buildUserTile(docs[i]),
        );
      },
    );
  }

  Widget _buildUserTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = data['role'] ?? '';
    final name = data['organizationName'] ?? data['name'] ?? 'Unknown';
    final email = data['organizationEmail'] ?? data['email'] ?? '';
    final isApproved = data['isApproved'] ?? false;
    final color = _roleColor(role);

    return Container(
      decoration: AppTheme.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_roleIcon(role), color: color, size: 22),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                _roleBadge(role, color),
                const SizedBox(width: 6),
                if (role == 'ngo')
                  _statusBadge(isApproved),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.grey),
          onSelected: (action) => _handleUserAction(action, doc.id, name, role, isApproved),
          itemBuilder: (_) => [
            if (role == 'ngo' && !isApproved)
              const PopupMenuItem(value: 'approve', child: Row(children: [Icon(Icons.check, color: AppTheme.success, size: 18), SizedBox(width: 8), Text('Approve')])),
            if (role == 'ngo' && isApproved)
              const PopupMenuItem(value: 'revoke', child: Row(children: [Icon(Icons.block, color: AppTheme.warning, size: 18), SizedBox(width: 8), Text('Revoke Approval')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: AppTheme.error, size: 18), SizedBox(width: 8), Text('Delete User')])),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _statusBadge(bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isApproved ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isApproved ? 'Approved' : 'Pending',
        style: TextStyle(
          color: isApproved ? AppTheme.success : AppTheme.warning,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleUserAction(String action, String docId, String name, String role, bool isApproved) async {
    switch (action) {
      case 'approve':
        await FirebaseFirestore.instance.collection('users').doc(docId).update({
          'isApproved': true,
          'isVerified': true,
          'approvedAt': FieldValue.serverTimestamp(),
        });
        _showSnack('$name approved', AppTheme.success);
        break;
      case 'revoke':
        await FirebaseFirestore.instance.collection('users').doc(docId).update({'isApproved': false});
        _showSnack('Approval revoked for $name', AppTheme.warning);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete User'),
            content: Text('Delete "$name"? This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: AppTheme.white),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await FirebaseFirestore.instance.collection('users').doc(docId).delete();
          _showSnack('$name deleted', AppTheme.error);
        }
        break;
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ngo': return AppTheme.ngoColor;
      case 'donor': return AppTheme.donorColor;
      case 'volunteer': return AppTheme.volunteerColor;
      default: return AppTheme.primaryDark;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'ngo': return Icons.business_rounded;
      case 'donor': return Icons.volunteer_activism_rounded;
      case 'volunteer': return Icons.handshake_rounded;
      default: return Icons.person_rounded;
    }
  }
}
