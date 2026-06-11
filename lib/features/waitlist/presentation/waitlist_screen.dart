import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'waitlist_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../models/waitlist_entry.dart';

class WaitlistScreen extends ConsumerWidget {
  const WaitlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waitlistProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Waitlist', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(waitlistProvider.notifier).fetch()),
        ],
      ),
      body: _buildBody(context, state, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Add Guest'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WaitlistState state, WidgetRef ref) {
    if (state.isLoading && state.list.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.card, itemCount: 5);
    }
    if (state.error != null && state.list.isEmpty) {
      return ErrorView(message: state.error!, onRetry: () => ref.read(waitlistProvider.notifier).fetch());
    }
    if (state.list.isEmpty) {
      return const EmptyState(icon: LucideIcons.users, title: 'Waitlist empty',
        subtitle: 'No guests waiting right now');
    }

    final waiting = state.list.where((e) => e.status == 'waiting').toList();
    final seated = state.list.where((e) => e.status == 'seated').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        if (waiting.isNotEmpty) _SectionHeader(title: 'Waiting (${waiting.length})'),
        ...waiting.asMap().entries.map((e) => AnimatedListItem(
          index: e.key,
          child: _WaitlistTile(entry: e.value, ref: ref),
        )),
        if (seated.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(title: 'Seated (${seated.length})'),
          ...seated.map((e) => _WaitlistTile(entry: e, ref: ref, isSeated: true)),
        ],
      ],
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final partyCtrl = TextEditingController(text: '2');
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
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
            Text('Add to Waitlist', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(
              labelText: 'Guest Name', prefixIcon: Icon(LucideIcons.user, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
            )),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(
              labelText: 'Phone', prefixIcon: Icon(LucideIcons.phone, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
            )),
            const SizedBox(height: 12),
            TextField(controller: partyCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Party Size', prefixIcon: Icon(LucideIcons.users, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              )),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes', prefixIcon: Icon(LucideIcons.fileText, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              )),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final data = <String, dynamic>{
                  'guest_name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'party_size': int.tryParse(partyCtrl.text) ?? 2,
                  'notes': notesCtrl.text.trim(),
                };
                ref.read(waitlistProvider.notifier).add(data);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Add Guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mutedForeground,
        letterSpacing: 0.5,
      )),
    );
  }
}

class _WaitlistTile extends StatelessWidget {
  final WaitlistEntry entry;
  final WidgetRef ref;
  final bool isSeated;

  const _WaitlistTile({required this.entry, required this.ref, this.isSeated = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSeated ? AppColors.success : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: isSeated ? 0.2 : 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Icon(LucideIcons.user, size: 24, color: color)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.guestName, style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.foreground)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.users, size: 12, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text('${entry.partySize}', style: TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSeated ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(isSeated ? 'Seated' : 'Waiting',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: isSeated ? AppColors.success : AppColors.accent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isSeated)
              PopupMenuButton<String>(
                onSelected: (action) {
                  final notifier = ref.read(waitlistProvider.notifier);
                  if (action == 'seat') _showSeatDialog(context, ref);
                  if (action == 'notify') notifier.notify(entry.id);
                  if (action == 'cancel') notifier.cancel(entry.id);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'seat', child: ListTile(
                    leading: Icon(LucideIcons.checkCircle, size: 20), title: Text('Seat'),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  PopupMenuItem(value: 'notify', child: ListTile(
                    leading: Icon(LucideIcons.bell, size: 20), title: Text('Notify'),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  PopupMenuItem(value: 'cancel', child: ListTile(
                    leading: Icon(LucideIcons.xCircle, size: 20, color: AppColors.destructive),
                    title: Text('Cancel', style: TextStyle(color: AppColors.destructive)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showSeatDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seat Guest'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Table ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final tableId = int.tryParse(ctrl.text);
            if (tableId != null) {
              ref.read(waitlistProvider.notifier).seat(entry.id, tableId);
            }
            Navigator.pop(ctx);
          }, child: const Text('Seat')),
        ],
      ),
    );
  }
}
