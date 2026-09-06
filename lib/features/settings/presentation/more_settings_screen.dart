import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/user.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/app_button.dart';
import '../../notifications/presentation/notifications_notifier.dart';

class MoreSettingsScreen extends ConsumerWidget {
  const MoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final notifState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('More & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.s8, AppSpacing.pagePadding, 100),
        children: [
          // Profile Header Card
          AppCard(
            onTap: () => context.go('/profile'),
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isDark ? AppColors.darkElevated : AppColors.primaryLight,
                  child: Text(
                    (user?.name ?? 'S').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Sectros User',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'operations@sectros.io',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          (user?.role ?? 'Owner').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s20),

          // Operations Section
          _SectionHeader(title: 'Operations', isDark: isDark),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: LucideIcons.layoutGrid,
                  title: 'Floor Plan & Tables',
                  subtitle: 'Manage tables, stations and room availability',
                  onTap: () => context.go('/tables'),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: LucideIcons.shoppingBag,
                  title: 'Orders & POS',
                  subtitle: 'View live table tabs, orders and checkout',
                  onTap: () => context.go('/orders'),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: LucideIcons.users,
                  title: 'Staff Management',
                  subtitle: 'Roster, attendance, shifts and staff messages',
                  onTap: () => context.go('/staff'),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: LucideIcons.dollarSign,
                  title: 'Finance & Cash Book',
                  subtitle: 'Daily settlements, profit margin & revenue',
                  onTap: () => context.go('/finance'),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: LucideIcons.messageSquare,
                  title: 'Inbox & Inquiries',
                  subtitle: 'Guest communications and requests',
                  onTap: () => context.go('/inbox'),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s20),

          // System & Administration Section
          _SectionHeader(title: 'System & Preferences', isDark: isDark),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: LucideIcons.bell,
                  title: 'Notifications',
                  badgeCount: notifState.unreadCount,
                  subtitle: 'Alerts, sound preferences and reminders',
                  onTap: () => context.go('/notifications'),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: LucideIcons.creditCard,
                  title: 'Subscription & Billing',
                  subtitle: 'Manage plan, invoices and SMS credits',
                  onTap: () => context.go('/billing'),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: LucideIcons.shieldCheck,
                  title: 'Security & App Lock',
                  subtitle: 'Biometric unlock and PIN security',
                  onTap: () => context.go('/lock'),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),

          // Logout Button
          AppButton(
            label: 'Sign Out',
            icon: LucideIcons.logOut,
            variant: AppButtonVariant.destructive,
            onPressed: () => _confirmSignOut(context, ref),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Sectros App Version Footer
          Center(
            child: Text(
              'Sectros Hospitality Suite v2.4.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of Sectros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(userProvider.notifier).logout();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final int? badgeCount;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
            ],
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
