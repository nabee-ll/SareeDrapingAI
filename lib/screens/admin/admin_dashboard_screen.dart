import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Welcome, ${auth.user?.fullName ?? 'Admin'}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Manage your Saree Draping AI platform',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),

            // Quick stats
            Text(
              'Quick Actions',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.55,
              children: [
                _ActionCard(
                  icon: Icons.video_library,
                  label: 'Manage Videos',
                  subtitle: 'Add, edit & delete tutorials',
                  color: AppColors.primary,
                  onTap: () => context.go('/admin/videos'),
                ),
                _ActionCard(
                  icon: Icons.style,
                  label: 'Manage Styles',
                  subtitle: 'Regional saree styles',
                  color: const Color(0xFF7B1FA2),
                  onTap: () => context.go('/admin/styles'),
                ),
                _ActionCard(
                  icon: Icons.monetization_on,
                  label: 'Credit Config',
                  subtitle: 'Packs & pricing',
                  color: AppColors.gold,
                  onTap: () => context.go('/admin/credits'),
                ),
                _ActionCard(
                  icon: Icons.people,
                  label: 'Users & Payments',
                  subtitle: 'User credits & transactions',
                  color: AppColors.info,
                  onTap: () => context.go('/admin/users'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // How to set admin
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.gold, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Admin Access Setup',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'To grant admin access to a user:\n'
                    '1. Go to Firebase Console → Firestore\n'
                    '2. Open the "users" collection\n'
                    '3. Find the user document by UID\n'
                    '4. Add/edit field: role = "admin"',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your UID: ${auth.user?.id ?? 'Not signed in'}',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            if (admin.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  admin.errorMessage!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
