import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class TimeSlotChips extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;
  final List<String>? unavailableSlots;

  const TimeSlotChips({
    super.key,
    required this.timeSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.unavailableSlots,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unavailable = unavailableSlots ?? [];

    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: timeSlots.map((slot) {
        final isSelected = slot == selectedSlot;
        final isUnavailable = unavailable.contains(slot);

        Color bg;
        Color fg;
        BorderSide borderSide;

        if (isSelected) {
          bg = isDark ? AppColors.darkPrimaryTeal : AppColors.primary;
          fg = isDark ? AppColors.darkBackground : AppColors.white;
          borderSide = BorderSide.none;
        } else if (isUnavailable) {
          bg = isDark ? AppColors.darkElevated : AppColors.secondaryBackground;
          fg = AppColors.textMuted;
          borderSide = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider);
        } else {
          bg = isDark ? AppColors.darkSurface : AppColors.surface;
          fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
          borderSide = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border);
        }

        return Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: borderSide,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isUnavailable ? null : () => onSlotSelected(slot),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
              child: Text(
                slot,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                  decoration: isUnavailable ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
