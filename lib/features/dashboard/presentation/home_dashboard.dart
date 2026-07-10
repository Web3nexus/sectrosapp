import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_notifier.dart';
import '../../../models/user.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/main_layout.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final user = ref.watch(userProvider);
    final metrics = dashboardState.metrics;
    final isLoading = dashboardState.isLoading;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await ref.read(dashboardProvider.notifier).fetchStats();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Header with greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Welcome!',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.go('/profile');
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.name ?? 'U').substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Stats row — WhatsApp-style status bubbles
            if (isLoading && metrics['total_revenue'] == 0)
              const SkeletonLoader(type: SkeletonType.grid, itemCount: 2)
            else
              _buildStatsRow(context, metrics),
            const SizedBox(height: 28),
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _QuickAction(
                  label: 'New Order',
                  icon: LucideIcons.plusCircle,
                  color: AppColors.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(navigationIndexProvider.notifier).state = 1;
                    context.go('/orders');
                  },
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  label: 'Reservation',
                  icon: LucideIcons.calendarPlus,
                  color: AppColors.secondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(navigationIndexProvider.notifier).state = 3;
                    context.go('/reservations');
                  },
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  label: 'Staff',
                  icon: LucideIcons.users,
                  color: AppColors.accent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(navigationIndexProvider.notifier).state = -1;
                    context.go('/staff');
                  },
                ),
              ],
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildStatsRow(BuildContext context, Map<String, dynamic> metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricBubble(
                value: metrics['total_revenue']?.toDouble() ?? 0,
                label: 'Revenue',
                prefix: '\$',
                icon: LucideIcons.dollarSign,
                color: AppColors.primary,
                gradientColors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricBubble(
                value: metrics['active_reservations']?.toDouble() ?? 0,
                label: 'Bookings',
                icon: LucideIcons.calendar,
                color: AppColors.success,
                gradientColors: [AppColors.success, const Color(0xFF28A745)],
                decimals: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricBubble(
                value: metrics['aov']?.toDouble() ?? 0,
                label: 'Avg Order',
                prefix: '\$',
                icon: LucideIcons.shoppingBag,
                color: AppColors.accent,
                gradientColors: [AppColors.accent, const Color(0xFFE08500)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricBubble(
                value: metrics['net_profit']?.toDouble() ?? 0,
                label: 'Net Profit',
                prefix: '\$',
                icon: LucideIcons.trendingUp,
                color: AppColors.secondary,
                gradientColors: [AppColors.secondary, const Color(0xFF4A48C0)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricBubble extends StatelessWidget {
  final double value;
  final String label;
  final String prefix;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final int decimals;

  const _MetricBubble({
    required this.value,
    required this.label,
    this.prefix = '',
    required this.icon,
    required this.color,
    required this.gradientColors,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCounter(
                  targetValue: value,
                  prefix: prefix,
                  decimals: decimals,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
