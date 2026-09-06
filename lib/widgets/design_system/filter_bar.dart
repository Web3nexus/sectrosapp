import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class FilterItem {
  final String key;
  final String label;
  final int? count;

  const FilterItem({
    required this.key,
    required this.label,
    this.count,
  });
}

class FilterBar extends StatelessWidget {
  final List<FilterItem> items;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const FilterBar({
    super.key,
    required this.items,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.key == selectedKey;

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
              onTap: () => onSelected(item.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: AppSpacing.s6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.darkBackground : AppColors.white)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                    ),
                    if (item.count != null) ...[
                      const SizedBox(width: AppSpacing.s6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.darkBackground.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.25))
                              : (isDark ? AppColors.darkElevated : AppColors.secondaryBackground),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${item.count}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? (isDark ? AppColors.darkBackground : AppColors.white)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
