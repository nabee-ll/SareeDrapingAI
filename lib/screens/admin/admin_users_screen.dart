import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      admin.loadUsers();
      admin.loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.secondaryLight,
          child: TabBar(
            controller: _tabs,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Transactions'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _UsersTab(admin: admin),
          _TransactionsTab(admin: admin),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// USERS TAB
// ──────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  final AdminProvider admin;
  const _UsersTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    if (admin.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (admin.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 12),
            const Text('No users found',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () => context.read<AdminProvider>().loadUsers(),
              child: const Text('Refresh',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: admin.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final user = admin.users[i];
        return _UserTile(
          user: user,
          onEditCredits: () =>
              _showEditCreditsDialog(context, user),
          onEditRole: () => _showEditRoleDialog(context, user),
        );
      },
    );
  }

  void _showEditCreditsDialog(BuildContext context, UserModel user) {
    final ctrl = TextEditingController(text: user.credits.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Edit Credits — ${user.fullName ?? user.email ?? 'User'}',
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Credits',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            suffixText: 'credits',
            suffixStyle: TextStyle(color: AppColors.gold),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () async {
              final newCredits = int.tryParse(ctrl.text.trim());
              if (newCredits == null) return;
              Navigator.of(context).pop();
              final ok = await context
                  .read<AdminProvider>()
                  .updateUserCredits(user.id!, newCredits);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Credits updated!' : 'Error'),
                    backgroundColor:
                        ok ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, UserModel user) {
    String selected = user.role ?? 'user';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Edit Role — ${user.fullName ?? user.email ?? 'User'}',
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final role in ['user', 'store_keeper', 'admin'])
                RadioListTile<String>(
                  value: role,
                  groupValue: selected,
                  onChanged: (v) => setSt(() => selected = v!),
                  title: Text(role,
                      style: const TextStyle(
                          color: AppColors.textPrimary)),
                  activeColor: AppColors.primary,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final ok = await context
                    .read<AdminProvider>()
                    .updateUserRole(user.id!, selected);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Role updated!' : 'Error'),
                      backgroundColor:
                          ok ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Save',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditCredits;
  final VoidCallback onEditRole;

  const _UserTile({
    required this.user,
    required this.onEditCredits,
    required this.onEditRole,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == 'admin'
        ? AppColors.error
        : user.role == 'store_keeper'
            ? AppColors.warning
            : AppColors.textHint;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  (user.fullName?.isNotEmpty == true
                          ? user.fullName![0]
                          : user.email?.isNotEmpty == true
                              ? user.email![0]
                              : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'No Name',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      user.email ?? user.phone ?? user.id ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.role ?? 'user',
                  style:
                      TextStyle(color: roleColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Credits
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond,
                        color: AppColors.gold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${user.credits} credits',
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.diamond_outlined,
                    size: 15, color: AppColors.gold),
                label: const Text('Credits',
                    style:
                        TextStyle(color: AppColors.gold, fontSize: 12)),
                onPressed: onEditCredits,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.manage_accounts_outlined,
                    size: 15, color: AppColors.info),
                label: const Text('Role',
                    style:
                        TextStyle(color: AppColors.info, fontSize: 12)),
                onPressed: onEditRole,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// TRANSACTIONS TAB
// ──────────────────────────────────────────────────────────

class _TransactionsTab extends StatelessWidget {
  final AdminProvider admin;
  const _TransactionsTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    if (admin.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (admin.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 12),
            const Text('No transactions yet',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () =>
                  context.read<AdminProvider>().loadTransactions(),
              child: const Text('Refresh',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: admin.transactions.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (context, i) {
        final tx = admin.transactions[i];
        final isPurchase = tx.amount > 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isPurchase ? AppColors.success : AppColors.error)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPurchase ? Icons.add : Icons.remove,
                  color: isPurchase ? AppColors.success : AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                    ),
                    Text(
                      '${tx.type} · ${tx.createdAt.toLocal().toString().substring(0, 16)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                    Text(
                      'User: ${tx.userId}',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${isPurchase ? '+' : ''}${tx.amount}',
                style: TextStyle(
                  color: isPurchase ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
