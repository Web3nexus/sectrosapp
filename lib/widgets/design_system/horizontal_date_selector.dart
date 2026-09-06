import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class HorizontalDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysCount;
  final DateTime? startDate;

  const HorizontalDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysCount = 14,
    this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseDate = startDate ?? DateTime.now();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        itemCount: daysCount,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
        itemBuilder: (context, index) {
          final date = baseDate.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          final dayName = DateFormat('EEE').format(date);
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 54,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
                    : (isDark ? AppColors.darkSurface : AppColors.surface),
                borderRadius: AppRadius.mdBorderRadius,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimaryTeal : AppColors.primary)
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: 1,
                ),
                boxShadow: isSelected ? AppShadows.card : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDark ? AppColors.darkBackground : AppColors.white)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? (isDark ? AppColors.darkBackground : AppColors.white)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
