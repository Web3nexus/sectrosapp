import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'reservation_notifier.dart';
import '../../../models/reservation.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../core/theme/app_colors.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resState = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservations',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarPlus, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, resState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ReservationsState state) {
    if (state.isLoading && state.reservations.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.listTile, itemCount: 6);
    }
    if (state.error != null && state.reservations.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(reservationsProvider.notifier).fetchReservations(),
      );
    }
    if (state.reservations.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.calendarCheck,
        title: 'No reservations',
        subtitle: 'New bookings will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: state.reservations.length,
      itemBuilder: (context, index) {
        final res = state.reservations[index];
        return AnimatedListItem(
          index: index,
          child: _ReservationTimelineTile(
            reservation: res,
            isFirst: index == 0,
            isLast: index == state.reservations.length - 1,
          ),
        );
      },
    );
  }
}

class _ReservationTimelineTile extends StatelessWidget {
  final Reservation reservation;
  final bool isFirst;
  final bool isLast;

  const _ReservationTimelineTile({
    required this.reservation,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    IconData statusIcon;
    switch (reservation.status) {
      case 'confirmed':
        statusColor = AppColors.success;
        statusIcon = LucideIcons.checkCircle;
        break;
      case 'arrived':
        statusColor = AppColors.primary;
        statusIcon = LucideIcons.userCheck;
        break;
      case 'cancelled':
        statusColor = AppColors.destructive;
        statusIcon = LucideIcons.xCircle;
        break;
      default:
        statusColor = AppColors.accent;
        statusIcon = LucideIcons.clock;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline bar
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  )
                else
                  const Spacer(),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(LucideIcons.clock, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text(
                              reservation.time.length >= 5
                                  ? reservation.time.substring(0, 5)
                                  : reservation.time,
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                            const SizedBox(width: 12),
                            Icon(LucideIcons.users, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text(
                              '${reservation.guests}',
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reservation.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
