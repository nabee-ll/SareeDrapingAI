import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saree_asset_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/gallery_provider.dart';

const List<String> _fabricFilters = [
  'All', 'Silk', 'Cotton', 'Georgette', 'Banarasi', 'Chiffon', 'Linen',
];

const List<Map<String, String>> _showcaseSarees = [
  {
    'name': 'Kanjivaram Classic',
    'meta': 'Tamil Nadu • Silk',
    'price': '₹12,000',
    'image': 'assets/images/front_view.png',
  },
  {
    'name': 'Bandhani Glow',
    'meta': 'Gujarat • Georgette',
    'price': '₹8,000',
    'image': 'assets/images/side_view.png',
  },
  {
    'name': 'Banarasi Royal',
    'meta': 'Varanasi • Silk',
    'price': '₹15,000',
    'image': 'assets/images/back_view.png',
  },
  {
    'name': 'Pallu Elegance',
    'meta': 'Designer • Fusion',
    'price': '₹10,000',
    'image': 'assets/images/pallu_view.png',
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;
  String _selectedFabric = 'All';
  final Set<String> _wishlist = {};

  late AnimationController _aiCardPulseController;
  late Animation<double> _aiCardPulse;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _aiCardPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _aiCardPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _aiCardPulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CatalogueProvider>().load();
      context.read<GalleryProvider>().load();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _aiCardPulseController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showFab) setState(() => _showFab = shouldShow);
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<CatalogueProvider>().load(),
      context.read<GalleryProvider>().load(),
    ]);
  }

  List<SareeAsset> _filteredSarees(List<SareeAsset> all) {
    if (_selectedFabric == 'All') return all.take(8).toList();
    return all
        .where((s) => s.fabricType.toLowerCase().contains(_selectedFabric.toLowerCase()))
        .take(8)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AnimatedScale(
        scale: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton.small(
          onPressed: _scrollToTop,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.keyboard_arrow_up_rounded, size: 24),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingHeader(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildStatsStrip(context),
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
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.user?.fullName?.split(' ').first ?? 'User';
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaste, $name! \u{1F64F}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to drape beautifully today?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _AnimatedSearchBar(onTap: () => context.go('/explore')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.checkroom_rounded, 'label': 'Catalogue', 'color': AppColors.primaryLight, 'route': '/explore'},
      {'icon': Icons.collections_rounded, 'label': 'Gallery', 'color': AppColors.info, 'route': '/my-drapes'},
      {'icon': Icons.auto_awesome, 'label': 'Try On', 'color': AppColors.gold, 'route': '/home/virtual-draping'},
      {'icon': Icons.stars_rounded, 'label': 'Credits', 'color': AppColors.gold, 'route': '/home/credits'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return _PressableQuickAction(
            icon: a['icon'] as IconData,
            label: a['label'] as String,
            color: a['color'] as Color,
            onTap: () => context.push(a['route'] as String),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsStrip(BuildContext context) {
    return Consumer3<CatalogueProvider, GalleryProvider, CreditProvider>(
      builder: (context, catalogue, gallery, credits, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _statItem(
                  icon: Icons.style_rounded,
                  color: AppColors.primaryLight,
                  value: '${catalogue.assets.length}',
                  label: 'Sarees',
                ),
                _statDivider(),
                _statItem(
                  icon: Icons.collections_rounded,
                  color: AppColors.info,
                  value: '${gallery.items.length}',
                  label: 'Try-Ons',
                ),
                _statDivider(),
                _statItem(
                  icon: Icons.stars_rounded,
                  color: AppColors.gold,
                  value: '${credits.credits}',
                  label: 'Credits',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 40, color: AppColors.divider);
  }

  Widget _buildAIDrapingCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _aiCardPulse,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.10 + _aiCardPulse.value * 0.14,
                  ),
                  blurRadius: 24 + _aiCardPulse.value * 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => context.push('/home/virtual-draping'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surfaceVariant.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 120,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _sectionChip('STYLE TIP'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 7, color: AppColors.success),
                              SizedBox(width: 5),
                              Text(
                                'Live',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'See Yourself in\nAny Saree, Instantly',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your photo, choose a saree, and watch AI create a photorealistic image.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/home/virtual-draping'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text(
                              'Start Try-On',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => context.go('/explore'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Browse',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSarees(BuildContext context) {
    return Consumer<CatalogueProvider>(
      builder: (context, catalogue, _) {
        final filtered = _filteredSarees(catalogue.assets);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionChip('BROWSE'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Featured Sarees',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/explore'),
                        child: const Text(
                          'See all →',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _fabricFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _fabricFilters[i];
                  final selected = _selectedFabric == f;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFabric = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.divider,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    if (catalogue.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No sarees found for "$_selectedFabric". Showing showcase picks.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _showcaseSarees.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final item = _showcaseSarees[i];
                          return GestureDetector(
                            onTap: () => context.go('/explore'),
                            child: Container(
                              width: 148,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Image.asset(
                                        item['image']!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name']!,
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
                                          item['meta']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          item['price']!,
                                          style: const TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w700,
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
                ),
              )
            else
              SizedBox(
                height: 230,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final saree = filtered[i];
                    final liked = _wishlist.contains(saree.assetId);
                    return _SareeCard(
                      saree: saree,
                      liked: liked,
                      onTap: () => context.go('/explore'),
                      onLike: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          liked
                              ? _wishlist.remove(saree.assetId)
                              : _wishlist.add(saree.assetId);
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecentTryOns(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, gallery, _) {
        final recent = gallery.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionChip('YOUR CREATIONS'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Recent Try-Ons',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/my-drapes'),
                        child: const Text(
                          'See all →',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/home/virtual-draping'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.2),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _emptyPreviewTile('assets/images/front_view.png'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _emptyPreviewTile('assets/images/side_view.png'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _emptyPreviewTile('assets/images/back_view.png'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No try-ons yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to create your first AI drape',
                              style: TextStyle(color: AppColors.primaryLight, fontSize: 12),
                            ),
                            if (gallery.isLoading) ...[
                              const SizedBox(height: 10),
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
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
                                  padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
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

  static Widget _sectionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _emptyPreviewTile(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 74,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _AnimatedSearchBar extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedSearchBar({required this.onTap});

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAlpha;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _borderAlpha = Tween<double>(begin: 0.22, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _borderAlpha,
        builder: (context, _) {
          return AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: _borderAlpha.value),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: _pressed ? 0.12 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primaryLight, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search sarees, styles, regions...',
                      style: TextStyle(color: AppColors.textHint, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Explore →',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PressableQuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PressableQuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PressableQuickAction> createState() => _PressableQuickActionState();
}

class _PressableQuickActionState extends State<_PressableQuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SareeCard extends StatefulWidget {
  final SareeAsset saree;
  final bool liked;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _SareeCard({
    required this.saree,
    required this.liked,
    required this.onTap,
    required this.onLike,
  });

  @override
  State<_SareeCard> createState() => _SareeCardState();
}

class _SareeCardState extends State<_SareeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onLike() {
    _heartController.forward(from: 0);
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    final saree = widget.saree;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    saree.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            saree.thumbnailUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child: Icon(Icons.style,
                                    color: AppColors.primaryLight, size: 40),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: Icon(Icons.style,
                                  color: AppColors.primaryLight, size: 40),
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _onLike,
                        child: AnimatedBuilder(
                          animation: _heartScale,
                          builder: (context, child) => Transform.scale(
                            scale: _heartScale.value,
                            child: child,
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: widget.liked
                                  ? AppColors.primary.withValues(alpha: 0.92)
                                  : Colors.white.withValues(alpha: 0.88),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: widget.liked ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${_formatPrice(saree.price)}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
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
  }
}

String _formatPrice(double price) {
  final value = price.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    buf.write(value[i]);
    final remaining = value.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buf.write(',');
    }
  }
  return buf.toString();
}
