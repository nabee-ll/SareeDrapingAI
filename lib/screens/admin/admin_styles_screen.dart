import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/regional_style.dart';
import '../../providers/admin_provider.dart';

class AdminStylesScreen extends StatefulWidget {
  const AdminStylesScreen({super.key});

  @override
  State<AdminStylesScreen> createState() => _AdminStylesScreenState();
}

class _AdminStylesScreenState extends State<AdminStylesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStyles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Style'),
        onPressed: () => _openEditDialog(context, null),
      ),
      body: admin.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : admin.styles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.style_outlined,
                          color: AppColors.textHint, size: 56),
                      const SizedBox(height: 12),
                      const Text('No styles yet',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary),
                        onPressed: () =>
                            context.read<AdminProvider>().loadStyles(),
                        child: const Text('Refresh',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: admin.styles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final s = admin.styles[i];
                    return _StyleTile(
                      style: s,
                      onEdit: () => _openEditDialog(context, s),
                      onDelete: () => _confirmDelete(context, s),
                    );
                  },
                ),
    );
  }

  void _openEditDialog(BuildContext context, RegionalStyle? existing) {
    showDialog(
      context: context,
      builder: (_) => _StyleEditDialog(
        style: existing,
        onSave: (style) async {
          final ok = await context.read<AdminProvider>().saveStyle(style);
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

  void _confirmDelete(BuildContext context, RegionalStyle s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Style',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${s.name}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AdminProvider>().deleteStyle(s.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  final RegionalStyle style;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StyleTile(
      {required this.style, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              style.imageUrl != null ? Icons.image : Icons.image_outlined,
              color: style.imageUrl != null
                  ? const Color(0xFF7B1FA2)
                  : AppColors.textHint,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.name,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${style.region} · ${style.difficulty} · ${style.stepCount} steps',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                if (style.imageUrl != null)
                  Text(
                    style.imageUrl!,
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

class _StyleEditDialog extends StatefulWidget {
  final RegionalStyle? style;
  final void Function(RegionalStyle) onSave;
  const _StyleEditDialog({this.style, required this.onSave});

  @override
  State<_StyleEditDialog> createState() => _StyleEditDialogState();
}

class _StyleEditDialogState extends State<_StyleEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _region;
  late TextEditingController _description;
  late TextEditingController _imageAsset;
  late TextEditingController _imageUrl;
  late TextEditingController _difficulty;
  late TextEditingController _stepCount;

  @override
  void initState() {
    super.initState();
    final s = widget.style;
    _name = TextEditingController(text: s?.name ?? '');
    _region = TextEditingController(text: s?.region ?? '');
    _description = TextEditingController(text: s?.description ?? '');
    _imageAsset = TextEditingController(text: s?.imageAsset ?? '');
    _imageUrl = TextEditingController(text: s?.imageUrl ?? '');
    _difficulty = TextEditingController(text: s?.difficulty ?? 'Easy');
    _stepCount =
        TextEditingController(text: s?.stepCount.toString() ?? '5');
  }

  @override
  void dispose() {
    for (final c in [
      _name, _region, _description, _imageAsset, _imageUrl,
      _difficulty, _stepCount
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.style;
    final style = RegionalStyle(
      id: existing?.id ??
          'style_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      region: _region.text.trim(),
      description: _description.text.trim(),
      imageAsset: _imageAsset.text.trim(),
      imageUrl:
          _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      difficulty: _difficulty.text.trim(),
      stepCount: int.tryParse(_stepCount.text.trim()) ?? 5,
    );
    widget.onSave(style);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.style == null ? 'Add Style' : 'Edit Style',
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
                _field(_name, 'Style Name', required: true),
                _field(_region, 'Region (e.g. Maharashtra)', required: true),
                _field(_description, 'Description', maxLines: 2),
                _field(_imageUrl,
                    'Image URL (remote – uploaded by admin)'),
                _field(_imageAsset,
                    'Image Asset (local fallback, e.g. saree_1.jpg)'),
                Row(
                  children: [
                    Expanded(
                        child: _field(_difficulty, 'Difficulty',
                            required: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _field(_stepCount, 'Step Count',
                            keyboardType: TextInputType.number)),
                  ],
                ),
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
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1FA2)),
          onPressed: _submit,
          child: const Text('Save',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
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
            borderSide:
                const BorderSide(color: Color(0xFF7B1FA2)),
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
