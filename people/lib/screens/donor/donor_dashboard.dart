import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/user_models.dart';
import '../../services/auth_service.dart';
import '../../services/donation_service.dart';
import 'donor_profile_screen.dart';
import 'donor_donate_screen.dart';
import 'donor_discover_screen.dart';
import 'donor_history_screen.dart';
import '../../services/notification_service.dart';
import '../common/notifications_screen.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _currentIndex = 0;
  DonorUser? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user is DonorUser ? user : null;
        _isLoadingUser = false;
      });
    }
  }

  int _getProfileCompletion() {
    if (_currentUser == null) return 0;
    int steps = 0;
    if (_currentUser!.verification.email) steps++;
    if (_currentUser!.verification.phone) steps++;
    if (_currentUser!.verification.governmentId) steps++;
    if (_currentUser!.bio?.isNotEmpty == true) steps++;
    return ((steps / 4) * 100).toInt();
  }

  bool get _isEligible => _getProfileCompletion() >= 70;

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.donorColor)),
      );
    }
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.white, // Solid white background
        child: SafeArea(
          child: Column(
            children: [
              if (_currentIndex != 4)
                _buildAppBar(), // Hide app bar for Profile which has its own header
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
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
              color: AppTheme.donorColor.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: AppTheme.donorColor,
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
                const Text(
                  'Donor Dashboard',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationBell(),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryDark,
              size: 24,
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: NotificationService.instance.hasUnreadNotifications,
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
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return const DonorDiscoverScreen();
      case 2:
        return _isEligible
            ? const DonorDonateScreen()
            : _buildEligibilityGate();
      case 3:
        return _isEligible
            ? const DonorHistoryScreen()
            : _buildEligibilityGate();
      case 4:
        return DonorProfileScreen(
          onViewAllDonations: () => setState(() => _currentIndex = 3),
        );
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildEligibilityGate() {
    final completion = _getProfileCompletion();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, color: AppTheme.warning, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You need at least 70% profile completion to access this feature. Your current completion is $completion%.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete: Email verification, Phone verification, Bio, and wait for Govt ID admin approval.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey.withValues(alpha: 0.7), fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentIndex = 4),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.donorColor,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Go to Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DonationService().getUserDonationsStream(),
      builder: (context, snapshot) {
        final donations = snapshot.data ?? [];

        // Compute stats from stream data
        double totalAmount = 0;
        int totalDonations = donations.length;
        for (final d in donations) {
          final raw = d['amount'] as String?;
          if (raw != null) {
            final numeric = double.tryParse(
              raw.replaceAll('₹', '').replaceAll(',', ''),
            );
            if (numeric != null) totalAmount += numeric;
          }
        }

        final recentDonations = donations.take(3).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImpactCard(totalAmount, totalDonations),
              const SizedBox(height: 24),
              _buildDonationOptions(),
              const SizedBox(height: 24),
              _buildRecentActivity(recentDonations),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImpactCard(double totalAmount, int totalDonations) {
    final formatter = NumberFormat('#,##,###');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.donorColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.donorColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Impact',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactStat('₹${formatter.format(totalAmount)}', 'Donated', Icons.attach_money),
              _buildImpactStat('$totalDonations', 'Donations', Icons.card_giftcard),
              _buildImpactStat(
                _currentUser?.name.split(' ').first ?? '—',
                'Donor',
                Icons.volunteer_activism,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.white.withValues(alpha: 0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDonationOptions() {
    final categories = [
      {'title': 'Money', 'icon': Icons.attach_money, 'color': AppTheme.success},
      {'title': 'Clothes', 'icon': Icons.checkroom, 'color': AppTheme.volunteerColor},
      {'title': 'Food', 'icon': Icons.restaurant, 'color': AppTheme.gold},
      {'title': 'Other', 'icon': Icons.inventory_2, 'color': AppTheme.info},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ways to Help',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: categories.map((c) {
            final color = c['color'] as Color;
            return InkWell(
              onTap: () => setState(() => _currentIndex = 2),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(c['icon'] as IconData, color: color, size: 32),
                    const SizedBox(height: 10),
                    Text(
                      c['title'] as String,
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<Map<String, dynamic>> donations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (donations.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _currentIndex = 3),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.donorColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (donations.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history, color: AppTheme.grey.withValues(alpha: 0.3), size: 48),
                  const SizedBox(height: 12),
                  Text('No donations yet', style: TextStyle(color: AppTheme.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'Your donations will appear here',
                    style: TextStyle(color: AppTheme.grey.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...donations.map((d) => _buildActivityItem(d)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> donation) {
    final type = (donation['type'] as String? ?? 'other').toLowerCase();
    final status = donation['status'] as String? ?? 'Pending';

    final typeColor = switch (type) {
      'money' => AppTheme.success,
      'clothes' => AppTheme.volunteerColor,
      'food' => AppTheme.gold,
      'medical' => AppTheme.accent,
      _ => AppTheme.info,
    };
    final typeIcon = switch (type) {
      'money' => Icons.attach_money,
      'clothes' => Icons.checkroom,
      'food' => Icons.restaurant,
      'medical' => Icons.medical_services,
      _ => Icons.inventory_2,
    };
    final statusColor = switch (status.toLowerCase()) {
      'completed' => AppTheme.success,
      'pending' => AppTheme.warning,
      'cancelled' => AppTheme.error,
      _ => AppTheme.info,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation['title'] as String? ?? 'Donation',
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  donation['ngo'] as String? ?? '',
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (donation['amount'] != null)
                Text(
                  donation['amount'] as String,
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.explore_rounded, 'label': 'Discover'},
      {'icon': Icons.volunteer_activism_rounded, 'label': 'Donate'},
      {'icon': Icons.history_rounded, 'label': 'History'},
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
              final isLocked = (index == 2 || index == 3) && !_isEligible;
              return InkWell(
                onTap: () {
                  final previous = _currentIndex;
                  setState(() => _currentIndex = index);
                  // Reload user only when leaving profile tab
                  if (previous == 4 && index != 4) _loadUser();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.donorColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            items[index]['icon'] as IconData,
                            color: isLocked
                                ? AppTheme.grey.withValues(alpha: 0.4)
                                : isSelected
                                    ? AppTheme.donorColor
                                    : AppTheme.grey,
                            size: 24,
                          ),
                          if (isLocked)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Icon(Icons.lock, size: 10, color: AppTheme.warning),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: TextStyle(
                          color: isLocked
                              ? AppTheme.grey.withValues(alpha: 0.4)
                              : isSelected
                                  ? AppTheme.donorColor
                                  : AppTheme.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
