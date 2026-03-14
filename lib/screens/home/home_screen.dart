import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/gallery_provider.dart';

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
              _buildFeaturedSarees(context),
              const SizedBox(height: 28),
              _buildRecentTryOns(context),
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
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
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
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to drape beautifully today?',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  // Credits Badge
                  GestureDetector(
                    onTap: () => context.push('/home/credits'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
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
              GestureDetector(
                onTap: () => context.go('/explore'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.divider,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search saree styles...',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
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
        'icon': Icons.checkroom_rounded,
        'label': 'Catalogue',
        'color': AppColors.primaryLight,
        'route': '/explore',
      },
      {
        'icon': Icons.collections_rounded,
        'label': 'Gallery',
        'color': AppColors.info,
        'route': '/my-drapes',
      },
      {
        'icon': Icons.auto_awesome,
        'label': 'Try On',
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
          final route = action['route'] as String;
          return GestureDetector(
            onTap: () => context.push(route),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: (action['color'] as Color).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (action['color'] as Color).withValues(
                          alpha: 0.12,
                        ),
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

  // ─── AI Draping Hero Card (Coming Soon) ──────────────────────────────────

  Widget _buildAIDrapingCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/virtual-draping'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.auto_awesome,
                  size: 130,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppColors.info,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: AppColors.info,
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
                  Text(
                    'Virtual Saree\nTry-On',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try any saree style on your photo\nwith our AI — launching soon!',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      '\u{1F512} Coming Soon',
                      style: TextStyle(
                        color: AppColors.textHint,
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
  }

  // ─── Featured Sarees ──────────────────────────────────────────────────────

  Widget _buildFeaturedSarees(BuildContext context) {
    return Consumer<CatalogueProvider>(
      builder: (context, catalogue, _) {
        final featured = catalogue.assets.take(6).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Sarees',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/explore'),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (catalogue.isLoading)
              const SizedBox(
                height: 230,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (featured.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 90,
                  child: Center(
                    child: Text(
                      'No sarees available right now.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 230,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final saree = featured[i];
                    return GestureDetector(
                      onTap: () => context.go('/explore'),
                      child: Container(
                        width: 148,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: saree.thumbnailUrl.isNotEmpty
                                    ? Image.network(
                                        saree.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.surfaceVariant,
                                          child: const Center(
                                            child: Icon(
                                              Icons.style,
                                              color: AppColors.primaryLight,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceVariant,
                                        child: const Center(
                                          child: Icon(
                                            Icons.style,
                                            color: AppColors.primaryLight,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    saree.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${saree.region} • ${saree.fabricType}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '₹${_formatK(saree.price)}',
                                    style: const TextStyle(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
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
      },
    );
  }

  // ─── Recent Try-Ons ───────────────────────────────────────────────────────

  Widget _buildRecentTryOns(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, gallery, _) {
        final recent = gallery.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Try-Ons',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/my-drapes'),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (gallery.isLoading)
              const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 80,
                  child: Center(
                    child: Text(
                      'No try-ons yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final item = recent[i];
                    return GestureDetector(
                      onTap: () => context.go('/my-drapes'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 100,
                          height: 140,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              item.resultImageUrl.isNotEmpty
                                  ? Image.network(
                                      item.resultImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.surfaceVariant,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 36,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.surfaceVariant,
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 36,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    18,
                                    8,
                                    8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    item.sareenName ?? 'Try-On',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

String _formatK(double price) {
  final p = price.toInt();
  if (p >= 1000) {
    final t = p ~/ 1000;
    final r = p % 1000;
    return r == 0 ? '${t}k' : '$t,${r.toString().padLeft(3, '0')}';
  }
  return p.toString();
}
