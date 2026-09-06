import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/customer.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/design_system/app_search_input.dart';
import '../../../widgets/design_system/filter_bar.dart';
import '../../../widgets/design_system/customer_card.dart';
import '../../../widgets/design_system/app_bottom_sheet.dart';
import '../../../widgets/design_system/app_button.dart';
import 'customers_notifier.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(customersProvider);

    final allCustomers = state.customers;
    final vipCount = allCustomers.where((c) => c.status.toLowerCase() == 'vip').length;
    final regularCount = allCustomers.where((c) => c.status.toLowerCase() == 'regular').length;
    final newCount = allCustomers.where((c) => c.status.toLowerCase() == 'new').length;

    final filterItems = [
      FilterItem(key: 'all', label: 'All Guests', count: allCustomers.length),
      FilterItem(key: 'vip', label: 'VIP', count: vipCount),
      FilterItem(key: 'regular', label: 'Regulars', count: regularCount),
      FilterItem(key: 'new', label: 'New Guests', count: newCount),
    ];

    final filtered = allCustomers.where((c) {
      if (_selectedFilter != 'all') {
        if (c.status.toLowerCase() != _selectedFilter) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = c.name.toLowerCase().contains(q);
        final phoneMatch = c.phone.toLowerCase().contains(q);
        final emailMatch = c.email.toLowerCase().contains(q);
        if (!nameMatch && !phoneMatch && !emailMatch) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Directory'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await ref.read(customersProvider.notifier).fetchCustomers();
        },
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s8),
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: AppSearchInput(
                controller: _searchController,
                hintText: 'Search guest name, phone, email...',
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                onClear: () => setState(() => _searchQuery = ''),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),

            // Filter Bar
            FilterBar(
              items: filterItems,
              selectedKey: _selectedFilter,
              onSelected: (key) {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = key);
              },
            ),
            const SizedBox(height: AppSpacing.s12),

            // List or Empty
            Expanded(
              child: _buildList(state, filtered, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(CustomersState state, List<Customer> filtered, bool isDark) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding),
        child: SkeletonLoader(type: SkeletonType.listTile, itemCount: 6),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: EmptyState(
          icon: LucideIcons.users,
          title: _searchQuery.isNotEmpty ? 'No guests found' : 'No customer records',
          subtitle: _searchQuery.isNotEmpty
              ? 'Try modifying your search criteria'
              : 'Guests will automatically appear here as reservations are created',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final customer = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s10),
          child: CustomerCard(
            customer: customer,
            onTap: () => _showCustomerDetails(context, customer, isDark),
          ),
        );
      },
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer, bool isDark) {
    HapticFeedback.selectionClick();
    AppBottomSheet.show(
      context: context,
      title: customer.name,
      subtitle: '${customer.status.toUpperCase()} Guest • ${customer.totalBookings} visits',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customer.phone.isNotEmpty) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.phone, size: 20, color: AppColors.primary),
              title: const Text('Phone Number', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              subtitle: Text(
                customer.phone,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: customer.phone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone number copied')),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],
          if (customer.email.isNotEmpty) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.mail, size: 20, color: AppColors.primary),
              title: const Text('Email Address', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              subtitle: Text(
                customer.email,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: customer.email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied')),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],
          if (customer.lastVisit != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.calendar, size: 20, color: AppColors.primary),
              title: const Text('Last Visit', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              subtitle: Text(
                customer.lastVisit!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (customer.notes != null && customer.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            const Text(
              'Guest Notes & Preferences',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                customer.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s20),
          AppButton(
            label: 'Close Profile',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

