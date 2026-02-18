import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/credit_model.dart';
import '../../providers/admin_provider.dart';

class AdminCreditsScreen extends StatefulWidget {
  const AdminCreditsScreen({super.key});

  @override
  State<AdminCreditsScreen> createState() => _AdminCreditsScreenState();
}

class _AdminCreditsScreenState extends State<AdminCreditsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCreditConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Add Pack'),
        onPressed: () => _openPackDialog(context, null),
      ),
      body: admin.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cost Config Section
                  _sectionTitle('Feature Costs'),
                  const SizedBox(height: 10),
                  _CostConfigCard(
                    aiDraping: admin.aiDrapingCost,
                    stylishLook: admin.stylishLookCost,
                    onSave: (ai, sl) async {
                      final ok = await admin.saveCreditConfig(
                          aiDraping: ai, stylishLook: sl);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                ok ? 'Saved!' : admin.errorMessage ?? 'Error'),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Credit Packs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('Credit Packs'),
                      if (admin.isSaving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.gold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (admin.creditPacks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No credit packs yet',
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    ...admin.creditPacks.map(
                      (pack) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PackTile(
                          pack: pack,
                          onEdit: () => _openPackDialog(context, pack),
                          onDelete: () =>
                              _confirmDeletePack(context, pack),
                        ),
                      ),
                    ),

                  if (admin.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(admin.errorMessage!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      );

  void _openPackDialog(BuildContext context, CreditPack? existing) {
    showDialog(
      context: context,
      builder: (_) => _PackEditDialog(
        pack: existing,
        onSave: (pack) async {
          final ok = await context.read<AdminProvider>().saveCreditPack(pack);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok ? 'Saved!' : 'Error saving pack'),
                backgroundColor:
                    ok ? AppColors.success : AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDeletePack(BuildContext context, CreditPack pack) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Pack',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${pack.name}" pack?',
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
              await context.read<AdminProvider>().deleteCreditPack(pack.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────

class _CostConfigCard extends StatefulWidget {
  final int aiDraping;
  final int stylishLook;
  final void Function(int ai, int sl) onSave;

  const _CostConfigCard({
    required this.aiDraping,
    required this.stylishLook,
    required this.onSave,
  });

  @override
  State<_CostConfigCard> createState() => _CostConfigCardState();
}

class _CostConfigCardState extends State<_CostConfigCard> {
  late TextEditingController _ai;
  late TextEditingController _sl;

  @override
  void initState() {
    super.initState();
    _ai = TextEditingController(text: widget.aiDraping.toString());
    _sl = TextEditingController(text: widget.stylishLook.toString());
  }

  @override
  void didUpdateWidget(_CostConfigCard old) {
    super.didUpdateWidget(old);
    if (old.aiDraping != widget.aiDraping) {
      _ai.text = widget.aiDraping.toString();
    }
    if (old.stylishLook != widget.stylishLook) {
      _sl.text = widget.stylishLook.toString();
    }
  }

  @override
  void dispose() {
    _ai.dispose();
    _sl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _costField(_ai, 'AI Draping Cost (credits)'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _costField(_sl, 'Stylish Look Cost (credits)'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final ai = int.tryParse(_ai.text.trim());
                final sl = int.tryParse(_sl.text.trim());
                if (ai != null && sl != null) {
                  widget.onSave(ai, sl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Enter valid numbers'),
                        backgroundColor: AppColors.error),
                  );
                }
              },
              child: const Text('Save Costs',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12),
        filled: true,
        fillColor: AppColors.secondaryLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.gold)),
        suffixText: 'cr',
        suffixStyle:
            const TextStyle(color: AppColors.gold, fontSize: 12),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────

class _PackTile extends StatelessWidget {
  final CreditPack pack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PackTile(
      {required this.pack, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pack.isBestValue
              ? AppColors.gold.withOpacity(0.5)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.diamond_outlined,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pack.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                    if (pack.isBestValue) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('BEST VALUE',
                            style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]
                  ],
                ),
                Text(
                  '${pack.credits} credits · ₹${pack.priceInRupees}'
                  '${pack.bonus.isNotEmpty ? ' · ${pack.bonus}' : ''}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.gold, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────

class _PackEditDialog extends StatefulWidget {
  final CreditPack? pack;
  final void Function(CreditPack) onSave;
  const _PackEditDialog({this.pack, required this.onSave});

  @override
  State<_PackEditDialog> createState() => _PackEditDialogState();
}

class _PackEditDialogState extends State<_PackEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _credits;
  late TextEditingController _priceInPaise;
  late TextEditingController _bonus;
  late TextEditingController _sortOrder;
  bool _isBestValue = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pack;
    _name = TextEditingController(text: p?.name ?? '');
    _credits = TextEditingController(text: p?.credits.toString() ?? '');
    _priceInPaise =
        TextEditingController(text: p?.priceInPaise.toString() ?? '');
    _bonus = TextEditingController(text: p?.bonus ?? '');
    _sortOrder =
        TextEditingController(text: p?.sortOrder.toString() ?? '0');
    _isBestValue = p?.isBestValue ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _credits, _priceInPaise, _bonus, _sortOrder]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.pack;
    final pack = CreditPack(
      id: existing?.id ??
          'pack_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      credits: int.tryParse(_credits.text.trim()) ?? 0,
      priceInPaise: int.tryParse(_priceInPaise.text.trim()) ?? 0,
      bonus: _bonus.text.trim(),
      isBestValue: _isBestValue,
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
    );
    widget.onSave(pack);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.pack == null ? 'Add Credit Pack' : 'Edit Credit Pack',
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_name, 'Pack Name', required: true),
                Row(
                  children: [
                    Expanded(
                        child: _field(_credits, 'Credits',
                            keyboardType: TextInputType.number,
                            required: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _field(_priceInPaise, 'Price (in paise)',
                            keyboardType: TextInputType.number,
                            required: true,
                            hint: '₹99 → 9900')),
                  ],
                ),
                _field(_bonus, 'Bonus Label (e.g. +5 Bonus)'),
                _field(_sortOrder, 'Sort Order',
                    keyboardType: TextInputType.number),
                Row(
                  children: [
                    Checkbox(
                      value: _isBestValue,
                      onChanged: (v) =>
                          setState(() => _isBestValue = v ?? false),
                      activeColor: AppColors.gold,
                    ),
                    const Text('Best Value',
                        style: TextStyle(color: AppColors.textPrimary)),
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
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          onPressed: _submit,
          child: const Text('Save',
              style: TextStyle(
                  color: AppColors.background,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textHint, fontSize: 12),
          labelStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: AppColors.secondaryLight,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.divider)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold)),
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
