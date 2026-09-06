import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/order.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/status_badge.dart';
import '../../../widgets/design_system/filter_bar.dart';
import '../../../widgets/design_system/app_bottom_sheet.dart';
import '../../../widgets/design_system/app_button.dart';
import 'order_notifier.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(ordersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allOrders = orderState.orders;
    final newCount = allOrders.where((o) => o.kitchenStatus.toLowerCase() == 'new' || o.kitchenStatus.isEmpty).length;
    final preparingCount = allOrders.where((o) => o.kitchenStatus.toLowerCase() == 'preparing').length;
    final readyCount = allOrders.where((o) => o.kitchenStatus.toLowerCase() == 'ready').length;

    final filterItems = [
      FilterItem(key: 'all', label: 'All Orders', count: allOrders.length),
      FilterItem(key: 'new', label: 'New', count: newCount),
      FilterItem(key: 'preparing', label: 'Preparing', count: preparingCount),
      FilterItem(key: 'ready', label: 'Ready', count: readyCount),
    ];

    final filtered = allOrders.where((o) {
      if (_selectedFilter != 'all') {
        final st = o.kitchenStatus.toLowerCase();
        if (_selectedFilter == 'new' && st != 'new' && st.isNotEmpty) return false;
        if (_selectedFilter == 'preparing' && st != 'preparing') return false;
        if (_selectedFilter == 'ready' && st != 'ready') return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Live Orders & Kitchen'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(ordersProvider.notifier).fetchOrders();
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await ref.read(ordersProvider.notifier).fetchOrders();
        },
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s8),
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

            // Order List
            Expanded(
              child: _buildList(orderState, filtered, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(OrdersState state, List<Order> filtered, bool isDark) {
    if (state.isLoading && state.orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding),
        child: SkeletonLoader(type: SkeletonType.listTile, itemCount: 6),
      );
    }
    if (state.error != null && state.orders.isEmpty) {
      return Center(
        child: ErrorView(
          message: state.error!,
          onRetry: () => ref.read(ordersProvider.notifier).fetchOrders(),
        ),
      );
    }
    if (filtered.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: LucideIcons.shoppingBag,
          title: 'No active orders',
          subtitle: 'Orders placed by guests or waitstaff will update here automatically',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s10),
          child: _OrderCard(
            order: order,
            isDark: isDark,
            onTap: () => _showOrderDetails(context, order, isDark),
          ),
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, Order order, bool isDark) {
    HapticFeedback.selectionClick();
    AppBottomSheet.show(
      context: context,
      title: 'Order #${order.id}',
      subtitle: 'Table ${order.tableNumber ?? 'N/A'} • \$${order.totalAmount.toStringAsFixed(2)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kitchen Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              StatusBadge.fromStatus(order.kitchenStatus.isNotEmpty ? order.kitchenStatus : 'New'),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Order Items (${order.items.length})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s8),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.quantity}x ${item.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isDark;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String timeFormatted = '';
    try {
      timeFormatted = DateFormat('hh:mm a').format(DateTime.parse(order.createdAt));
    } catch (_) {}

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkElevated : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        'T${order.tableNumber ?? '?' }',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${order.tableNumber ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      if (timeFormatted.isNotEmpty)
                        Text(
                          timeFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge.fromStatus(order.kitchenStatus.isNotEmpty ? order.kitchenStatus : 'New'),
                ],
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
