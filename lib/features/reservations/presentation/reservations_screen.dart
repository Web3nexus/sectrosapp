import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'reservation_notifier.dart';
import '../../../models/reservation.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../core/theme/app_colors.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  void _showAddReservationSheet() {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final guestsCtl = TextEditingController(text: '2');
    final notesCtl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 19, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Add Reservation',
                  style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                // Customer name
                TextField(
                  controller: nameCtl,
                  decoration: InputDecoration(
                    labelText: 'Customer Name *',
                    prefixIcon: const Icon(LucideIcons.user, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: const Icon(LucideIcons.mail, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone *',
                    prefixIcon: const Icon(LucideIcons.phone, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: guestsCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Guests *',
                    prefixIcon: const Icon(LucideIcons.users, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setModalState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 20, color: AppColors.mutedForeground),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                          style: Theme.of(ctx).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Time picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setModalState(() => selectedTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 20, color: AppColors.mutedForeground),
                        const SizedBox(width: 12),
                        Text(
                          selectedTime.format(ctx),
                          style: Theme.of(ctx).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Special Requests',
                    prefixIcon: const Icon(LucideIcons.fileText, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (nameCtl.text.isEmpty || emailCtl.text.isEmpty || phoneCtl.text.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Please fill in all required fields')),
                        );
                        return;
                      }

                      final dt = DateTime(
                        selectedDate.year, selectedDate.month, selectedDate.day,
                        selectedTime.hour, selectedTime.minute,
                      );
                      final isoTime = dt.toIso8601String();

                      final err = await ref.read(reservationsProvider.notifier).createReservation({
                        'customer_name': nameCtl.text.trim(),
                        'customer_email': emailCtl.text.trim(),
                        'customer_phone': phoneCtl.text.trim(),
                        'party_size': int.tryParse(guestsCtl.text) ?? 2,
                        'reservation_time': isoTime,
                        'special_requests': notesCtl.text.trim(),
                        'source': 'app',
                      });

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      if (err != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err), backgroundColor: AppColors.destructive),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reservation created!'), backgroundColor: AppColors.success),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.calendarCheck, size: 18),
                    label: const Text('Create Reservation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resState = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservations',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarPlus, size: 20),
            tooltip: 'Add Reservation',
            onPressed: _showAddReservationSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, resState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReservationSheet,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Add Reservation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReservationsState state) {
    if (state.isLoading && state.reservations.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.listTile, itemCount: 6);
    }
    if (state.error != null && state.reservations.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(reservationsProvider.notifier).fetchReservations(),
      );
    }
    if (state.reservations.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.calendarCheck,
        title: 'No reservations',
        subtitle: 'New bookings will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: state.reservations.length,
      itemBuilder: (context, index) {
        final res = state.reservations[index];
        return AnimatedListItem(
          index: index,
          child: _ReservationTimelineTile(
            reservation: res,
            isFirst: index == 0,
            isLast: index == state.reservations.length - 1,
          ),
        );
      },
    );
  }
}

class _ReservationTimelineTile extends StatelessWidget {
  final Reservation reservation;
  final bool isFirst;
  final bool isLast;

  const _ReservationTimelineTile({
    required this.reservation,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    IconData statusIcon;
    switch (reservation.status) {
      case 'confirmed':
        statusColor = AppColors.success;
        statusIcon = LucideIcons.checkCircle;
        break;
      case 'arrived':
        statusColor = AppColors.primary;
        statusIcon = LucideIcons.userCheck;
        break;
      case 'cancelled':
        statusColor = AppColors.destructive;
        statusIcon = LucideIcons.xCircle;
        break;
      default:
        statusColor = AppColors.accent;
        statusIcon = LucideIcons.clock;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline bar
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  )
                else
                  const Spacer(),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(LucideIcons.clock, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text(
                              reservation.time.length >= 5
                                  ? reservation.time.substring(0, 5)
                                  : reservation.time,
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                            const SizedBox(width: 12),
                            Icon(LucideIcons.users, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text(
                              '${reservation.guests}',
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reservation.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
