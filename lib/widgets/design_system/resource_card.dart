import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/table.dart';
import 'app_card.dart';
import 'status_badge.dart';

class ResourceCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback? onTap;

  const ResourceCard({
    super.key,
    required this.table,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    StatusType statusType;
    String statusLabel = table.status.toUpperCase();
    if (table.status.toLowerCase() == 'available') {
      statusType = StatusType.available;
      statusLabel = 'AVAILABLE';
    } else if (table.status.toLowerCase() == 'occupied') {
      statusType = StatusType.pending;
      statusLabel = 'OCCUPIED';
    } else {
      statusType = StatusType.completed;
      statusLabel = 'RESERVED';
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.layoutGrid,
                    size: 18,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              StatusBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                table.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Up to ${table.capacity} guests',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
