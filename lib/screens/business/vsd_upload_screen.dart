import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/store_provider.dart';

class VsdUploadScreen extends StatefulWidget {
  const VsdUploadScreen({super.key});

  @override
  State<VsdUploadScreen> createState() => _VsdUploadScreenState();
}

class _VsdUploadScreenState extends State<VsdUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, String type) async {
    final storeProvider = context.read<StoreProvider>();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        switch (type) {
          case 'border':
            storeProvider.setBorderImage(image);
            break;
          case 'pallu':
            storeProvider.setPalluImage(image);
            break;
          case 'pleats':
            storeProvider.setPleatsImage(image);
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.virtualDraping),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.info, Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Virtual Saree Draping',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Upload Border, Pallu & Pleats images (combined or individual)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Upload Images',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'You can upload 3 individual images for Border, Pallu, and Pleats, or upload a combined image.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Three image upload slots
                Row(
                  children: [
                    _imageUploadSlot(
                      context,
                      label: AppStrings.border,
                      icon: Icons.border_style,
                      image: storeProvider.borderImage,
                      onTap: () => _pickImage(context, 'border'),
                      onRemove: () => storeProvider.setBorderImage(null),
                    ),
                    const SizedBox(width: 12),
                    _imageUploadSlot(
                      context,
                      label: AppStrings.pallu,
                      icon: Icons.texture,
                      image: storeProvider.palluImage,
                      onTap: () => _pickImage(context, 'pallu'),
                      onRemove: () => storeProvider.setPalluImage(null),
                    ),
                    const SizedBox(width: 12),
                    _imageUploadSlot(
                      context,
                      label: AppStrings.pleats,
                      icon: Icons.layers,
                      image: storeProvider.pleatsImage,
                      onTap: () => _pickImage(context, 'pleats'),
                      onRemove: () => storeProvider.setPleatsImage(null),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upload status
                _buildUploadStatus(storeProvider),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          storeProvider.clearVsdImages();
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _hasAnyImage(storeProvider)
                            ? () {
                                // TODO: Upload to API
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Images uploaded successfully! Virtual draping will be available soon.'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            : null,
                        child: const Text(AppStrings.uploadImages),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Image Guidelines',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...const [
                        '• Upload clear, high-resolution images',
                        '• Border: Close-up of the saree border pattern',
                        '• Pallu: Full pallu design from edge to edge',
                        '• Pleats: Pleated section showing the drape pattern',
                        '• Supported formats: JPG, PNG (max 5MB each)',
                      ].map(
                        (text) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            text,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _imageUploadSlot(
    BuildContext context, {
    required String label,
    required IconData icon,
    required XFile? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: image != null
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: image != null ? AppColors.primary : AppColors.divider,
              width: image != null ? 2 : 1,
              style: image != null ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: image != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: kIsWeb
                          ? Image.network(
                              image.path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon,
                          color: AppColors.textSecondary, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap to upload',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUploadStatus(StoreProvider provider) {
    final items = [
      {'label': 'Border', 'uploaded': provider.borderImage != null},
      {'label': 'Pallu', 'uploaded': provider.palluImage != null},
      {'label': 'Pleats', 'uploaded': provider.pleatsImage != null},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) {
        final uploaded = item['uploaded'] as bool;
        return Row(
          children: [
            Icon(
              uploaded ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: uploaded ? AppColors.success : AppColors.textHint,
            ),
            const SizedBox(width: 4),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 13,
                color: uploaded ? AppColors.success : AppColors.textSecondary,
                fontWeight: uploaded ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  bool _hasAnyImage(StoreProvider provider) {
    return provider.borderImage != null ||
        provider.palluImage != null ||
        provider.pleatsImage != null;
  }
}
