import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum StatusType {
  confirmed,
  pending,
  cancelled,
  completed,
  available,
  unavailable,
  blocked,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final Color? customColor;
  final Color? customBgColor;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.confirmed,
    this.customColor,
    this.customBgColor,
    this.showDot = true,
  });

  factory StatusBadge.fromStatus(String? status) {
    final s = (status ?? '').toLowerCase().trim();
    if (s.contains('confirm') || s == 'seated' || s == 'active' || s == 'success' || s == 'available') {
      return StatusBadge(label: status ?? 'Confirmed', type: StatusType.confirmed);
    } else if (s.contains('pend') || s == 'waiting' || s == 'upcoming' || s == 'preparing') {
      return StatusBadge(label: status ?? 'Pending', type: StatusType.pending);
    } else if (s.contains('cancel') || s == 'rejected' || s == 'failed') {
      return StatusBadge(label: status ?? 'Cancelled', type: StatusType.cancelled);
    } else if (s.contains('complet') || s == 'served' || s == 'finished' || s == 'closed') {
      return StatusBadge(label: status ?? 'Completed', type: StatusType.completed);
    } else if (s.contains('block') || s == 'unavailable') {
      return StatusBadge(label: status ?? 'Blocked', type: StatusType.blocked);
    }
    return StatusBadge(label: status ?? 'Active', type: StatusType.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    Color fg;
    Color bg;

    switch (type) {
      case StatusType.confirmed:
      case StatusType.available:
        fg = AppColors.success;
        bg = AppColors.successLight;
      case StatusType.pending:
        fg = AppColors.warning;
        bg = AppColors.warningLight;
      case StatusType.cancelled:
        fg = AppColors.error;
        bg = AppColors.errorLight;
      case StatusType.completed:
        fg = AppColors.info;
        bg = AppColors.infoLight;
      case StatusType.unavailable:
        fg = AppColors.neutral;
        bg = AppColors.neutralLight;
      case StatusType.blocked:
        fg = AppColors.blocked;
        bg = AppColors.neutralLight;
      case StatusType.custom:
        fg = customColor ?? AppColors.primary;
        bg = customBgColor ?? AppColors.primaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
