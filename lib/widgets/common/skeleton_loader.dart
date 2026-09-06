import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum SkeletonType { card, listTile, grid, metric, reservation }

class SkeletonLoader extends StatelessWidget {
  final int itemCount;
  final SkeletonType type;

  const SkeletonLoader({
    super.key,
    this.itemCount = 4,
    this.type = SkeletonType.card,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkElevated : AppColors.secondaryBackground;
    final highlightColor = isDark ? AppColors.darkBorder : AppColors.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, i) => _buildItem(context, isDark),
      ),
    );
  }

  Widget _buildItem(BuildContext context, bool isDark) {
    final shimmerColor = isDark ? AppColors.darkElevated : AppColors.surface;

    switch (type) {
      case SkeletonType.card:
        return Padding(
          padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, bottom: AppSpacing.s12),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: AppRadius.lgBorderRadius,
            ),
          ),
        );
      case SkeletonType.reservation:
        return Padding(
          padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, bottom: AppSpacing.s10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: AppRadius.lgBorderRadius,
            ),
          ),
        );
      case SkeletonType.listTile:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.s8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Container(
                      height: 10,
                      width: 120,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case SkeletonType.grid:
      case SkeletonType.metric:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.s6),
          child: Row(
            children: List.generate(2, (i) => Expanded(
              child: Container(
                height: 96,
                margin: EdgeInsets.only(right: i == 0 ? AppSpacing.s8 : 0, left: i == 1 ? AppSpacing.s8 : 0),
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: AppRadius.lgBorderRadius,
                ),
              ),
            )),
          ),
        );
    }
  }
}
