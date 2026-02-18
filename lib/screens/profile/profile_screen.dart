import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/data_seeder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (auth.user?.fullName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  auth.user?.fullName ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  auth.user?.email ?? auth.user?.phone ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Menu items
                _profileTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _profileTile(
                  context,
                  icon: Icons.card_membership,
                  title: 'Subscription',
                  subtitle: _planLabel(auth.user?.subscriptionTier),
                  onTap: () => context.push('/home/subscriptions'),
                ),
                _profileTile(
                  context,
                  icon: Icons.store_outlined,
                  title: 'Business Dashboard',
                  subtitle: 'Manage stores & designs',
                  onTap: () => context.push('/home/business'),
                ),
                _profileTile(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: auth.user?.language ?? 'English',
                  onTap: () {},
                ),
                _profileTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _profileTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                _profileTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                // ── Dev Tool: Seed Database ──────────────────────────────
                _SeedDatabaseButton(),
                const SizedBox(height: 8),
                // ─────────────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      auth.logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _planLabel(String? tier) {
    return switch (tier) {
      'basic' => 'Basic Plan',
      'premium' => 'Premium Plan',
      'annual' => 'Annual Premium',
      _ => 'Free Plan',
    };
  }

  Widget _profileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Seed Database Button ─────────────────────────────────────────────────────
class _SeedDatabaseButton extends StatefulWidget {
  @override
  State<_SeedDatabaseButton> createState() => _SeedDatabaseButtonState();
}

class _SeedDatabaseButtonState extends State<_SeedDatabaseButton> {
  bool _loading = false;
  String? _message;

  Future<void> _seed() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await DataSeeder().forceSeed();
      if (mounted) {
        setState(() {
          _loading = false;
          _message = '✅ Database seeded successfully!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _message = '❌ Failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _seed,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.info),
                  )
                : const Icon(Icons.cloud_upload_outlined,
                    color: AppColors.info),
            label: Text(
              _loading ? 'Uploading data...' : 'Seed Database',
              style: const TextStyle(color: AppColors.info),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.info),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(
            _message!,
            style: TextStyle(
              fontSize: 12,
              color: _message!.startsWith('✅')
                  ? AppColors.success
                  : AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
