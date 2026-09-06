import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppSearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final Widget? trailing;

  const AppSearchInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search guest, reservation ID, phone...',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.mdBorderRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.s12),
          Icon(
            LucideIcons.search,
            size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16),
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              onPressed: () {
                controller?.clear();
                onClear?.call();
                onChanged?.call('');
              },
            ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: AppSpacing.s8),
          ],
        ],
      ),
    );
  }
}
