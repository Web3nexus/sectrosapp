import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class GuestStepper extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String label;

  const GuestStepper({
    super.key,
    required this.count,
    required this.onChanged,
    this.min = 1,
    this.max = 30,
    this.label = 'Guests',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.mdBorderRadius,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          // Minus button
          _StepperButton(
            icon: LucideIcons.minus,
            onPressed: count > min ? () => onChanged(count - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          // Plus button
          _StepperButton(
            icon: LucideIcons.plus,
            onPressed: count < max ? () => onChanged(count + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null;

    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: isEnabled
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
