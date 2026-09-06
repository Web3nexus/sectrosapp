import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/reservation.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/status_badge.dart';
import '../../../widgets/design_system/app_button.dart';

class ReservationDetailScreen extends ConsumerStatefulWidget {
  final Reservation reservation;

  const ReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  @override
  ConsumerState<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends ConsumerState<ReservationDetailScreen> {
  late Reservation _reservation;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _reservation;

    String formattedDate = res.date;
    try {
      final parsed = DateTime.parse(res.date);
      formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(parsed);
    } catch (_) {}

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Reservation Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          top: AppSpacing.s12,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.s12,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Cancel Booking',
                variant: AppButtonVariant.destructive,
                isLoading: _isActionLoading,
                onPressed: () => _handleCancel(context),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: AppButton(
                label: res.status.toLowerCase() == 'confirmed' ? 'Seat Guest' : 'Confirm',
                variant: AppButtonVariant.primary,
                isLoading: _isActionLoading,
                onPressed: () => _handleConfirm(context),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Navy Contextual Card for Booking Summary
            AppNavyCard(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BOOKING #${res.id}',
                        style: const TextStyle(
                          color: AppColors.navyCardTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      StatusBadge.fromStatus(res.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    res.customerName.isNotEmpty ? res.customerName : 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s14),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.navyCardTextMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 14, color: AppColors.navyCardTextMuted),
                      const SizedBox(width: 6),
                      Text(
                        res.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // Party & Table Information Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seating & Allocation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _DetailRow(
                    icon: LucideIcons.users,
                    label: 'Party Size',
                    value: '${res.guests} Guests',
                    isDark: isDark,
                  ),
                  const Divider(height: AppSpacing.s16),
                  _DetailRow(
                    icon: LucideIcons.layoutGrid,
                    label: 'Table Allocation',
                    value: res.tableNumber != null ? 'Table ${res.tableNumber}' : 'Unassigned',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Contact Information Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Contact',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  if (res.phone != null && res.phone!.isNotEmpty) ...[
                    _DetailRow(
                      icon: LucideIcons.phone,
                      label: 'Phone',
                      value: res.phone!,
                      isDark: isDark,
                      trailing: AppIconButton(
                        icon: LucideIcons.copy,
                        size: 32,
                        tooltip: 'Copy Phone',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: res.phone!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Phone number copied')),
                          );
                        },
                      ),
                    ),
                    const Divider(height: AppSpacing.s16),
                  ],
                  if (res.email != null && res.email!.isNotEmpty) ...[
                    _DetailRow(
                      icon: LucideIcons.mail,
                      label: 'Email',
                      value: res.email!,
                      isDark: isDark,
                      trailing: AppIconButton(
                        icon: LucideIcons.copy,
                        size: 32,
                        tooltip: 'Copy Email',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: res.email!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email copied')),
                          );
                        },
                      ),
                    ),
                  ],
                  if ((res.phone == null || res.phone!.isEmpty) &&
                      (res.email == null || res.email!.isEmpty))
                    Text(
                      'No direct contact details provided.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Special Requests & Notes Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        size: 16,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Special Requests & Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    (res.notes != null && res.notes!.isNotEmpty)
                        ? res.notes!
                        : 'No special requests submitted for this booking.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: (res.notes != null && res.notes!.isNotEmpty)
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context) async {
    HapticFeedback.mediumImpact();
    setState(() => _isActionLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _isActionLoading = false;
        _reservation = Reservation(
          id: _reservation.id,
          customerName: _reservation.customerName,
          tableNumber: _reservation.tableNumber,
          date: _reservation.date,
          time: _reservation.time,
          guests: _reservation.guests,
          status: 'confirmed',
          phone: _reservation.phone,
          email: _reservation.email,
          notes: _reservation.notes,
        );
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation status updated to Confirmed'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleCancel(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text('Are you sure you want to cancel the booking for ${_reservation.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && mounted) {
      setState(() => _isActionLoading = true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _isActionLoading = false;
          _reservation = Reservation(
            id: _reservation.id,
            customerName: _reservation.customerName,
            tableNumber: _reservation.tableNumber,
            date: _reservation.date,
            time: _reservation.time,
            guests: _reservation.guests,
            status: 'cancelled',
            phone: _reservation.phone,
            email: _reservation.email,
            notes: _reservation.notes,
          );
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation cancelled'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
