import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../auth/role_selection_screen.dart';
import 'volunteer_pickup_screen.dart';
import 'volunteer_profile_screen.dart';
import '../../models/transaction_model.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _currentIndex = 0;
  bool _isApproved = false;
  int _completedTasks = 0;
  int _totalDeliveries = 0;
  int _totalHours = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
  }

  Future<void> _loadVolunteerData() async {
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
      int deliveries = 0;
      int hours = 0;

      for (var doc in transactionsSnapshot.docs) {
        final transaction = Transaction.fromFirestore(doc);
        if (transaction.status == TransactionStatus.completed) {
          completed++;
          deliveries++;
          hours += 2; // Estimate 2 hours per delivery
        } else if (transaction.status == TransactionStatus.volunteerAssigned) {
          deliveries++;
        }
      }

      if (mounted) {
        setState(() {
          _isApproved = userData?['isApproved'] ?? false;
          _completedTasks = completed;
          _totalDeliveries = deliveries;
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
          child: Column(
            children: [
              if (_currentIndex != 4) _buildAppBar(),
              if (!_isApproved && _currentIndex == 0)
                _buildPendingApprovalBanner(),
              Expanded(child: _buildContentBasedOnApproval()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContentBasedOnApproval() {
    if (_currentIndex == 4) {
      return const VolunteerProfileScreen();
    }

    if (_currentIndex == 0 && !_isApproved) {
      return _buildPendingContent();
    }

    if (_isApproved) {
      return _buildContent();
    }

    return _buildPendingContent();
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.volunteerColor.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: AppTheme.volunteerColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isApproved ? 'Volunteer Dashboard' : 'Pending Approval',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 18,
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

  Widget _buildPendingApprovalBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_empty, color: AppTheme.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Approval Pending',
                  style: TextStyle(
                    color: AppTheme.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin will review your application',
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_clock, color: AppTheme.warning, size: 60),
            ),
            const SizedBox(height: 30),
            const Text(
              'Account Pending Approval',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your volunteer account is under review. You will be notified once admin approves your application.',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatusItem('Application Submitted', true),
                  _buildStatusItem('Documents Verified', true),
                  _buildStatusItem('Admin Approval', false),
                  _buildStatusItem('Account Active', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? AppTheme.success
                  : AppTheme.white.withValues(alpha: 0.1),
              border: Border.all(
                color: completed
                    ? AppTheme.success
                    : AppTheme.white.withValues(alpha: 0.3),
              ),
            ),
            child: completed
                ? const Icon(Icons.check, color: AppTheme.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: completed ? AppTheme.primaryDark : AppTheme.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return _buildPlaceholder('Available Tasks', Icons.task_alt);
      case 2:
        return const VolunteerPickupScreen();
      case 3:
        return _buildPlaceholder('My Tasks', Icons.checklist);
      case 4:
        return const VolunteerProfileScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildAvailableTasks(),
          const SizedBox(height: 24),
          _buildRecentDeliveries(),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.volunteerColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.volunteerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Contribution',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('$_completedTasks', 'Tasks Done', Icons.task_alt),
              _buildStat('$_totalDeliveries', 'Deliveries', Icons.local_shipping),
              _buildStat('$_totalHours', 'Hours', Icons.schedule),
            ],
          ),
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

  Widget _buildAvailableTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Tasks',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          'Pickup Clothes',
          'From: John Doe, Andheri West',
          Icons.checkroom,
          AppTheme.volunteerColor,
          'Urgent',
        ),
        _buildTaskCard(
          'Deliver Food',
          'To: Hope NGO, Bandra',
          Icons.restaurant,
          AppTheme.gold,
          'Today',
        ),
        _buildTaskCard(
          'Collect Donations',
          'From: ABC Corp, BKC',
          Icons.inventory_2,
          AppTheme.ngoColor,
          'Tomorrow',
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    String title,
    String location,
    IconData icon,
    Color color,
    String urgency,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.white.withValues(alpha: 0.5),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: AppTheme.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              urgency,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Deliveries',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDeliveryItem(
          'Clothes Delivery',
          'Completed',
          Icons.check_circle,
          AppTheme.success,
        ),
        _buildDeliveryItem(
          'Food Delivery',
          'In Progress',
          Icons.timelapse,
          AppTheme.warning,
        ),
      ],
    );
  }

  Widget _buildDeliveryItem(
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            status,
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

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.volunteerColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.volunteerColor, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(color: AppTheme.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Home'},
      {'icon': Icons.task_alt, 'label': 'Tasks'},
      {'icon': Icons.local_shipping, 'label': 'Pickup'},
      {'icon': Icons.checklist, 'label': 'My Tasks'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          top: BorderSide(color: AppTheme.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _currentIndex == index;
              final isDisabled = !_isApproved && index != 0 && index != 4;
              return InkWell(
                onTap: isDisabled
                    ? null
                    : () => setState(() => _currentIndex = index),
                child: Opacity(
                  opacity: isDisabled ? 0.3 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.volunteerColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[index]['icon'] as IconData,
                          color: isSelected
                              ? AppTheme.volunteerColor
                              : AppTheme.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index]['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.volunteerColor
                                : AppTheme.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
