import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../features/notifications/presentation/notifications_notifier.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final notifState = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      _NavItem(icon: LucideIcons.home, label: 'Home', route: '/dashboard'),
      _NavItem(icon: LucideIcons.calendar, label: 'Calendar', route: '/calendar'),
      _NavItem(icon: LucideIcons.bookOpen, label: 'Bookings', route: '/reservations'),
      _NavItem(icon: LucideIcons.users, label: 'Customers', route: '/customers'),
      _NavItem(
        icon: LucideIcons.menu,
        label: 'More',
        route: '/more',
        badge: notifState.unreadCount,
      ),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isActive = currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      ref.read(navigationIndexProvider.notifier).state = index;
                      context.go(item.route);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive
                                  ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                            ),
                            if (item.badge != null && item.badge! > 0)
                              Positioned(
                                right: -8,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: Text(
                                    item.badge! > 9 ? '9+' : '${item.badge}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });
}
