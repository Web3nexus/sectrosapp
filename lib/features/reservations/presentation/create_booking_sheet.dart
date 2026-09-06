import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/design_system/app_bottom_sheet.dart';
import '../../../widgets/design_system/app_button.dart';
import '../../../widgets/design_system/horizontal_date_selector.dart';
import '../../../widgets/design_system/time_slot_chips.dart';
import '../../../widgets/design_system/guest_stepper.dart';
import 'reservation_notifier.dart';

class CreateBookingSheet extends ConsumerStatefulWidget {
  const CreateBookingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'New Reservation',
      subtitle: 'Create a direct booking for your guests',
      child: const CreateBookingSheet(),
    );
  }

  @override
  ConsumerState<CreateBookingSheet> createState() => _CreateBookingSheetState();
}

class _CreateBookingSheetState extends ConsumerState<CreateBookingSheet> {
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = '19:00';
  int _guestCount = 2;
  bool _isSubmitting = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _timeSlots = [
    '12:00', '12:30', '13:00', '13:30', '14:00',
    '17:00', '17:30', '18:00', '18:30', '19:00',
    '19:30', '20:00', '20:30', '21:00', '21:30'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Date Selection
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        HorizontalDateSelector(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            HapticFeedback.selectionClick();
            setState(() => _selectedDate = date);
          },
        ),

        const SizedBox(height: AppSpacing.s20),

        // 2. Party Size & Time Row
        Text(
          'Party Size',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        GuestStepper(
          count: _guestCount,
          onChanged: (val) {
            HapticFeedback.selectionClick();
            setState(() => _guestCount = val);
          },
        ),

        const SizedBox(height: AppSpacing.s20),

        // 3. Time Slots
        Text(
          'Select Time',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        TimeSlotChips(
          timeSlots: _timeSlots,
          selectedSlot: _selectedSlot,
          onSlotSelected: (slot) {
            HapticFeedback.selectionClick();
            setState(() => _selectedSlot = slot);
          },
        ),

        const SizedBox(height: AppSpacing.s20),

        // 4. Guest Details
        Text(
          'Guest Details',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Customer Full Name *',
            prefixIcon: Icon(LucideIcons.user, size: 18),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Icon(LucideIcons.phone, size: 18),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(LucideIcons.mail, size: 18),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Special Requests / Dietary Notes',
            prefixIcon: Icon(LucideIcons.fileText, size: 18),
          ),
        ),

        const SizedBox(height: AppSpacing.s24),

        // Submit Button
        AppButton(
          label: 'Confirm & Book Reservation',
          icon: LucideIcons.calendarCheck,
          isLoading: _isSubmitting,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter guest name and phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final reservationDateTime = '$dateStr $_selectedSlot:00';

    final error = await ref.read(reservationsProvider.notifier).createReservation({
      'customer_name': name,
      'customer_phone': phone,
      'customer_email': _emailController.text.trim(),
      'party_size': _guestCount,
      'reservation_time': reservationDateTime,
      'special_requests': _notesController.text.trim(),
      'source': 'app',
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation successfully created!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
