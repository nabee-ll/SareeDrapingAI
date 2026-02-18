import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/credit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/data_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingHeader(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              _buildAIDrapingCard(context),
              const SizedBox(height: 28),
              _buildSareeStylesSection(context),
              const SizedBox(height: 28),
              _buildVideosSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Greeting Header ──────────────────────────────────────────────────────

  Widget _buildGreetingHeader(BuildContext context) {
    return Consumer2<AuthProvider, CreditProvider>(
      builder: (context, auth, credits, _) {
        final name = auth.user?.fullName?.split(' ').first ?? 'User';
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, Color(0xFF2A0A18), AppColors.secondary],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaste, $name! \u{1F64F}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to drape beautifully today?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  // Credits Badge
                  GestureDetector(
                    onTap: () => context.push('/home/credits'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: AppColors.gold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${credits.credits}',
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'cr',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search styles, tutorials...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.primaryLight),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Colors.white, size: 20),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.grid_view_rounded,
        'label': 'Styles',
        'color': AppColors.primaryLight,
        'route': '/home/styles',
      },
      {
        'icon': Icons.play_circle_outline_rounded,
        'label': 'Videos',
        'color': AppColors.info,
        'route': '/home/tutorials',
      },
      {
        'icon': Icons.auto_awesome,
        'label': 'AI Drape',
        'color': AppColors.gold,
        'route': '/home/virtual-draping',
      },
      {
        'icon': Icons.stars_rounded,
        'label': 'Credits',
        'color': AppColors.gold,
        'route': '/home/credits',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () => context.push(action['route'] as String),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          (action['color'] as Color).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (action['color'] as Color)
                            .withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── AI Draping Hero Card ─────────────────────────────────────────────────

  Widget _buildAIDrapingCard(BuildContext context) {
    return Consumer<CreditProvider>(builder: (context, credits, _) {
      final canAfford = credits.canAfford(CreditCost.aiDraping);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () {
            if (canAfford) {
              context.push('/home/virtual-draping');
            } else {
              context.push('/home/credits');
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  Color(0xFF2A0A18),
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(Icons.auto_awesome,
                      size: 130,
                      color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            '\u2728 AI Powered',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Credit cost badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: canAfford
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: canAfford
                                  ? AppColors.success.withValues(alpha: 0.4)
                                  : AppColors.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded,
                                  size: 12,
                                  color: canAfford
                                      ? AppColors.success
                                      : AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                '${CreditCost.aiDraping} credits',
                                style: TextStyle(
                                  color: canAfford
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Virtual Saree\nDraping',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try any saree style on your photo\nwith our AI draping model',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        canAfford ? 'Try Now \u2192' : 'Buy Credits to Unlock',
                        style: TextStyle(
                          color: canAfford
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── Saree Styles Section ─────────────────────────────────────────────────

  Widget _buildSareeStylesSection(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, _) {
      final styles = dataProvider.getStylesPreview(8);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.regionalStyles,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => context.push('/home/styles'),
                  child: const Text('See All',
                      style: TextStyle(color: AppColors.primaryLight)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (dataProvider.isLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ))
          else
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: styles.length,
                itemBuilder: (context, index) {
                  final style = styles[index];
                  final colors = [
                    AppColors.primary,
                    AppColors.primaryLight,
                    AppColors.gold,
                    AppColors.info,
                  ];
                  final accent = colors[index % colors.length];
                  return GestureDetector(
                    onTap: () => context.push('/home/styles'),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.checkroom_rounded,
                                color: accent, size: 26),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            style.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            style.region,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  // ─── Videos / Tutorials Section ───────────────────────────────────────────

  Widget _buildVideosSection(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, _) {
      final tutorials = dataProvider.tutorials;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tutorial Videos',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => context.push('/home/tutorials'),
                  child: const Text('See All',
                      style: TextStyle(color: AppColors.primaryLight)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dataProvider.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ))
            else if (tutorials.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Center(
                  child: Text('No videos yet.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              // Featured video card (larger)
              GestureDetector(
                onTap: () => context.push('/home/tutorials'),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.info.withValues(alpha: 0.25),
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          child: const Icon(Icons.play_circle_fill_rounded,
                              color: AppColors.info, size: 60),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.info.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '\u25b6 Featured Video',
                                style: TextStyle(
                                    color: AppColors.info,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tutorials.first.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 13,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  tutorials.first.duration,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tutorials.first.difficulty,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Remaining tutorials list
            ...tutorials.skip(1).take(3).map((tutorial) {
              return GestureDetector(
                onTap: () => context.push('/home/tutorials'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.play_circle_fill_rounded,
                            color: AppColors.primaryLight, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 12, color: AppColors.textHint),
                                const SizedBox(width: 4),
                                Text(tutorial.duration,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tutorial.difficulty,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textHint, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
