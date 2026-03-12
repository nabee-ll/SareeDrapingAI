import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saree_asset_model.dart';

class VirtualDrapingScreen extends StatelessWidget {
  final SareeAsset? preselectedAsset;
  const VirtualDrapingScreen({super.key, this.preselectedAsset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Try-On'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon with glow
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 52,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Our AI-powered Virtual Saree Try-On feature is under development and will be available shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 36),
              // Feature preview chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: const [
                  _FeatureChip(label: '\u{1F457} Any Saree Style'),
                  _FeatureChip(label: '\u{1F4F7} Upload Your Photo'),
                  _FeatureChip(label: '\u2728 AI Draping'),
                  _FeatureChip(label: '\u{1F4BE} Save to Gallery'),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.primaryLight),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(color: AppColors.primaryLight),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.primaryLight.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
