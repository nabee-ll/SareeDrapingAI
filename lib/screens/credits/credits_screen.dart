import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/credit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/data_provider.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Credits'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer3<CreditProvider, AuthProvider, DataProvider>(
        builder: (context, credits, auth, data, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BalanceCard(credits: credits.credits),
                const SizedBox(height: 8),
                _HowItWorksCard(),
                const SizedBox(height: 24),
                Text(
                  'Buy Credits',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pay securely via UPI, Card, or Wallet',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _PacksGrid(
                  packs: data.creditPacks,
                  currentCredits: credits.credits,
                  authProvider: auth,
                  creditProvider: credits,
                ),
                if (credits.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(credits.errorMessage!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: AppColors.error),
                          onPressed: credits.clearError,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (credits.transactions.isNotEmpty) ...[
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _TransactionList(transactions: credits.transactions),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final int credits;
  const _BalanceCard({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, Color(0xFF2A0A18), AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Your Credit Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$credits',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'CREDITS',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CostChip(
                icon: Icons.auto_awesome,
                label: '${CreditCost.aiDraping} credits — AI Draping',
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              _CostChip(
                icon: Icons.style,
                label: '${CreditCost.stylishLook} credits — Stylish Look',
                color: AppColors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CostChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── How It Works ─────────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.primaryLight, size: 16),
              SizedBox(width: 6),
              Text('How Credits Work',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          _HowItem(icon: Icons.auto_awesome, text: 'AI Draping Model costs ${CreditCost.aiDraping} credits per use', color: AppColors.primaryLight),
          const SizedBox(height: 6),
          _HowItem(icon: Icons.style, text: 'Stylish Look feature costs ${CreditCost.stylishLook} credits per use', color: AppColors.gold),
          const SizedBox(height: 6),
          _HowItem(icon: Icons.security, text: 'All payments secured by Razorpay with UPI, Cards & Wallets', color: AppColors.success),
        ],
      ),
    );
  }
}

class _HowItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _HowItem({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ),
      ],
    );
  }
}

// ─── Packs Grid ───────────────────────────────────────────────────────────────

class _PacksGrid extends StatelessWidget {
  final List<CreditPack> packs;
  final int currentCredits;
  final AuthProvider authProvider;
  final CreditProvider creditProvider;

  const _PacksGrid({
    required this.packs,
    required this.currentCredits,
    required this.authProvider,
    required this.creditProvider,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: packs
          .map((pack) => _PackCard(
                pack: pack,
                isLoading: creditProvider.isLoading,
                onBuy: () {
                  final user = authProvider.user;
                  creditProvider.purchaseCreditPack(
                    pack: pack,
                    userId: user?.id ?? '',
                    userName: user?.fullName ?? '',
                    userEmail: user?.email ?? '',
                    userPhone: user?.phone ?? '',
                  );
                },
              ))
          .toList(),
    );
  }
}

class _PackCard extends StatelessWidget {
  final CreditPack pack;
  final bool isLoading;
  final VoidCallback onBuy;

  const _PackCard({
    required this.pack,
    required this.isLoading,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
        pack.isBestValue ? AppColors.gold : AppColors.primaryLight;

    return Stack(
      children: [
        InkWell(
          onTap: isLoading ? null : onBuy,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: pack.isBestValue
                    ? AppColors.gold.withValues(alpha: 0.6)
                    : AppColors.divider,
                width: pack.isBestValue ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.stars_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      pack.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${pack.credits}',
                            style: TextStyle(
                              color: accent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: ' cr',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pack.bonus.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        pack.bonus,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          pack.isBestValue ? AppColors.gold : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: isLoading ? null : onBuy,
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            '₹${pack.priceInRupees}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (pack.isBestValue)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Transaction List ─────────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  final List<CreditTransaction> transactions;
  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions.take(20).map((tx) {
        final isCredit = tx.amount > 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCredit
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCredit ? Icons.add_circle_outline : Icons.bolt,
                  color: isCredit ? AppColors.success : AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(tx.createdAt),
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '${isCredit ? '+' : ''}${tx.amount}',
                style: TextStyle(
                  color: isCredit ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
