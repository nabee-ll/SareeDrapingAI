import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../models/saree_asset_model.dart';
import '../../providers/catalogue_provider.dart';

/// Drape styles matching web TryOnSection.
const List<String> _drapeStyles = [
  'Nivi Style',
  'Bengali Style',
  'Nauvari/Kashta Style',
  'Gujarati Style',
  'Lehenga Style',
  'Butterfly/Mumtaz Style',
  'Madisar/Tamil Brahmin Style',
  'Kodagu/Coorg Style',
];

const List<Map<String, String>> _accessoryIdeas = [
  {'name': 'Maang Tikka', 'place': 'Center of forehead'},
  {'name': 'Nose Ring (Nath)', 'place': 'Left nostril'},
  {'name': 'Bangles', 'place': 'Both wrists'},
  {'name': 'Gajra', 'place': 'Wrapped around bun'},
  {'name': 'Waist Belt', 'place': 'Over saree pleats'},
];

const List<String> _viewLabels = ['Front View', 'Side View', 'Back View', 'Pallu View'];

const List<String> _viewAssets = [
  'assets/images/front_view.png',
  'assets/images/side_view.png',
  'assets/images/back_view.png',
  'assets/images/pallu_view.png',
];

class VirtualDrapingScreen extends StatefulWidget {
  final SareeAsset? preselectedAsset;

  const VirtualDrapingScreen({super.key, this.preselectedAsset});

  @override
  State<VirtualDrapingScreen> createState() => _VirtualDrapingScreenState();
}

