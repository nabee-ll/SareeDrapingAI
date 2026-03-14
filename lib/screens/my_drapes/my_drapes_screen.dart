import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/gallery_item_model.dart';
import '../../providers/gallery_provider.dart';

class MyDrapesScreen extends StatefulWidget {
  const MyDrapesScreen({super.key});

  @override
  State<MyDrapesScreen> createState() => _MyDrapesScreenState();
}

class _MyDrapesScreenState extends State<MyDrapesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, gallery, _) {
          if (gallery.isEmpty) {
            return _EmptyGallery(
              onExplore: () => context.go('/explore'),
              isLoading: gallery.isLoading,
            );
          }
          return RefreshIndicator(
            onRefresh: gallery.load,
            color: AppColors.primary,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: gallery.items.length,
              itemBuilder: (context, index) =>
                  _GalleryCard(item: gallery.items[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/home/virtual-draping'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_photo_alternate_outlined,
            color: Colors.white),
        label:
            const Text('New Try-On', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ── Gallery Card ──────────────────────────────────────────────────────────────

class _GalleryCard extends StatelessWidget {
  final GalleryItem item;
  const _GalleryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openImageViewer(context, item),
      onLongPress: () => _confirmDelete(context, item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            item.resultImageUrl.isNotEmpty
                ? Image.network(
                    item.resultImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image,
                          size: 40, color: AppColors.textHint),
                    ),
                  )
                : Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_outlined,
                        size: 40, color: AppColors.textHint),
                  ),
            // Gradient overlay with saree name
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
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
                  item.sareenName ?? 'Try-On Result',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Tap hint: small zoom icon in top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in_rounded,
                    size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context, GalleryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageViewerScreen(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GalleryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete item?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This result will be permanently removed from your gallery.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<GalleryProvider>().deleteItem(item.id);
    }
  }
}

// ── Full-Screen Image Viewer ─────────────────────────────────────────────────

class _ImageViewerScreen extends StatefulWidget {
  final GalleryItem item;
  const _ImageViewerScreen({required this.item});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  final TransformationController _controller = TransformationController();
  double _scale = 1.0;

  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;
  static const double _step = 0.75;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final next = (_scale + _step).clamp(_minScale, _maxScale);
    _setScale(next);
  }

  void _zoomOut() {
    final next = (_scale - _step).clamp(_minScale, _maxScale);
    _setScale(next);
  }

  void _resetZoom() {
    _setScale(1.0);
  }

  void _setScale(double scale) {
    _controller.value = Matrix4.identity()..scale(scale);
    setState(() => _scale = scale);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.sareenName ?? 'Try-On Result';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded),
            tooltip: 'Zoom Out',
            onPressed: _scale > _minScale ? _zoomOut : null,
          ),
          // Zoom level badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(_scale * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded),
            tooltip: 'Zoom In',
            onPressed: _scale < _maxScale ? _zoomIn : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Zoom',
            onPressed: _scale != 1.0 ? _resetZoom : null,
          ),
        ],
      ),
      body: InteractiveViewer(
        transformationController: _controller,
        minScale: _minScale,
        maxScale: _maxScale,
        onInteractionUpdate: (_) {
          final s = _controller.value.getMaxScaleOnAxis();
          if ((s - _scale).abs() > 0.01) setState(() => _scale = s);
        },
        child: Center(
          child: widget.item.resultImageUrl.isNotEmpty
              ? Image.network(
                  widget.item.resultImageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Colors.white38,
                  ),
                )
              : const Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.white38,
                ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({required this.onExplore, this.isLoading = false});

  final VoidCallback onExplore;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(50),
            ),
            child:
                const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('No results yet',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Browse the catalogue and generate\nyour first virtual try-on!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          if (isLoading) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse Catalogue'),
              style:
                  ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ],
        ],
      ),
    );
  }
}
