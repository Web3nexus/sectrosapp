import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../models/staff_message.dart';
import 'staff_messages_notifier.dart';

class StaffMessagesScreen extends ConsumerWidget {
  const StaffMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffMessagesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: SkeletonLoader(type: SkeletonType.card))
              : state.error != null
                  ? ErrorView(message: state.error!, onRetry: () => ref.read(staffMessagesProvider.notifier).fetch())
                  : state.messages.isEmpty
                      ? const EmptyState(icon: LucideIcons.inbox, title: 'No messages yet', subtitle: 'Messages from your manager will appear here')
                  : RefreshIndicator(
                      onRefresh: () => ref.read(staffMessagesProvider.notifier).fetch(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          return _MessageTile(
                            message: msg,
                            theme: theme,
                            onTap: () => _showMessage(context, msg, ref),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showMessage(BuildContext context, StaffMessage message, WidgetRef ref) {
    if (!message.read) {
      ref.read(staffMessagesProvider.notifier).markRead(message.id);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MessageDetail(message: message),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final StaffMessage message;
  final ThemeData theme;
  final VoidCallback onTap;

  const _MessageTile({required this.message, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: !message.read ? Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 1.5) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(LucideIcons.mail, color: theme.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.subject,
                          style: TextStyle(
                            fontWeight: message.read ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!message.read)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.destructive, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.body,
                    style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.user, size: 12, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(message.from, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      const Spacer(),
                      Text(_formatTime(message.createdAt), style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
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

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }
}

class _MessageDetail extends StatelessWidget {
  final StaffMessage message;
  const _MessageDetail({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.mutedForeground.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.user, size: 16, color: AppColors.mutedForeground),
                    const SizedBox(width: 6),
                    Text(message.from, style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(message.subject, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text(message.body, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
