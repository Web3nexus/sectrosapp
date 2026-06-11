import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'staff_notifier.dart';
import '../../../models/staff_profile.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../core/theme/app_colors.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  void _showStaffSheet({StaffProfile? existing}) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final emailCtl = TextEditingController(text: existing?.email ?? '');
    final phoneCtl = TextEditingController(text: existing?.phone ?? '');
    String role = existing?.role ?? 'waiter';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
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
            Text(
              existing != null ? 'Edit Staff' : 'Add Staff',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(LucideIcons.user, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(LucideIcons.mail, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneCtl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: const Icon(LucideIcons.phone, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: InputDecoration(
                labelText: 'Role',
                prefixIcon: const Icon(LucideIcons.shield, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: const [
                DropdownMenuItem(value: 'waiter', child: Text('Waiter')),
                DropdownMenuItem(value: 'chef', child: Text('Chef')),
                DropdownMenuItem(value: 'manager', child: Text('Manager')),
                DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                DropdownMenuItem(value: 'host', child: Text('Host')),
              ],
              onChanged: (v) => role = v ?? 'waiter',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtl.text.trim().isEmpty) return;
                  final staff = StaffProfile(
                    id: existing?.id ?? 0,
                    name: nameCtl.text.trim(),
                    email: emailCtl.text.trim().isEmpty ? null : emailCtl.text.trim(),
                    phone: phoneCtl.text.trim().isEmpty ? null : phoneCtl.text.trim(),
                    role: role,
                  );
                  if (existing != null) {
                    ref.read(staffProvider.notifier).updateStaff(existing.id, staff);
                  } else {
                    ref.read(staffProvider.notifier).createStaff(staff);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(existing != null ? 'Save Changes' : 'Add Staff'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Staff',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 20),
            onPressed: () => _showStaffSheet(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(staffProvider.notifier).fetchStaff(),
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, StaffState state) {
    if (state.isLoading && state.staff.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.listTile, itemCount: 6);
    }
    if (state.error != null && state.staff.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(staffProvider.notifier).fetchStaff(),
      );
    }
    if (state.staff.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.users,
        title: 'No staff yet',
        subtitle: 'Add your team members to manage shifts and roles',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
      itemCount: state.staff.length,
      itemBuilder: (context, index) {
        final staff = state.staff[index];
        return AnimatedListItem(
          index: index,
          child: _StaffContactTile(
            staff: staff,
            onTap: () => _showStaffSheet(existing: staff),
            onToggle: () {
              ref.read(staffProvider.notifier).updateStaff(
                staff.id,
                StaffProfile(
                  id: staff.id,
                  name: staff.name,
                  email: staff.email,
                  phone: staff.phone,
                  role: staff.role,
                  isActive: !staff.isActive,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StaffContactTile extends StatelessWidget {
  final StaffProfile staff;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _StaffContactTile({
    required this.staff,
    required this.onTap,
    required this.onToggle,
  });

  Color _roleColor() {
    switch (staff.role) {
      case 'manager':
        return AppColors.secondary;
      case 'chef':
        return AppColors.accent;
      case 'cashier':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleColor = _roleColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: staff.isActive
                    ? AppColors.border.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: roleColor.withValues(alpha: 0.15),
                      child: Text(
                        staff.name.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: staff.isActive ? AppColors.success : AppColors.mutedForeground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkCard : AppColors.card,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              staff.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: roleColor,
                              ),
                            ),
                          ),
                          if (staff.email != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              staff.email!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: staff.isActive
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.mutedForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      staff.isActive ? LucideIcons.checkCircle : LucideIcons.xCircle,
                      size: 16,
                      color: staff.isActive ? AppColors.success : AppColors.mutedForeground,
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
}
