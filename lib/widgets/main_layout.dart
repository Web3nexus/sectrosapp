    import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../models/user.dart';
import '../core/theme/app_colors.dart';
import '../features/notifications/presentation/notifications_notifier.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final user = ref.watch(userProvider);
    final notifState = ref.watch(notificationsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    List<NavItem> navItems = [
      NavItem(icon: LucideIcons.home, label: 'Home', index: 0, route: '/dashboard'),
      NavItem(icon: LucideIcons.clipboardList, label: 'Orders', index: 1, route: '/orders'),
      NavItem(icon: LucideIcons.layoutGrid, label: 'Tables', index: 2, route: '/tables'),
      NavItem(icon: LucideIcons.calendar, label: 'Bookings', index: 3, route: '/reservations'),
      NavItem(icon: LucideIcons.bell, label: 'Alerts', index: 4, route: '/notifications', badge: notifState.unreadCount),
      NavItem(icon: LucideIcons.user, label: 'Profile', index: 5, route: '/profile'),
    ];

    if (user != null) {
      if (user.isOwner) {
        // 6 items max — keep nav clean and uncluttered
        navItems = [
          NavItem(icon: LucideIcons.home, label: 'Home', index: 0, route: '/dashboard'),
          NavItem(icon: LucideIcons.wallet, label: 'Finance', index: 8, route: '/finance'),
          NavItem(icon: LucideIcons.clipboardList, label: 'Orders', index: 1, route: '/orders'),
          NavItem(icon: LucideIcons.calendar, label: 'Bookings', index: 3, route: '/reservations'),
          NavItem(icon: LucideIcons.bell, label: 'Alerts', index: 4, route: '/notifications', badge: notifState.unreadCount),
          NavItem(icon: LucideIcons.user, label: 'Profile', index: 5, route: '/profile'),
        ];
      } else if (user.isStaff) {
        navItems = [
          NavItem(icon: LucideIcons.home, label: 'Home', index: 0, route: '/dashboard'),
          NavItem(icon: LucideIcons.mail, label: 'Messages', index: 7, route: '/staff-messages'),
          NavItem(icon: LucideIcons.clipboardList, label: 'Orders', index: 1, route: '/orders'),
          NavItem(icon: LucideIcons.layoutGrid, label: 'Tables', index: 2, route: '/tables'),
          NavItem(icon: LucideIcons.bell, label: 'Alerts', index: 4, route: '/notifications', badge: notifState.unreadCount),
          NavItem(icon: LucideIcons.user, label: 'Profile', index: 5, route: '/profile'),
        ];
      }
      if (user.role == 'chef') {
        navItems = [
          NavItem(icon: LucideIcons.home, label: 'Home', index: 0, route: '/dashboard'),
          NavItem(icon: LucideIcons.utensils, label: 'Kitchen', index: 1, route: '/orders'),
          NavItem(icon: LucideIcons.user, label: 'Profile', index: 4, route: '/profile'),
        ];
      }
    }

    // Nav bar total height: 70px height + 20px bottom margin + system bottom padding
    final navTotalHeight = 70.0 + 20.0 + bottomPad;

    return Scaffold(
      body: Stack(
        children: [
          // Padding pushes screen content above the floating nav bar
          Padding(
            padding: EdgeInsets.only(bottom: navTotalHeight),
            child: child,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _FloatingBottomNav(
              currentIndex: currentIndex,
              items: navItems,
              bottomPad: bottomPad,
              onTap: (index) {
                final item = navItems.firstWhere((i) => i.index == index);
                ref.read(navigationIndexProvider.notifier).state = index;
                context.go(item.route);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final int index;
  final String route;
  final int? badge;
  NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.route,
    this.badge,
  });
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final ValueChanged<int> onTap;
  final double bottomPad;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 16 + bottomPad, left: 20, right: 20),
      height: 68,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkCard : AppColors.card).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) => _NavIcon(
              icon: item.icon,
              label: item.label,
              isActive: currentIndex == item.index,
              badge: item.badge,
              onTap: () => onTap(item.index),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? theme.primaryColor : AppColors.mutedForeground,
                  size: 22,
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.destructive,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        badge! > 9 ? '9+' : '$badge',
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
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? theme.primaryColor : AppColors.mutedForeground,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
