import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'shift_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../models/shift.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shiftProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Shifts', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${state.list.length}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(shiftProvider.notifier).fetch()),
        ],
      ),
      body: _buildBody(context, state, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showShiftSheet(context, ref, null),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Add Shift'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ShiftState state, WidgetRef ref) {
    if (state.isLoading && state.list.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.card, itemCount: 5);
    }
    if (state.error != null && state.list.isEmpty) {
      return ErrorView(message: state.error!,
        onRetry: () => ref.read(shiftProvider.notifier).fetch());
    }
    if (state.list.isEmpty) {
      return const EmptyState(icon: LucideIcons.clock, title: 'No shifts',
        subtitle: 'Create your first shift schedule');
    }

    final sorted = ref.read(shiftProvider.notifier).sorted;
    final grouped = <String, List<Shift>>{};
    for (final shift in sorted) {
      grouped.putIfAbsent(shift.dayOfWeek, () => []).add(shift);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(entry.key, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mutedForeground,
                letterSpacing: 0.5,
              )),
            ),
            ...entry.value.asMap().entries.map((e) => AnimatedListItem(
              index: e.key,
              child: _ShiftTile(
                shift: e.value,
                ref: ref,
                onEdit: () => showShiftSheet(context, ref, e.value),
              ),
            )),
          ],
        );
      }).toList(),
    );
  }

void showShiftSheet(BuildContext context, WidgetRef ref, Shift? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final startCtrl = TextEditingController(text: existing?.startTime ?? '09:00');
    final endCtrl = TextEditingController(text: existing?.endTime ?? '17:00');
    String day = existing?.dayOfWeek ?? 'Monday';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppColors.mutedForeground.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 20),
              Text(existing != null ? 'Edit Shift' : 'New Shift', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.foreground)),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(
                labelText: 'Shift Name', prefixIcon: Icon(LucideIcons.tag, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              )),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(
                labelText: 'Description', prefixIcon: Icon(LucideIcons.fileText, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              )),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: day,
                decoration: const InputDecoration(
                  labelText: 'Day of Week', prefixIcon: Icon(LucideIcons.calendar, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                ),
                items: const [
                  'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
                ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) { if (v != null) { setSheetState(() => day = v); } },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: startCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Start', prefixIcon: Icon(LucideIcons.sunrise, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                    ))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: endCtrl,
                    decoration: const InputDecoration(
                      labelText: 'End', prefixIcon: Icon(LucideIcons.sunset, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                    ))),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () {
                  ref.read(shiftProvider.notifier).save({
                    'name': nameCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'day_of_week': day,
                    'start_time': startCtrl.text.trim(),
                    'end_time': endCtrl.text.trim(),
                  }, id: existing?.id);
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(existing != null ? 'Save Changes' : 'Create Shift',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final Shift shift;
  final WidgetRef ref;
  final VoidCallback onEdit;
  const _ShiftTile({required this.shift, required this.ref, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(LucideIcons.clock, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shift.name, style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.foreground)),
                  if (shift.description != null && shift.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(shift.description!, style: TextStyle(
                      fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.sunrise, size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(shift.startTime, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.sunset, size: 12, color: AppColors.destructive),
                      const SizedBox(width: 4),
                      Text(shift.endTime, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.destructive)),
                      if (shift.staffCount != null) ...[
                        const SizedBox(width: 12),
                        Icon(LucideIcons.users, size: 12, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text('${shift.staffCount}', style: TextStyle(
                          fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') {
                  onEdit();
                }
                if (action == 'delete') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Shift?'),
                      content: Text('Remove "${shift.name}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        FilledButton(onPressed: () {
                          ref.read(shiftProvider.notifier).delete(shift.id);
                          Navigator.pop(ctx);
                        }, child: const Text('Delete',
                          style: TextStyle(color: AppColors.destructive))),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: ListTile(
                  leading: Icon(LucideIcons.pencil, size: 20), title: Text('Edit'),
                  dense: true, contentPadding: EdgeInsets.zero)),
                PopupMenuItem(value: 'delete', child: ListTile(
                  leading: Icon(LucideIcons.trash, size: 20, color: AppColors.destructive),
                  title: Text('Delete', style: TextStyle(color: AppColors.destructive)),
                  dense: true, contentPadding: EdgeInsets.zero)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
