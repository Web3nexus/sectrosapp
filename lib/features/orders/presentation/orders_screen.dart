import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'order_notifier.dart';
import '../../../models/order.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../core/theme/app_colors.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Orders',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (!orderState.isLoading && orderState.orders.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orderState.orders.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(ordersProvider.notifier).fetchOrders(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, orderState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrdersState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.listTile, itemCount: 7);
    }
    if (state.error != null && state.orders.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(ordersProvider.notifier).fetchOrders(),
      );
    }
    if (state.orders.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.messageSquare,
        title: 'No orders yet',
        subtitle: 'New customer orders will appear here in real-time',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 120),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return AnimatedListItem(
          index: index,
          child: _OrderChatTile(order: order),
        );
      },
    );
  }
}

class _OrderChatTile extends ConsumerWidget {
  final Order order;
  const _OrderChatTile({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    String statusLabel;
    switch (order.kitchenStatus) {
      case 'ready':
        statusColor = AppColors.success;
        statusLabel = 'Ready';
        break;
      case 'preparing':
        statusColor = AppColors.accent;
        statusLabel = 'Cooking';
        break;
      default:
        statusColor = AppColors.primary;
        statusLabel = 'New';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar with status dot (WhatsApp-style)
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Text(
                        'T${order.tableNumber ?? '?'}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkCard : AppColors.card,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Order details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Table ${order.tableNumber ?? 'N/A'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('hh:mm a').format(DateTime.parse(order.createdAt)),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
