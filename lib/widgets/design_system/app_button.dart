import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, destructive, ghost }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Sizing
    final double height = switch (size) {
      AppButtonSize.sm => 36.0,
      AppButtonSize.md => 46.0,
      AppButtonSize.lg => 52.0,
    };
    final double fontSize = switch (size) {
      AppButtonSize.sm => 13.0,
      AppButtonSize.md => 14.0,
      AppButtonSize.lg => 15.0,
    };
    final double iconSize = switch (size) {
      AppButtonSize.sm => 16.0,
      AppButtonSize.md => 18.0,
      AppButtonSize.lg => 20.0,
    };

    // Colors
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = isDark ? AppColors.darkPrimaryTeal : AppColors.primary;
        fg = isDark ? AppColors.darkBackground : AppColors.white;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurface : AppColors.surface;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        borderSide = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border, width: 1);
      case AppButtonVariant.destructive:
        bg = isDark ? AppColors.error.withValues(alpha: 0.15) : AppColors.errorLight;
        fg = AppColors.error;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    }

    final child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: AppSpacing.s8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.1,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.s8),
            Icon(trailingIcon, size: iconSize, color: fg),
          ],
        ],
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: AppRadius.mdBorderRadius,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdBorderRadius,
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          splashColor: fg.withValues(alpha: 0.1),
          highlightColor: fg.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final bool hasBorder;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.hasBorder = true,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final defaultFg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    Widget button = Material(
      color: backgroundColor ?? (hasBorder ? defaultBg : Colors.transparent),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorderRadius,
        side: hasBorder ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: 20, color: color ?? defaultFg),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
