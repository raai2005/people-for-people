import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'ngo_profile_screen.dart';
import '../../services/notification_service.dart';
import 'ngo_transactions_screen.dart';
import '../common/notifications_screen.dart';

class NGODashboard extends StatefulWidget {
  const NGODashboard({super.key});

  @override
  State<NGODashboard> createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.white,
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              if (_currentIndex != 4) _buildAppBar(),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ... existing app bar methods ...

  // Keep _buildAppBar, _buildNotificationBell, _buildContent, _buildDashboardHome etc. as is.
  // I will only include the changed methods to avoid context size explosion if I were using replace_file_content on the whole file,
  // but since I am replacing the whole file content to be safe with the structure changes (adding FAB property to Scaffold), I need to be careful.
  // Actually, I should probably use `multi_replace_file_content` or targeted `replace_file_content` if possible.
  // The Scaffold is in `build`. The `_buildBottomNav` is at the end.
  // Let's rewrite `build` and `_buildBottomNav` and remove `_navItems`.

  // Wait, I can't easily remove `_navItems` field with `replace_file_content` unless I target it specifically.
  // Let's stick to replacing `build` and `_buildBottomNav` and just ignore `_navItems` or remove it in a separate block if strictly necessary,
  // but for a clean code I should remove it.

  // Let's try to do it in one go if I can match the blocks.
  // Or I can just overwrite the file from line 14 down to the end of the class. That's a lot of lines.
  // Let's try targeted replacements.

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
              color: AppTheme.ngoColor.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: AppTheme.ngoColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NGO Dashboard',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Welcome back, Organisation',
                  style: TextStyle(color: AppTheme.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          // Notification Bell
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryDark,
                    size: 24,
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable:
                    NotificationService.instance.hasUnreadNotifications,
                builder: (context, hasUnread, child) {
                  return hasUnread
                      ? Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
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
        return _buildPlaceholder(
          'NGO to NGO Donate',
          Icons.volunteer_activism_rounded,
        );
      case 2:
        return _buildPlaceholder(
          'Create Donation Request',
          Icons.add_circle_rounded,
        );
      case 3:
        return const NGOTransactionsScreen();
      case 4:
        return const NGOProfileScreen();
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
          // Stats Cards
          _buildStatsSection(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Recent Donations
          _buildRecentDonations(),
          const SizedBox(height: 24),

          // Active Campaigns
          _buildActiveCampaigns(),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Donations',
                '₹1,25,000',
                Icons.attach_money,
                AppTheme.success,
                '+12%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Volunteers',
                '45',
                Icons.people_alt_rounded,
                AppTheme.volunteerColor,
                '+5',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Campaigns',
                '8',
                Icons.campaign_rounded,
                AppTheme.gold,
                '3 Active',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Beneficiaries',
                '230',
                Icons.favorite,
                AppTheme.accent,
                '+28',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: AppTheme.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Create Campaign',
                Icons.add_circle_outline,
                AppTheme.ngoColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Request Volunteers',
                Icons.person_add_alt_1_outlined,
                AppTheme.volunteerColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Post Update',
                Icons.edit_note,
                AppTheme.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDonations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Donations',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(color: AppTheme.ngoColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDonationItem('John Doe', '₹5,000', 'Money', '2 hours ago'),
        _buildDonationItem('Sarah Smith', '50 Items', 'Clothes', '5 hours ago'),
        _buildDonationItem('Anonymous', '₹10,000', 'Money', 'Yesterday'),
      ],
    );
  }

  Widget _buildDonationItem(
    String donor,
    String amount,
    String type,
    String time,
  ) {
    IconData icon;
    Color color;

    switch (type) {
      case 'Money':
        icon = Icons.attach_money;
        color = AppTheme.success;
        break;
      case 'Clothes':
        icon = Icons.checkroom;
        color = AppTheme.volunteerColor;
        break;
      case 'Food':
        icon = Icons.restaurant;
        color = AppTheme.gold;
        break;
      default:
        icon = Icons.inventory_2;
        color = AppTheme.info;
    }

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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor,
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(type, style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCampaigns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Campaigns',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(color: AppTheme.ngoColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCampaignCard(
          'Winter Clothes Drive',
          'Help provide warm clothes for the homeless',
          0.65,
          '₹32,500 / ₹50,000',
        ),
        _buildCampaignCard(
          'Food for All',
          'Daily meals for underprivileged children',
          0.80,
          '₹40,000 / ₹50,000',
        ),
      ],
    );
  }

  Widget _buildCampaignCard(
    String title,
    String description,
    double progress,
    String amount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: AppTheme.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.ngoColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.ngoColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
              color: AppTheme.ngoColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.ngoColor, size: 48),
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
            children: [
              Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _buildNavItem(1, Icons.volunteer_activism_rounded, 'Donate')),
              Expanded(child: _buildNavItem(2, Icons.add_circle_rounded, '')),
              Expanded(child: _buildNavItem(3, Icons.receipt_long_rounded, 'Activity')),
              Expanded(child: _buildNavItem(4, Icons.person_rounded, 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
              size: label.isEmpty ? 28 : 24,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.ngoColor : AppTheme.grey,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
