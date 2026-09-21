import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../design_system/app_button.dart';
import '../main_layout.dart';

/// A "top navigation" menu accessible from any screen so staff can always
/// jump directly to a section (Home / Bookings / Orders / ...) or go back
/// without relying on the system back button.
class AppNavMenuButton extends StatelessWidget {
  final Color? color;
  const AppNavMenuButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: LucideIcons.menu,
      tooltip: 'Menu',
      hasBorder: false,
      color: color,
      onPressed: () => AppNavSheet.show(context),
    );
  }
}

class AppNavSheet {
  static void show(BuildContext screenContext) {
    final isDark = Theme.of(screenContext).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: screenContext,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final navItems = _sections();
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Text(
                    'Sectros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    itemCount: navItems.length,
                    separatorBuilder: (_, _) => const Divider(height: 0),
                    itemBuilder: (_, index) {
                      final item = navItems[index];
                      final isDark = Theme.of(ctx).brightness == Brightness.dark;
                      return InkWell(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          if (item.index != null) {
                            final container = ProviderScope.containerOf(screenContext);
                            container.read(navigationIndexProvider.notifier).state = item.index!;
                          }
                          screenContext.go(item.route);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 19,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.s14),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.pagePadding,
                    right: AppSpacing.pagePadding,
                    bottom: MediaQuery.of(ctx).padding.bottom + AppSpacing.s12,
                  ),
                  child: AppButton(
                    label: 'Back',
                    icon: LucideIcons.arrowLeft,
                    variant: AppButtonVariant.ghost,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      final router = GoRouter.of(screenContext);
                      if (router.canPop()) {
                        router.pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<_NavSection> _sections() {
    return [
      const _NavSection(LucideIcons.home, 'Home', '/dashboard', 0),
      const _NavSection(LucideIcons.calendar, 'Calendar', '/calendar', 1),
      const _NavSection(LucideIcons.bookOpen, 'Bookings', '/reservations', 2),
      const _NavSection(LucideIcons.users, 'Customers', '/customers', 3),
      const _NavSection(LucideIcons.shoppingBag, 'Orders', '/orders', null),
      const _NavSection(LucideIcons.layoutGrid, 'Tables', '/tables', null),
      const _NavSection(LucideIcons.inbox, 'Inbox', '/inbox', null),
      const _NavSection(LucideIcons.walletCards, 'Finance', '/finance', null),
      const _NavSection(LucideIcons.userCog, 'Staff', '/staff', null),
      const _NavSection(LucideIcons.userCircle, 'Profile', '/profile', null),
      const _NavSection(LucideIcons.settings, 'More Settings', '/more', 4),
    ];
  }
}

class _NavSection {
  final IconData icon;
  final String label;
  final String route;
  final int? index;

  const _NavSection(this.icon, this.label, this.route, this.index);
}