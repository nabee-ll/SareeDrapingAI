import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/tutorial_model.dart';
import '../../providers/admin_provider.dart';

class AdminVideosScreen extends StatefulWidget {
  const AdminVideosScreen({super.key});

  @override
  State<AdminVideosScreen> createState() => _AdminVideosScreenState();
}

class _AdminVideosScreenState extends State<AdminVideosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTutorials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Video'),
        onPressed: () => _openEditDialog(context, null),
      ),
      body: admin.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : admin.tutorials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.video_library_outlined,
                          color: AppColors.textHint, size: 56),
                      const SizedBox(height: 12),
                      const Text('No tutorials yet',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary),
                        onPressed: () => context
                            .read<AdminProvider>()
                            .loadTutorials(),
                        child: const Text('Refresh',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: admin.tutorials.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = admin.tutorials[index];
                    return _TutorialTile(
                      tutorial: t,
                      onEdit: () => _openEditDialog(context, t),
                      onDelete: () => _confirmDelete(context, t),
                    );
                  },
                ),
    );
  }

  void _openEditDialog(BuildContext context, TutorialModel? existing) {
    showDialog(
      context: context,
      builder: (_) => _TutorialEditDialog(
        tutorial: existing,
        onSave: (tutorial) async {
          final ok =
              await context.read<AdminProvider>().saveTutorial(tutorial);
          if (ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Saved!'),
                  backgroundColor: AppColors.success),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, TutorialModel t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Tutorial',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Delete "${t.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AdminProvider>().deleteTutorial(t.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TutorialTile extends StatelessWidget {
  final TutorialModel tutorial;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TutorialTile(
      {required this.tutorial, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Video icon or thumbnail indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              tutorial.videoUrl != null
                  ? Icons.play_circle
                  : Icons.video_library_outlined,
              color: tutorial.videoUrl != null
                  ? AppColors.primary
                  : AppColors.textHint,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutorial.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tutorial.difficulty} · ${tutorial.duration} · ${tutorial.steps} steps',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                if (tutorial.videoUrl != null)
                  Text(
                    tutorial.videoUrl!,
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.gold, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

class _TutorialEditDialog extends StatefulWidget {
  final TutorialModel? tutorial;
  final void Function(TutorialModel) onSave;

  const _TutorialEditDialog({this.tutorial, required this.onSave});

  @override
  State<_TutorialEditDialog> createState() => _TutorialEditDialogState();
}

class _TutorialEditDialogState extends State<_TutorialEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _difficulty;
  late TextEditingController _duration;
  late TextEditingController _videoUrl;
  late TextEditingController _thumbnailUrl;
  late TextEditingController _steps;

  @override
  void initState() {
    super.initState();
    final t = widget.tutorial;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _difficulty = TextEditingController(text: t?.difficulty ?? 'Beginner');
    _duration = TextEditingController(text: t?.duration ?? '10 min');
    _videoUrl = TextEditingController(text: t?.videoUrl ?? '');
    _thumbnailUrl = TextEditingController(text: t?.thumbnailUrl ?? '');
    _steps = TextEditingController(text: t?.steps.toString() ?? '0');
  }

  @override
  void dispose() {
    for (final c in [
      _title, _description, _difficulty, _duration,
      _videoUrl, _thumbnailUrl, _steps
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.tutorial;
    final tutorial = TutorialModel(
      id: existing?.id ??
          'tutorial_${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      difficulty: _difficulty.text.trim(),
      duration: _duration.text.trim(),
      steps: int.tryParse(_steps.text.trim()) ?? 0,
      category: existing?.category ?? 'Beginner Tutorials',
      videoUrl:
          _videoUrl.text.trim().isEmpty ? null : _videoUrl.text.trim(),
      thumbnailUrl: _thumbnailUrl.text.trim().isEmpty
          ? null
          : _thumbnailUrl.text.trim(),
    );
    widget.onSave(tutorial);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.tutorial == null ? 'Add Tutorial' : 'Edit Tutorial',
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_title, 'Title', required: true),
                _field(_description, 'Description', maxLines: 2),
                _field(_videoUrl, 'Video URL (YouTube/direct)'),
                _field(_thumbnailUrl, 'Thumbnail URL'),
                Row(
                  children: [
                    Expanded(
                        child: _field(_difficulty, 'Difficulty',
                            required: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _field(_duration, 'Duration (e.g. 15 min)')),
                  ],
                ),
                _field(_steps, 'Number of Steps',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _submit,
          child: const Text('Save',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textHint, fontSize: 12),
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: AppColors.secondaryLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }
}
