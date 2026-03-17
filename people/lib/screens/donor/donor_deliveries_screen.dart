import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DonorDeliveriesScreen extends StatelessWidget {
  const DonorDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.donorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.donorColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Deliveries',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: AppTheme.donorColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Track your physical item deliveries, get verification codes, and coordinate with NGOs — all in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.grey,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
