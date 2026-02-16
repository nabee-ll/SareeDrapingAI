import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MyDrapesScreen extends StatelessWidget {
  const MyDrapesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drapes'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
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
              child: const Icon(Icons.checkroom, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No drapes saved yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start exploring styles and save\nyour favorites here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              child: const Text('Explore Styles'),
            ),
          ],
        ),
      ),
    );
  }
}
