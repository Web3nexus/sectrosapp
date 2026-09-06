import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/user.dart';
import '../../../models/table.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/design_system/filter_bar.dart';
import '../../../widgets/design_system/resource_card.dart';
import '../../../widgets/design_system/app_bottom_sheet.dart';
import '../../../widgets/design_system/app_button.dart';
import '../../../widgets/design_system/status_badge.dart';
import 'table_notifier.dart';

class TablesScreen extends ConsumerStatefulWidget {
  const TablesScreen({super.key});

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final tableState = ref.watch(tablesProvider);
    final user = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title = 'Floor Plan & Tables';
    String resourceName = 'Table';

    if (user != null) {
      if (user.businessType == 'hotel') {
        title = 'Rooms & Availability';
        resourceName = 'Room';
      } else if (user.businessType == 'salon') {
        title = 'Workstations';
        resourceName = 'Station';
      }
    }

    final allTables = tableState.tables;
    final availableCount = allTables.where((t) => t.status.toLowerCase() == 'available').length;
    final occupiedCount = allTables.where((t) => t.status.toLowerCase() == 'occupied').length;
    final reservedCount = allTables.where((t) => t.status.toLowerCase() == 'reserved').length;

    final filterItems = [
      FilterItem(key: 'all', label: 'All $resourceName' 's', count: allTables.length),
      FilterItem(key: 'available', label: 'Available', count: availableCount),
      FilterItem(key: 'occupied', label: 'Occupied', count: occupiedCount),
      FilterItem(key: 'reserved', label: 'Reserved', count: reservedCount),
    ];

    final filtered = allTables.where((t) {
      if (_selectedFilter != 'all') {
        if (t.status.toLowerCase() != _selectedFilter) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(tablesProvider.notifier).fetchTables();
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await ref.read(tablesProvider.notifier).fetchTables();
        },
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s8),

            // Status Filter Bar
            FilterBar(
              items: filterItems,
              selectedKey: _selectedFilter,
              onSelected: (key) {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = key);
              },
            ),

            const SizedBox(height: AppSpacing.s12),

            // Floor Plan Grid
            Expanded(
              child: _buildGrid(tableState, filtered, resourceName, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(TablesState state, List<TableModel> tables, String resourceName, bool isDark) {
    if (state.isLoading && state.tables.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding),
        child: SkeletonLoader(type: SkeletonType.grid, itemCount: 4),
      );
    }
    if (state.error != null && state.tables.isEmpty) {
      return Center(
        child: ErrorView(
          message: state.error!,
          onRetry: () => ref.read(tablesProvider.notifier).fetchTables(),
        ),
      );
    }
    if (tables.isEmpty) {
      return Center(
        child: EmptyState(
          icon: LucideIcons.layoutGrid,
          title: 'No $resourceName' 's found',
          subtitle: 'No $resourceName matches the selected status filter',
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.s12,
        mainAxisSpacing: AppSpacing.s12,
        childAspectRatio: 1.1,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return ResourceCard(
          table: table,
          onTap: () => _showTableDetails(context, table, resourceName, isDark),
        );
      },
    );
  }

  void _showTableDetails(BuildContext context, TableModel table, String resourceName, bool isDark) {
    HapticFeedback.selectionClick();
    AppBottomSheet.show(
      context: context,
      title: table.name,
      subtitle: '$resourceName capacity: ${table.capacity} guests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              StatusBadge.fromStatus(table.status),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              const Icon(LucideIcons.users, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s10),
              Text(
                'Maximum Capacity: ${table.capacity} persons',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          AppButton(
            label: 'Close',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
