import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../common/public_donor_profile_screen.dart';
import '../common/public_volunteer_profile_screen.dart';

class NGOTransactionsScreen extends StatefulWidget {
  const NGOTransactionsScreen({super.key});

  @override
  State<NGOTransactionsScreen> createState() => _NGOTransactionsScreenState();
}

class _NGOTransactionsScreenState extends State<NGOTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  void _loadTransactions() {
    // Mock data load
    setState(() {
      _transactions = Transaction.getMockTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.ngoColor,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.grey,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Incoming'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
            dividerColor: Colors.transparent,
          ),
        ),

        // Tab View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIncomingList(),
              _buildPendingList(),
              _buildCompletedList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingList() {
    final incoming = _transactions
        .where((t) => t.status == TransactionStatus.incoming)
        .toList();

    if (incoming.isEmpty) return _buildEmptyState('No new requests');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: incoming.length,
      itemBuilder: (context, index) {
        final t = incoming[index];
        return InkWell(
          onTap: () => _showDonationDetails(t),
          borderRadius: BorderRadius.circular(16),
          child: _buildTransactionCard(
            t,
            // Visual indicator that it's clickable, maybe an arrow or just the card style
          ),
        );
      },
    );
  }

  void _showDonationDetails(Transaction t) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Donation Details',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Donor', t.donorName),
              const SizedBox(height: 12),
              _buildDetailRow('Item', t.itemName),
              const SizedBox(height: 12),
              _buildDetailRow('Quantity', t.quantity),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Delivery',
                t.isDonorDelivering ? 'Donor will deliver' : 'Needs Volunteer',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Date',
                '${t.date.day}/${t.date.month}/${t.date.year}',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close modal first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicDonorProfileScreen(
                          donorId: t.donorId,
                          donorName: t.donorName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('View Donor Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ngoColor,
                    side: const BorderSide(color: AppTheme.ngoColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reject logic (remove from list for now)
                        setState(() {
                          _transactions.removeWhere((tr) => tr.id == t.id);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Donation rejected')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (t.isDonorDelivering) {
                          _approveWithVerificationCode(t);
                        } else {
                          _updateStatus(t, TransactionStatus.needsVolunteer);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Donation Accepted')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ngoColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingList() {
    final pending = _transactions.where((t) {
      return t.status == TransactionStatus.pendingDelivery ||
          t.status == TransactionStatus.needsVolunteer ||
          t.status == TransactionStatus.volunteerAssigned;
    }).toList();

    if (pending.isEmpty) return _buildEmptyState('No pending deliveries');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final t = pending[index];
        String statusText;
        Color statusColor;
        String? actionLabel;
        VoidCallback? onAction;

        if (t.status == TransactionStatus.pendingDelivery) {
          statusText = 'Donor Delivering';
          statusColor = AppTheme.gold;
          actionLabel = 'Verify & Receive';
          onAction = () => _showVerificationDialog(t);
        } else if (t.status == TransactionStatus.needsVolunteer) {
          statusText = 'Needs Volunteer';
          statusColor = AppTheme.warning;
          // In real app, this might open a dialog to assign/approve volunteer
          actionLabel = 'Assign Volunteer';
          onAction = () => _showVolunteerSelectionDialog(t);
        } else {
          statusText = 'Volunteer: ${t.volunteerName}';
          statusColor = AppTheme.volunteerColor;
          actionLabel = 'Mark Received';
          onAction = () => _updateStatus(t, TransactionStatus.completed);
        }

        return _buildTransactionCard(
          t,
          statusTag: _buildStatusTag(statusText, statusColor),
          actionLabel: actionLabel,
          onAction: onAction,
        );
      },
    );
  }

  Widget _buildCompletedList() {
    final completed = _transactions
        .where((t) => t.status == TransactionStatus.completed)
        .toList();

    if (completed.isEmpty) return _buildEmptyState('No completed transactions');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(
          completed[index],
          statusTag: _buildStatusTag('Completed', AppTheme.success),
        );
      },
    );
  }

  /// Generates a verification code like "JD-4827"
  /// Format: [First letter of first name][First letter of last name]-[4 random digits]
  String _generateVerificationCode(String donorName) {
    final random = Random();
    final parts = donorName.trim().split(' ');

    // Get initials (first letter of first name + first letter of last name if exists)
    String initials;
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].length >= 2) {
      initials = parts[0].substring(0, 2).toUpperCase();
    } else {
      initials = 'VR'; // Fallback
    }

    // Generate 4 random digits
    final digits = (1000 + random.nextInt(9000)).toString();

    return '$initials-$digits';
  }

  /// Approves a transaction and generates a verification code for donor delivery
  void _approveWithVerificationCode(Transaction t) {
    final verificationCode = _generateVerificationCode(t.donorName);

    setState(() {
      final index = _transactions.indexWhere((tr) => tr.id == t.id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: t.id,
          donorId: t.donorId,
          donorName: t.donorName,
          itemName: t.itemName,
          quantity: t.quantity,
          status: TransactionStatus.pendingDelivery,
          isDonorDelivering: t.isDonorDelivering,
          volunteerId: t.volunteerId,
          volunteerName: t.volunteerName,
          verificationCode: verificationCode,
          date: t.date,
        );
      }
    });

    // TODO: Save to Firestore with the generated verification code
    // FirebaseFirestore.instance.collection('transactions').doc(t.id).update({
    //   'status': 'pendingDelivery',
    //   'verificationCode': verificationCode,
    //   'approvedAt': FieldValue.serverTimestamp(),
    // });
  }

  void _updateStatus(Transaction t, TransactionStatus newStatus) {
    setState(() {
      final index = _transactions.indexWhere((tr) => tr.id == t.id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: t.id,
          donorId: t.donorId,
          donorName: t.donorName,
          itemName: t.itemName,
          quantity: t.quantity,
          status: newStatus,
          isDonorDelivering: t.isDonorDelivering,
          volunteerId: t.volunteerId,
          volunteerName: t.volunteerName,
          verificationCode: t.verificationCode,
          date: t.date,
        );
      }
    });
  }

  void _showVerificationDialog(Transaction t) {
    final codeController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.verified_user, color: AppTheme.gold),
              const SizedBox(width: 12),
              const Text('Verify Delivery'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the verification code shown by ${t.donorName}:',
                style: TextStyle(color: AppTheme.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'XX-0000',
                  hintStyle: TextStyle(
                    color: AppTheme.grey.withValues(alpha: 0.4),
                  ),
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.gold),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.gold, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.gold.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The donor should show you this code on their app',
                        style: TextStyle(color: AppTheme.info, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredCode = codeController.text.trim().toUpperCase();
                final expectedCode = t.verificationCode?.toUpperCase() ?? '';

                if (enteredCode.isEmpty) {
                  setDialogState(() => errorText = 'Please enter a code');
                  return;
                }

                if (enteredCode == expectedCode || expectedCode.isEmpty) {
                  Navigator.pop(context);
                  _updateStatus(t, TransactionStatus.completed);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Donation from ${t.donorName} received!'),
                        ],
                      ),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                } else {
                  setDialogState(
                    () => errorText = 'Invalid code. Please try again.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ngoColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    Transaction t, {
    Widget? statusTag,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.ngoColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: AppTheme.ngoColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.donorName,
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${t.quantity} • ${t.itemName}',
                        style: TextStyle(color: AppTheme.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              if (statusTag != null) statusTag,
            ],
          ),
          if (t.status == TransactionStatus.incoming) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                t.isDonorDelivering
                    ? 'Donor will deliver'
                    : 'Requires Volunteer',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.grey,
                ),
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ngoColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppTheme.grey.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppTheme.grey, fontSize: 14)),
        ],
      ),
    );
  }

  void _showVolunteerSelectionDialog(Transaction t) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Volunteer',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${t.interestedVolunteers.length} volunteers interested',
                style: TextStyle(color: AppTheme.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              if (t.interestedVolunteers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Waiting for volunteers to accept...',
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: t.interestedVolunteers.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: AppTheme.grey.withValues(alpha: 0.1)),
                    itemBuilder: (context, index) {
                      final vol = t.interestedVolunteers[index];
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PublicVolunteerProfileScreen(volunteer: vol),
                            ),
                          ).then((_) {
                            // Reshow dialog when returning if needed, or just let user click again.
                            // For simplicity, we just return to list. User can click Assign again.
                            // To improve UX, could reshow dialog here, but might feel jumpy.
                            // Let's rely on user flow: Check profile -> Back -> Click Assign again -> Select.
                            // Or better: keep dialog open? Cannot easily push on top of dialog context without closing it usually.

                            // Actually, standard pattern:
                            // 1. Click row -> Go to profile.
                            // 2. Profile has "Select" or "Back".
                            // If Profile is just for viewing, we pop back.
                            // User has to click "Assign" again on the Item Card.
                            // Wait, if we pop the dialog to show profile, the dialog is gone.
                            // Let's just pop.
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.volunteerColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.volunteerColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          vol.name,
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppTheme.gold,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vol.rating.toString(),
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _assignVolunteer(t, vol);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ngoColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Approve'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _assignVolunteer(Transaction t, VolunteerPreview vol) {
    setState(() {
      final index = _transactions.indexWhere((tr) => tr.id == t.id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: t.id,
          donorId: t.donorId,
          donorName: t.donorName,
          itemName: t.itemName,
          quantity: t.quantity,
          status: TransactionStatus.volunteerAssigned,
          isDonorDelivering: false,
          date: t.date,
          volunteerId: vol.id,
          volunteerName: vol.name,
          verificationCode: t.verificationCode,
          interestedVolunteers: t.interestedVolunteers,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assigned ${vol.name} to pickup'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}
