import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/user.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/metric_card.dart';
import '../../../widgets/design_system/reservation_card.dart';
import '../../../widgets/design_system/app_button.dart';
import '../../../widgets/main_layout.dart';
import '../presentation/dashboard_notifier.dart';
import '../../reservations/presentation/reservation_notifier.dart';
import '../../reservations/presentation/create_booking_sheet.dart';
import '../../reservations/presentation/reservation_detail_screen.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final user = ref.watch(userProvider);
    final reservationState = ref.watch(reservationsProvider);
    final metrics = dashboardState.metrics;
    final isLoading = dashboardState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final todayDisplay = DateFormat('EEEE, MMM d').format(today);

    // Filter today's reservations
    final todayReservations = reservationState.reservations.where((res) {
      return res.date.startsWith(todayStr);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.wait([
              ref.read(dashboardProvider.notifier).fetchStats(),
              ref.read(reservationsProvider.notifier).fetchReservations(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s16),

                // Top Bar: Property Brand & Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.name ?? 'Sectros Hospitality',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                        radius: 20,
                        backgroundColor: isDark ? AppColors.darkElevated : AppColors.primaryLight,
                        child: Text(
                          (user?.name ?? 'S').substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s16),

                // Dark Navy Contextual Property Header Card
                AppNavyCard(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Text(
                                todayDisplay.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.navyCardTextMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${todayReservations.length} today',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Hospitality Operations',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Overview & Availability',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: _NavyStatItem(
                              label: 'Today Bookings',
                              value: '${todayReservations.length}',
                              icon: LucideIcons.calendar,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          Expanded(
                            child: _NavyStatItem(
                              label: 'Active Guests',
                              value: '${todayReservations.fold<int>(0, (sum, r) => sum + r.guests)}',
                              icon: LucideIcons.users,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s20),

                // Metrics Grid (2x2)
                if (isLoading && metrics['total_revenue'] == 0)
                  const SkeletonLoader(type: SkeletonType.grid, itemCount: 4)
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Revenue',
                              value: '\$${(metrics['total_revenue']?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                              trend: '+12.5%',
                              isPositiveTrend: true,
                              icon: LucideIcons.dollarSign,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: MetricCard(
                              title: 'Bookings',
                              value: '${metrics['active_reservations'] ?? reservationState.reservations.length}',
                              subtitle: 'Active total',
                              icon: LucideIcons.bookOpen,
                              onTap: () {
                                ref.read(navigationIndexProvider.notifier).state = 2;
                                context.go('/reservations');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Avg Order',
                              value: '\$${(metrics['aov']?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                              subtitle: 'Per table',
                              icon: LucideIcons.shoppingBag,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: MetricCard(
                              title: 'Net Profit',
                              value: '\$${(metrics['net_profit']?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                              trend: '+8.2%',
                              isPositiveTrend: true,
                              icon: LucideIcons.trendingUp,
                              onTap: () => context.go('/finance'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: AppSpacing.s24),

                // Quick Action Bar
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'New Booking',
                        icon: LucideIcons.calendarPlus,
                        size: AppButtonSize.md,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          CreateBookingSheet.show(context);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    AppIconButton(
                      icon: LucideIcons.layoutGrid,
                      tooltip: 'Floor Plan',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go('/tables');
                      },
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    AppIconButton(
                      icon: LucideIcons.userPlus,
                      tooltip: 'Customers',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(navigationIndexProvider.notifier).state = 3;
                        context.go('/customers');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s28),

                // Today's Reservations Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Reservations",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(navigationIndexProvider.notifier).state = 2;
                        context.go('/reservations');
                      },
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 14,
                              color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s12),

                // Today's Reservation List
                if (reservationState.isLoading && reservationState.reservations.isEmpty)
                  const SkeletonLoader(type: SkeletonType.reservation, itemCount: 3)
                else if (todayReservations.isEmpty && reservationState.reservations.isEmpty)
                  const EmptyState(
                    icon: LucideIcons.calendarCheck,
                    title: 'No bookings today',
                    subtitle: 'Create a new reservation to get started',
                  )
                else ...[
                  // Show today's or fallback to latest upcoming
                  ...((todayReservations.isNotEmpty ? todayReservations : reservationState.reservations.take(4))
                      .map((res) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                      child: ReservationCard(
                        reservation: res,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReservationDetailScreen(reservation: res),
                            ),
                          );
                        },
                      ),
                    );
                  })),
                ],

                const SizedBox(height: AppSpacing.s32),
              ],
            ),
          ),
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
}

class _NavyStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _NavyStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.navyCardTextMuted),
        const SizedBox(width: AppSpacing.s8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.navyCardTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
