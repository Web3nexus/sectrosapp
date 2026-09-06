import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/reservation.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/horizontal_date_selector.dart';
import '../../../widgets/design_system/reservation_card.dart';
import '../../reservations/presentation/reservation_notifier.dart';
import '../../reservations/presentation/create_booking_sheet.dart';
import '../../reservations/presentation/reservation_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedViewMode = 0; // 0: Day, 1: Week

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resState = ref.watch(reservationsProvider);
    final allReservations = resState.reservations;

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final monthYearStr = DateFormat('MMMM yyyy').format(_selectedDate);

    // Filter for current selected date
    final dayReservations = allReservations.where((r) {
      return r.date.startsWith(selectedDateStr);
    }).toList();

    final totalGuestsForDay = dayReservations.fold<int>(0, (sum, r) => sum + r.guests);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(monthYearStr),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarPlus, size: 20),
            tooltip: 'Add Booking',
            onPressed: () {
              HapticFeedback.lightImpact();
              CreateBookingSheet.show(context);
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s8),

          // Horizontal Date Selector (scrollable days)
          HorizontalDateSelector(
            selectedDate: _selectedDate,
            daysCount: 28,
            startDate: DateTime.now().subtract(const Duration(days: 3)),
            onDateSelected: (date) {
              HapticFeedback.selectionClick();
              setState(() => _selectedDate = date);
            },
          ),

          const SizedBox(height: AppSpacing.s12),

          // View Mode Selector (Day / Week)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Row(
              children: [
                _ViewModeToggle(
                  label: 'Day View',
                  isSelected: _selectedViewMode == 0,
                  onTap: () => setState(() => _selectedViewMode = 0),
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.s8),
                _ViewModeToggle(
                  label: 'Week View',
                  isSelected: _selectedViewMode == 1,
                  onTap: () => setState(() => _selectedViewMode = 1),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s12),

          // Day summary mini card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: AppSpacing.s10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 16,
                        color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        DateFormat('EEE, MMM d').format(_selectedDate),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${dayReservations.length} Bookings',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.divider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalGuestsForDay Guests',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s12),

          // Main View Content
          Expanded(
            child: _selectedViewMode == 0
                ? _buildDayView(dayReservations, isDark)
                : _buildWeekView(allReservations, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(List<Reservation> reservations, bool isDark) {
    if (reservations.isEmpty) {
      return Center(
        child: EmptyState(
          icon: LucideIcons.calendar,
          title: 'No bookings for this date',
          subtitle: 'No reservations are scheduled for this day',
          actionLabel: 'Add Booking',
          onAction: () => CreateBookingSheet.show(context),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 100),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final res = reservations[index];
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
      },
    );
  }

  Widget _buildWeekView(List<Reservation> allReservations, bool isDark) {
    // Generate the 7 days of the selected week starting from Monday
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 100),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = startOfWeek.add(Duration(days: index));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final isSelected = DateUtils.isSameDay(date, _selectedDate);

        final reservationsForDate = allReservations.where((r) => r.date.startsWith(dateKey)).toList();
        final guestCount = reservationsForDate.fold<int>(0, (sum, r) => sum + r.guests);

        return AppCard(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedDate = date;
              _selectedViewMode = 0; // Switch to day view on tap
            });
          },
          padding: const EdgeInsets.all(AppSpacing.s14),
          backgroundColor: isSelected
              ? (isDark ? AppColors.darkElevated : AppColors.primaryLight.withValues(alpha: 0.3))
              : null,
          child: Row(
            children: [
              // Date Box
              Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
                      : (isDark ? AppColors.darkSurface : AppColors.secondaryBackground),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              // Day details & bookings bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(date),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${reservationsForDate.length} Bookings',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: reservationsForDate.isNotEmpty
                                ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      reservationsForDate.isEmpty
                          ? 'No bookings scheduled'
                          : '$guestCount total expected guests',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ViewModeToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
          : (isDark ? AppColors.darkSurface : AppColors.surface),
      borderRadius: BorderRadius.circular(AppRadius.full),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isSelected
              ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
              : (isDark ? AppColors.darkBorder : AppColors.border),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: AppSpacing.s6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.darkBackground : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
