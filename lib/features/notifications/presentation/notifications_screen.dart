import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/notification.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/design_system/app_card.dart';
import 'notifications_notifier.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (state.unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${state.unreadCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(notificationsProvider.notifier).markAllRead();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(notificationsProvider.notifier).fetch();
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: _buildBody(context, state, ref, isDark),
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state, WidgetRef ref, bool isDark) {
    if (state.isLoading && state.list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding),
        child: SkeletonLoader(type: SkeletonType.listTile, itemCount: 6),
      );
    }
    if (state.error != null && state.list.isEmpty) {
      return Center(
        child: ErrorView(
          message: state.error!,
          onRetry: () => ref.read(notificationsProvider.notifier).fetch(),
        ),
      );
    }
    if (state.list.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: LucideIcons.bell,
          title: 'No notifications',
          subtitle: 'You are completely caught up!',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.s8, AppSpacing.pagePadding, 100),
      itemCount: state.list.length,
      itemBuilder: (context, index) {
        final notif = state.list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: _NotificationCard(
            notification: notif,
            isDark: isDark,
            onTap: () {
              if (notif.isUnread) {
                ref.read(notificationsProvider.notifier).markRead(notif.id);
              }
            },
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  IconData _icon() {
    switch ((notification.type ?? '').toLowerCase()) {
      case 'order':
        return LucideIcons.shoppingBag;
      case 'reservation':
        return LucideIcons.calendar;
      case 'error':
        return LucideIcons.alertCircle;
      default:
        return LucideIcons.bell;
    }
  }

  Color _color() {
    switch ((notification.type ?? '').toLowerCase()) {
      case 'error':
        return AppColors.error;
      case 'reservation':
        return AppColors.success;
      case 'order':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final isUnread = notification.isUnread;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s14),
      backgroundColor: isUnread
          ? (isDark ? AppColors.darkElevated : AppColors.primaryLight.withValues(alpha: 0.25))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Icon(_icon(), size: 18, color: color),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _timeAgo(notification.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return '';
    }
  }
}
