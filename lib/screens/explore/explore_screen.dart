import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saree_asset_model.dart';
import '../../providers/catalogue_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String? _selectedRegion;

  final List<String> _regions = [
    'All', 'Kerala', 'Tamil Nadu', 'Bengal', 'Gujarat', 'Rajasthan',
    'Andhra Pradesh', 'Maharashtra', 'Odisha',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  context.read<CatalogueProvider>().setSearch(v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search sarees…',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.primaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textHint, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CatalogueProvider>().setSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide:
                      BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide:
                      BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Region filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final region = _regions[i];
                final isAll = region == 'All';
                final isSelected = isAll
                    ? _selectedRegion == null
                    : _selectedRegion == region;
                return ChoiceChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedRegion = isAll ? null : region;
                    });
                    context.read<CatalogueProvider>().setRegionFilter(
                        isAll ? null : region);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Grid
          Expanded(
            child: Consumer<CatalogueProvider>(
              builder: (context, catalogue, _) {
                if (catalogue.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (catalogue.assets.isEmpty) {
                  return const _EmptyView();
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: catalogue.assets.length,
                  itemBuilder: (context, index) =>
                      _AssetCard(asset: catalogue.assets[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Asset Card ────────────────────────────────────────────────────────────────

String _formatPrice(double price) {
  final p = price.toInt();
  if (p >= 1000) {
    final thousands = p ~/ 1000;
    final remainder = p % 1000;
    return remainder == 0
        ? '${thousands}k'
        : '$thousands,${remainder.toString().padLeft(3, '0')}';
  }
  return p.toString();
}

class _AssetCard extends StatelessWidget {
  final SareeAsset asset;
  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/virtual-draping',
          extra: asset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: asset.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        asset.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _PlaceholderImage(),
                      )
                    : _PlaceholderImage(),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${asset.region} • ${asset.fabricType}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${_formatPrice(asset.price)}',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Try On',
                          style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
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
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.style, color: AppColors.primaryLight, size: 40),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No sarees found',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'The catalogue is empty right now.\nCheck back soon!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
