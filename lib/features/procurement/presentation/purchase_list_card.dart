import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/shopping_item.dart';
import 'purchase_list_notifier.dart';

class PurchaseListCard extends ConsumerWidget {
  const PurchaseListCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.shoppingCart, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shopping List',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        )),
                      Text(
                        '${state.pending.length} pending · ${state.purchased.length} done',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.refreshCw, size: 16, color: AppColors.textMuted),
                  onPressed: () => ref.read(purchaseListProvider.notifier).fetch(),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  icon: Icon(LucideIcons.plusCircle, size: 20, color: AppColors.primary),
                  onPressed: () => _showAddSheet(context, ref),
                  tooltip: 'Add item',
                ),
              ],
            ),
          ),

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(state.error!,
                style: TextStyle(color: AppColors.error, fontSize: 13)),
            )
          else if (state.items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  Icon(LucideIcons.clipboardList, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text('No items yet. Tap + to add.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            )
          else ...[
            // Pending items
            ...state.pending.map((item) => _ShoppingTile(item: item)),
            // Purchased items (collapsed under divider)
            if (state.purchased.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Purchased (${state.purchased.length})',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.3))),
                  ],
                ),
              ),
              ...state.purchased.map((item) => _ShoppingTile(item: item)),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(ref: ref),
    );
  }
}

class _ShoppingTile extends ConsumerWidget {
  final ShoppingItem item;
  const _ShoppingTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        ref.read(purchaseListProvider.notifier).deleteItem(item.id);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(purchaseListProvider.notifier).toggle(item.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.isPurchased ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: item.isPurchased ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.isPurchased
                    ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.isPurchased
                            ? AppColors.textMuted
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (item.notes != null || item.unit != null || item.quantity != null)
                      Text(
                        [
                          if (item.quantity != null && item.unit != null)
                            '${item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1)} ${item.unit}',
                          if (item.notes != null) item.notes!,
                        ].join(' · '),
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              Icon(LucideIcons.gripVertical, size: 14, color: AppColors.border),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddItemSheet({required this.ref});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _unitCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final ok = await widget.ref.read(purchaseListProvider.notifier).addItem(
      name,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
      quantity: double.tryParse(_qtyCtrl.text.trim()),
    );
    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Add Shopping Item',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              )),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Item name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(LucideIcons.shoppingBasket, size: 18),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: InputDecoration(
                      labelText: 'Unit (kg, pcs…)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Add Item', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
