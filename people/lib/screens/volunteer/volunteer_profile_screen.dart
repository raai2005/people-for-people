import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/user_models.dart';
import '../auth/role_selection_screen.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  VolunteerUser? _user;
  bool _isLoading = true;
  int _completedTasks = 0;
  int _totalHours = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();

      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('volunteerId', isEqualTo: uid)
          .get();

      int completed = 0;
      int hours = 0;

      for (var doc in transactionsSnapshot.docs) {
        final status = doc.data()['status'];
        if (status == 'completed') {
          completed++;
          hours += 2;
        }
      }

      if (mounted && userData != null) {
        setState(() {
          _user = VolunteerUser.fromFirestore(userDoc);
          _completedTasks = completed;
          _totalHours = hours;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.volunteerColor)),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(),
                const SizedBox(height: 30),
                _buildStatsCard(),
                const SizedBox(height: 20),
                _buildInfoSection(),
                const SizedBox(height: 40),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppTheme.volunteerColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.volunteerColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppTheme.volunteerColor,
            size: 60,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _user?.name ?? 'Volunteer',
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _user?.email ?? '',
          style: TextStyle(color: AppTheme.grey, fontSize: 14),
        ),
        if (_user?.isAdminApproved == true) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success),
            ),
            child: const Text(
              'Verified Volunteer',
              style: TextStyle(
                color: AppTheme.success,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('$_completedTasks', 'Tasks', Icons.task_alt),
          _buildStat('${_totalHours}h', 'Time', Icons.schedule),
          _buildStat(_completedTasks > 0 ? '4.8' : '0.0', 'Rating', Icons.star),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.volunteerColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard('Phone', _user?.phone ?? 'Not provided', Icons.phone),
        if (_user?.qualification != null && _user!.qualification!.isNotEmpty)
          _buildInfoCard('Qualification', _user!.qualification!, Icons.school),
        if (_user?.isWorkingInNGO == true) ...[
          _buildInfoCard('NGO', _user?.ngoName ?? 'N/A', Icons.business),
          if (_user?.employeeId != null && _user!.employeeId!.isNotEmpty)
            _buildInfoCard('Employee ID', _user!.employeeId!, Icons.badge),
        ],
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.volunteerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.volunteerColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppTheme.error),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: AppTheme.white)),
                ],
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
