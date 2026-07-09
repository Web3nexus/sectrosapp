import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/staff_dashboard_data.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/error_view.dart';
import 'staff_dashboard_notifier.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffDashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Dashboard'), centerTitle: true),
      body: state.isLoading
          ? const Center(child: SkeletonLoader(type: SkeletonType.card))
          : state.error != null
              ? ErrorView(message: state.error!, onRetry: () => ref.read(staffDashboardProvider.notifier).fetch())
              : _buildContent(context, ref, state.data!, theme),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, StaffDashboardData data, ThemeData theme) {

    return RefreshIndicator(
      onRefresh: () => ref.read(staffDashboardProvider.notifier).fetch(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(profile: data.profile, theme: theme),
          const SizedBox(height: 16),
          _SummaryCards(summary: data.summary, theme: theme),
          const SizedBox(height: 16),
          if (data.nextShift != null) ...[
            _NextShiftCard(shift: data.nextShift!, theme: theme),
            const SizedBox(height: 16),
          ],
          if (data.upcomingShifts.isNotEmpty) ...[
            _SectionHeader(icon: LucideIcons.calendar, title: 'Upcoming Shifts', theme: theme),
            const SizedBox(height: 8),
            ...data.upcomingShifts.map((s) => _ShiftTile(shift: s, theme: theme)),
            const SizedBox(height: 16),
          ],
          if (data.recentAttendance.isNotEmpty) ...[
            _SectionHeader(icon: LucideIcons.clock, title: 'Recent Attendance', theme: theme),
            const SizedBox(height: 8),
            ...data.recentAttendance.map((a) => _AttendanceTile(attendance: a, theme: theme)),
            const SizedBox(height: 16),
          ],
          if (data.payroll.isNotEmpty) ...[
            _SectionHeader(icon: LucideIcons.wallet, title: 'Payroll History', theme: theme),
            const SizedBox(height: 8),
            ...data.payroll.map((p) => _PayrollTile(payroll: p, theme: theme)),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final StaffProfileInfo profile;
  final ThemeData theme;
  const _ProfileCard({required this.profile, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.primaryColor,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(profile.role.toUpperCase(), style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600)),
                ),
                if (profile.hourlyRate != null) ...[
                  const SizedBox(height: 4),
                  Text('\$${profile.hourlyRate!.toStringAsFixed(2)}/hr', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final StaffSummary summary;
  final ThemeData theme;
  const _SummaryCards({required this.summary, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Card(label: 'This Week', value: '${summary.weeklyHours}h', icon: LucideIcons.trendingUp, color: Colors.green, theme: theme)),
        const SizedBox(width: 12),
        Expanded(child: _Card(label: 'This Month', value: '${summary.monthlyHours}h', icon: LucideIcons.calendar, color: theme.primaryColor, theme: theme)),
        const SizedBox(width: 12),
        Expanded(child: _Card(label: 'Payout', value: '\$${summary.monthlyPayout.toStringAsFixed(0)}', icon: LucideIcons.wallet, color: Colors.orange, theme: theme)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  const _Card({required this.label, required this.value, required this.icon, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _NextShiftCard extends StatelessWidget {
  final NextShift shift;
  final ThemeData theme;
  const _NextShiftCard({required this.shift, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.clock, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Next Shift', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(shift.date, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${shift.startTime} - ${shift.endTime}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(shift.status.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.icon, required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedForeground),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final ShiftItem shift;
  final ThemeData theme;
  const _ShiftTile({required this.shift, required this.theme});

  Color _statusColor(String status) {
    switch (status) {
      case 'checked_in': return Colors.green;
      case 'checked_out': return AppColors.mutedForeground;
      case 'missed': return AppColors.destructive;
      default: return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusColor(shift.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.calendar, color: _statusColor(shift.status), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift.date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${shift.startTime} - ${shift.endTime}', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(shift.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(shift.status.replaceAll('_', ' '), style: TextStyle(fontSize: 11, color: _statusColor(shift.status), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final AttendanceItem attendance;
  final ThemeData theme;
  const _AttendanceTile({required this.attendance, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attendance.date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${attendance.checkIn ?? '--'} - ${attendance.checkOut ?? '--'}', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          Text('${attendance.totalHours.toStringAsFixed(1)}h', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }
}

class _PayrollTile extends StatelessWidget {
  final PayrollItem payroll;
  final ThemeData theme;
  const _PayrollTile({required this.payroll, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(payroll.period, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (payroll.status == 'paid' ? Colors.green : Colors.amber).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(payroll.status.toUpperCase(), style: TextStyle(fontSize: 11, color: payroll.status == 'paid' ? Colors.green : Colors.amber, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _amount('Base', '\$${payroll.baseSalary.toStringAsFixed(0)}'),
              const SizedBox(width: 16),
              if (payroll.overtimePay > 0) _amount('Overtime', '\$${payroll.overtimePay.toStringAsFixed(0)}'),
              if (payroll.overtimePay > 0) const SizedBox(width: 16),
              if (payroll.tipsShare > 0) _amount('Tips', '\$${payroll.tipsShare.toStringAsFixed(0)}'),
              const Spacer(),
              Text('\$${payroll.totalPayout.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amount(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
      ],
    );
  }
}