class _VirtualDrapingScreenState extends State<VirtualDrapingScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _personPhoto; // User's (person's) uploaded photo for try-on
  bool _collectionMode = true; // true = Curated Rack, false = Custom Upload (for saree)
  SareeAsset? _selectedSaree;
  String _selectedStyle = _drapeStyles.first;
  int _progress = 12;
  bool _isApplying = false;
  int _activeViewIndex = 0;
  bool _showStylistModal = false;
  bool _stylistModeAutonomous = true;

  @override
  void initState() {
    super.initState();
    _selectedSaree = widget.preselectedAsset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final catalogue = context.read<CatalogueProvider>();
      catalogue.load();
      if (_selectedSaree == null && catalogue.assets.isNotEmpty) {
        setState(() => _selectedSaree = catalogue.assets.first);
      }
    });
  }

  void _onCraftMyDrape() {
    if (_isApplying) return;
    setState(() {
      _isApplying = true;
      _progress = 15;
      _activeViewIndex = 0;
    });
    void advance() {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + 11).clamp(0, 100);
        if (_progress >= 100) {
          _isApplying = false;
          _progress = 100;
          return;
        }
      });
      if (_progress < 100) {
        Future.delayed(const Duration(milliseconds: 340), advance);
      }
    }
    Future.delayed(const Duration(milliseconds: 340), advance);
  }

  void _openStylistModal() {
    setState(() => _showStylistModal = true);
  }

  void _closeStylistModal() {
    setState(() => _showStylistModal = false);
  }

  Future<void> _pickPersonPhoto(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _personPhoto = File(picked.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not pick image. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Virtual Try-On'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<CatalogueProvider>(
        builder: (context, catalogue, _) {
          if (_selectedSaree == null && catalogue.assets.isNotEmpty && widget.preselectedAsset == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedSaree = catalogue.assets.first);
            });
          }
          final sareeList = catalogue.assets.take(6).toList();
          return Stack(
            children: [
              SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTag('GET STARTED'),
                const SizedBox(height: 6),
                Text(
                  'AI Virtual Try-On Studio',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload your photo, select a saree style, and let our AI create magic',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),

                // ─── 0. Upload Your Photo (person) ─────────────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_rounded, color: AppColors.primaryLight, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Upload Your Photo',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'A clear front-facing picture is needed for the try-on',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _personPhotoUploadArea(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 2. Choose Your Saree Base ─────────────────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. Choose Your Saree Base',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _modeSwitch(),
                      const SizedBox(height: 16),
                      if (_collectionMode) ...[
                        _sareeGrid(sareeList),
                        const SizedBox(height: 12),
                        _customColorRow(),
                      ] else
                        _uploadSlots(),
                      const SizedBox(height: 16),
                      _selectedSareeSummary(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 3. Select Draping Direction ─────────────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3. Select Draping Direction',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pick a traditional flow or design your own',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 14),
                      _styleGrid(),
                      const SizedBox(height: 16),
                      _currentStylePanel(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 4. Result Preview ───────────────────────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '4. Preview',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          Text(
                            '$_progress%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: LinearProgressIndicator(
                          value: _progress / 100,
                          minHeight: 10,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _resultImageBlock(),
                      const SizedBox(height: 12),
                      _viewThumbs(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 5. Style Up (accessories after drape) ────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5. Style Up',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Once your drape is ready, add accessories—bangles, earrings, maang tikka, and more—to complete your look.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _goldButton(
                            label: 'Refine with Stylist',
                            onPressed: _openStylistModal,
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: AppColors.divider),
                            ),
                            child: const Text('Adjust Render Settings'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _paletteRow(),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Download Hero Shot'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                          ),
                          child: const Text('Download Full Set'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Share Lookbook'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Accessory ideas',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ..._accessoryIdeas.map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          a['place']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
              if (_showStylistModal) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeStylistModal,
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.black54),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _stylistModal(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _personPhotoUploadArea() {
    final hasPhoto = _personPhoto != null;
    return GestureDetector(
      onTap: () => _showPersonPhotoSourceSheet(),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: hasPhoto ? AppColors.surfaceVariant.withValues(alpha: 0.4) : AppColors.surfaceVariant.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: hasPhoto ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.primaryLight.withValues(alpha: 0.3),
            width: hasPhoto ? 2 : 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _personPhoto!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Photo added. Tap to change',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 48,
                    color: AppColors.primaryLight.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload your photo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Camera or gallery • Front-facing works best',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPersonPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload your photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'A clear front-facing picture is needed for the AI try-on.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickPersonPhoto(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Take Photo'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickPersonPhoto(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _modeSwitch() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _collectionMode = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: _collectionMode ? AppTheme.primaryGradient : null,
                  color: _collectionMode ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _collectionMode
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  'Curated Rack',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _collectionMode ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _collectionMode = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: !_collectionMode ? AppTheme.primaryGradient : null,
                  color: _collectionMode ? Colors.transparent : null,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: !_collectionMode
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  'Custom Upload',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: !_collectionMode ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sareeGrid(List<SareeAsset> list) {
    if (list.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: const Text(
          'No sarees in catalogue. Browse Explore to add.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final s = list[i];
          final isSelected = _selectedSaree?.assetId == s.assetId;
          return GestureDetector(
            onTap: () => setState(() => _selectedSaree = s),
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.4),
                          AppColors.gold.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    s.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.fabricType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _customColorRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Custom Color',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Text(
                'Tune saree palette',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _colorDot(const Color(0xFF8B2252)),
              const SizedBox(width: 8),
              _colorDot(const Color(0xFFD4AF37)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );
  }

  Widget _uploadSlots() {
    const slots = ['Body/Pattern', 'Border', 'Pallu'];
    return Row(
      children: slots.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.35),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file_rounded, color: AppColors.primaryLight, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _selectedSareeSummary() {
    final s = _selectedSaree;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(child: Text('🪡', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Saree',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  s?.name ?? 'None selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (s != null)
                  Text(
                    '${s.region} • ${s.fabricType}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Change Saree'),
          ),
        ],
      ),
    );
  }

  Widget _styleGrid() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _drapeStyles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final style = _drapeStyles[i];
          final isSelected = _selectedStyle == style;
          return GestureDetector(
            onTap: () => setState(() => _selectedStyle = style),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    style,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Traditional and modern drape.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _currentStylePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Style',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedStyle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can switch styles anytime before final export.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isApplying ? null : _onCraftMyDrape,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _isApplying
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Composing Your Look...'),
                      ],
                    )
                  : const Text('Craft My Drape'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultImageBlock() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        height: 380,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F13),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _viewAssets[_activeViewIndex],
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _zoomBtn('-'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('100%', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  _zoomBtn('+'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(String label) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300)),
          ),
        ),
      ),
    );
  }

  Widget _viewThumbs() {
    return Row(
      children: List.generate(_viewLabels.length, (i) {
        final isActive = _activeViewIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _viewLabels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _activeViewIndex = i),
              child: Column(
                children: [
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive ? AppColors.primaryLight : AppColors.divider,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        _viewAssets[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _viewLabels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? AppColors.primaryLight : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _goldButton({required String label, required VoidCallback onPressed}) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: const Color(0xFF1a0e00),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _paletteRow() {
    const colors = [Color(0xFFb12358), Color(0xFFd1b266), Color(0xFF6b173d), Color(0xFFd9cfae)];
    return Row(
      children: colors.map((c) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _colorDot(c),
          )).toList(),
    );
  }

  Widget _stylistModal() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Stylist Assist',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose how you want to finalize this look.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 18),
            _stylistOption(
              title: 'Auto Curate',
              subtitle: 'Let the system suggest accessories and accents.',
              selected: _stylistModeAutonomous,
              onTap: () => setState(() => _stylistModeAutonomous = true),
            ),
            const SizedBox(height: 10),
            _stylistOption(
              title: 'Guide Manually',
              subtitle: 'Provide your preference notes for custom styling.',
              selected: !_stylistModeAutonomous,
              onTap: () => setState(() => _stylistModeAutonomous = false),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _closeStylistModal,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _closeStylistModal,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: const Color(0xFF1a0e00)),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stylistOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
