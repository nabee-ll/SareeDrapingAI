import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/gallery_provider.dart';

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
      body: Consumer3<AuthProvider, CreditProvider, GalleryProvider>(
        builder: (context, auth, credits, gallery, _) {
          final user = auth.user;
          final displayName = (user?.fullName?.trim().isNotEmpty ?? false)
              ? user!.fullName!.trim()
              : 'User';
          final displayEmail = user?.email ?? 'No email available';
          final memberSince = user?.createdAt != null
              ? DateFormat('MMM yyyy').format(user!.createdAt!)
              : 'Recently joined';
          final avatarText = displayName.isNotEmpty
              ? displayName[0].toUpperCase()
              : 'U';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 980;
              final detailColumns = constraints.maxWidth >= 1240 ? 4 : 2;

              final header = Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      AppColors.surfaceVariant.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Text(
                        'ACCOUNT',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              avatarText,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayEmail,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Member since $memberSince',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final stats = _sectionCard(
                title: 'Overview',
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.stars_rounded,
                        label: 'Credits',
                        value: '${credits.credits}',
                        accent: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.photo_library_outlined,
                        label: 'Saved',
                        value: '${gallery.items.length}',
                        accent: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Plan',
                        value: _displayValue(
                          user?.subscriptionTier,
                          fallback: 'Free',
                        ),
                        accent: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              );

              final detailsSection = _sectionCard(
                title: 'Account Details',
                child: _detailGrid(
                  [
                    _detailItem('Phone', _displayValue(user?.phone)),
                    _detailItem('Region', _displayValue(user?.region)),
                    _detailItem('Language', _displayValue(user?.language)),
                    _detailItem(
                      'Role',
                      _displayValue(user?.role, fallback: 'User'),
                    ),
                  ],
                  crossAxisCount: detailColumns,
                  childAspectRatio: isDesktop ? 2.9 : 2.3,
                ),
              );

              final preferencesSection = _sectionCard(
                title: 'Style Preferences',
                child: _detailGrid(
                  [
                    _detailItem('Body Type', _displayValue(user?.bodyType)),
                    _detailItem(
                      'Experience',
                      _displayValue(user?.experienceLevel),
                    ),
                    _detailItem(
                      'Subscription',
                      _displayValue(user?.subscriptionTier, fallback: 'Free'),
                    ),
                    _detailItem('Tenant', _displayValue(user?.tenantId)),
                  ],
                  crossAxisCount: detailColumns,
                  childAspectRatio: isDesktop ? 2.9 : 2.3,
                ),
              );

              final actionsSection = _sectionCard(
                title: 'Actions',
                child: Column(
                  children: [
                    _profileTile(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () => _showComingSoon(context),
                    ),
                    _profileTile(
                      context,
                      icon: Icons.stars_rounded,
                      title: 'Buy Credits',
                      subtitle: '${credits.credits} credits remaining',
                      onTap: () => context.push('/home/credits'),
                    ),
                    _profileTile(
                      context,
                      icon: Icons.collections_rounded,
                      title: 'My Gallery',
                      subtitle: 'View your saved try-ons',
                      onTap: () => context.go('/my-drapes'),
                    ),
                    _profileTile(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage alerts and reminders',
                      onTap: () => _showComingSoon(context),
                    ),
                    _profileTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get assistance with your account',
                      onTap: () => _showComingSoon(context),
                    ),
                    _profileTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Drape & Glow',
                      subtitle: 'Version and platform information',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1220 : 760,
                    ),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    header,
                                    const SizedBox(height: 14),
                                    stats,
                                    const SizedBox(height: 14),
                                    _logoutButton(context, auth),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    detailsSection,
                                    const SizedBox(height: 14),
                                    preferencesSection,
                                    const SizedBox(height: 14),
                                    actionsSection,
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header,
                              const SizedBox(height: 14),
                              stats,
                              const SizedBox(height: 14),
                              detailsSection,
                              const SizedBox(height: 14),
                              preferencesSection,
                              const SizedBox(height: 14),
                              actionsSection,
                              const SizedBox(height: 14),
                              _logoutButton(context, auth),
                            ],
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_sectionTitle(title), child],
      ),
    );
  }

  Widget _logoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          auth.logout();
          context.go('/login');
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text('Logout', style: TextStyle(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailGrid(
    List<Widget> children, {
    int crossAxisCount = 2,
    double childAspectRatio = 2.3,
  }) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  Widget _detailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? raw, {String fallback = 'Not set'}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    return raw.trim();
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon.')),
    );
  }

  Widget _profileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        tileColor: AppColors.surfaceVariant.withValues(alpha: 0.38),
        minLeadingWidth: 40,
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
