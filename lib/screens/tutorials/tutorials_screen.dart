import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty filter
            Text(
              'Step-by-Step Video Tutorials',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Learn at your own pace with guided tutorials',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _tutorialCategory(
                    context,
                    title: 'Beginner Tutorials',
                    subtitle: 'Start your draping journey',
                    icon: Icons.school,
                    color: AppColors.success,
                    tutorials: [
                      _TutorialItem('Nivi Drape Basics', '12 min', 8),
                      _TutorialItem('Understanding Fabric', '8 min', 5),
                      _TutorialItem('Pleating 101', '10 min', 6),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _tutorialCategory(
                    context,
                    title: 'Intermediate Tutorials',
                    subtitle: 'Expand your skills',
                    icon: Icons.trending_up,
                    color: AppColors.warning,
                    tutorials: [
                      _TutorialItem('Bengali Style Complete', '18 min', 12),
                      _TutorialItem('Gujarati Seedha Pallu', '15 min', 9),
                      _TutorialItem('Coorgi Drape', '16 min', 10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _tutorialCategory(
                    context,
                    title: 'Advanced Tutorials',
                    subtitle: 'Master complex styles',
                    icon: Icons.star,
                    color: AppColors.error,
                    tutorials: [
                      _TutorialItem('Maharashtrian Nauvari', '25 min', 15),
                      _TutorialItem('Madisar (9-yard)', '30 min', 18),
                      _TutorialItem('Bridal Draping', '28 min', 16),
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

  Widget _tutorialCategory(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<_TutorialItem> tutorials,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${tutorials.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ...tutorials.map(
            (tutorial) => ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_circle_outline,
                    color: AppColors.primary),
              ),
              title: Text(tutorial.title,
                  style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                '${tutorial.duration} · ${tutorial.steps} steps',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textHint),
              onTap: () {
                // TODO: Open tutorial
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialItem {
  final String title;
  final String duration;
  final int steps;

  _TutorialItem(this.title, this.duration, this.steps);
}
