import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_config.dart';
import '../../../models/order.dart';
import '../../../models/menu.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/status_badge.dart';
import '../../../widgets/design_system/filter_bar.dart';
import '../../../widgets/design_system/app_bottom_sheet.dart';
import '../../../widgets/design_system/app_button.dart';
import '../../../widgets/navigation/app_nav_menu.dart';
import '../../../core/utils/subscription_guard.dart';
import '../../menu/presentation/menu_notifier.dart';
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
    final kitchenCount = allOrders.where((o) =>
        ['pending', 'new', 'accepted', 'preparing'].contains(o.kitchenStatus.toLowerCase()) ||
        o.kitchenStatus.isEmpty).length;
    final readyCount = allOrders.where((o) => o.kitchenStatus.toLowerCase() == 'ready').length;
    final servedCount = allOrders.where((o) => o.kitchenStatus.toLowerCase() == 'served').length;
    final unremittedCount = allOrders.where((o) => o.needsRemittance).length;

    final filterItems = [
      FilterItem(key: 'all', label: 'All', count: allOrders.length),
      FilterItem(key: 'kitchen', label: 'Kitchen Queue', count: kitchenCount),
      FilterItem(key: 'ready', label: 'Ready', count: readyCount),
      FilterItem(key: 'served', label: 'Served', count: servedCount),
      if (unremittedCount > 0)
        FilterItem(key: 'unremitted', label: 'Unremitted Cash', count: unremittedCount),
    ];

    final filtered = allOrders.where((o) {
      final ks = o.kitchenStatus.toLowerCase();
      if (_selectedFilter == 'kitchen') {
        return ['pending', 'new', 'accepted', 'preparing'].contains(ks) || ks.isEmpty;
      }
      if (_selectedFilter == 'ready') {
        return ks == 'ready';
      }
      if (_selectedFilter == 'served') {
        return ks == 'served';
      }
      if (_selectedFilter == 'unremitted') {
        return o.needsRemittance;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: const AppNavMenuButton(),
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
          const SizedBox(width: AppSpacing.s4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _showTakeOrderSheet(context),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('New Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
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
            FilterBar(
              items: filterItems,
              selectedKey: _selectedFilter,
              onSelected: (key) {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = key);
              },
            ),
            const SizedBox(height: AppSpacing.s12),
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
          title: 'No orders found',
          subtitle: 'In-house and POS orders will appear here automatically',
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
            onQuickAction: () => _handleQuickAction(context, order),
          ),
        );
      },
    );
  }

  void _handleQuickAction(BuildContext context, Order order) {
    final ks = order.kitchenStatus.toLowerCase();
    final notifier = ref.read(ordersProvider.notifier);

    if (ks == 'pending' || ks == 'new' || ks.isEmpty) {
      notifier.updateKitchenStatus(order.id, 'preparing');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} sent to prep')),
      );
    } else if (ks == 'preparing' || ks == 'accepted') {
      notifier.updateKitchenStatus(order.id, 'ready');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} marked READY! Server notified.')),
      );
    } else if (ks == 'ready') {
      notifier.updateKitchenStatus(order.id, 'served');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} marked as SERVED.')),
      );
    } else if (ks == 'served' && !order.isPaid) {
      _showPaymentOptionsDialog(context, order);
    }
  }

  // Take In-House Order Bottom Sheet
  void _showTakeOrderSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (!SubscriptionGuard.canPerformAction(context, ref, actionName: 'take new in-house orders')) {
      return;
    }
    // Ensure menu is fetched
    ref.read(menuProvider.notifier).fetchMenu();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TakeInHouseOrderModal(
        onSubmit: (tableCode, selectedItems, customerName) async {
          final success = await ref.read(ordersProvider.notifier).createInHouseOrder(
            tableCode: tableCode,
            items: selectedItems,
            customerName: customerName,
          );
          if (success && mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green.shade800,
                content: Text('Order for Table $tableCode placed & sent to kitchen!'),
              ),
            );
          }
        },
      ),
    );
  }

  // Order Details Bottom Sheet
  void _showOrderDetails(BuildContext context, Order order, bool isDark) {
    HapticFeedback.selectionClick();
    final ks = order.kitchenStatus.toLowerCase();

    AppBottomSheet.show(
      context: context,
      title: 'Order #${order.id}',
      subtitle: 'Table ${order.tableCode ?? 'N/A'} • \$${order.totalAmount.toStringAsFixed(2)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kitchen Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  StatusBadge.fromStatus(order.kitchenStatus.isNotEmpty ? order.kitchenStatus : 'New'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Payment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: order.isPaid
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: order.isPaid ? Colors.green : Colors.amber,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      order.isPaid
                          ? 'PAID (${order.paymentMethod?.toUpperCase() ?? 'CARD'})'
                          : 'UNPAID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: order.isPaid ? Colors.green : Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (order.staffName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.user, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Server: ${order.staffName}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],

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
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
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
          const SizedBox(height: AppSpacing.s12),

          // Subtotal & Tip Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Food & Drinks Subtotal', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
            ],
          ),
          if (order.tipAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Server Tip / Gratuity', style: TextStyle(fontSize: 13, color: Colors.amber)),
                Text('+\$${order.tipAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(
                '\$${(order.totalAmount + order.tipAmount).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s20),

          // Lifecycle & Kitchen Action Buttons
          if (ks == 'pending' || ks == 'new' || ks.isEmpty) ...[
            AppButton(
              label: 'Accept & Prepare Order',
              variant: AppButtonVariant.primary,
              icon: LucideIcons.utensils,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(ordersProvider.notifier).updateKitchenStatus(order.id, 'preparing');
              },
            ),
          ] else if (ks == 'preparing' || ks == 'accepted') ...[
            AppButton(
              label: 'Mark as Ready for Pickup',
              variant: AppButtonVariant.primary,
              icon: LucideIcons.bell,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(ordersProvider.notifier).updateKitchenStatus(order.id, 'ready');
              },
            ),
          ] else if (ks == 'ready') ...[
            AppButton(
              label: 'Pick Up & Mark as Served',
              variant: AppButtonVariant.primary,
              icon: LucideIcons.checkCircle,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(ordersProvider.notifier).updateKitchenStatus(order.id, 'served');
              },
            ),
          ] else if (ks == 'served' && !order.isPaid) ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'QR Pay',
                    variant: AppButtonVariant.primary,
                    icon: LucideIcons.qrCode,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showPaymentQrDialog(context, order);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Collect Cash',
                    variant: AppButtonVariant.secondary,
                    icon: LucideIcons.banknote,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showCashPaymentDialog(context, order);
                    },
                  ),
                ),
              ],
            ),
          ],

          if (order.needsRemittance) ...[
            const SizedBox(height: 10),
            AppButton(
              label: 'Remit Cash to Business Owner',
              variant: AppButtonVariant.secondary,
              icon: LucideIcons.arrowUpRight,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(ordersProvider.notifier).remitCash(order.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cash for Order #${order.id} remitted successfully!')),
                );
              },
            ),
          ],

          const SizedBox(height: AppSpacing.s10),
          AppButton(
            label: 'Close',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptionsDialog(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Collect Payment for Order #${order.id}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Table ${order.tableCode ?? 'N/A'} • Total: \$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.qrCode, color: AppColors.primary),
              ),
              title: const Text('Customer Mobile QR Pay', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Customer scans with their mobile phone, selects tip, and pays directly'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showPaymentQrDialog(context, order);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.banknote, color: Colors.green),
              ),
              title: const Text('Collect Cash Payment', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Manually record cash received from guest with optional tip'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showCashPaymentDialog(context, order);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showPaymentQrDialog(BuildContext context, Order order) {
    final payUrl = '${AppConfig.baseUrl}/order-pay/${order.id}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Column(
            children: [
              Text(
                'Table ${order.tableCode ?? 'N/A'} Payment',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Scan QR with Phone Camera to Pay & Tip',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: payUrl,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${order.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Share.share('Please complete your payment and tip for Order #${order.id}: $payUrl');
              },
              icon: const Icon(LucideIcons.share2, size: 16),
              label: const Text('Share Payment Link'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showCashPaymentDialog(BuildContext context, Order order) {
    final tipController = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Collect Cash - Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table: ${order.tableCode ?? 'N/A'}'),
            const SizedBox(height: 4),
            Text(
              'Subtotal: \$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Cash Tip Received (Optional):', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: tipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Tips are tracked to your staff profile. Cash must be remitted to the owner.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final tip = double.tryParse(tipController.text) ?? 0.0;
              Navigator.of(ctx).pop();
              final ok = await ref.read(ordersProvider.notifier).collectCashPayment(order.id, tipAmount: tip);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green.shade800,
                    content: Text('Payment marked as cash paid! (Tip: \$${tip.toStringAsFixed(2)})'),
                  ),
                );
              }
            },
            child: const Text('Confirm Cash Paid'),
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
  final VoidCallback onQuickAction;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.onTap,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    String timeFormatted = '';
    try {
      timeFormatted = DateFormat('hh:mm a').format(DateTime.parse(order.createdAt));
    } catch (_) {}

    final ks = order.kitchenStatus.toLowerCase();
    String quickActionLabel = '';
    IconData quickActionIcon = LucideIcons.chevronRight;
    Color quickActionColor = AppColors.primary;

    if (ks == 'pending' || ks == 'new' || ks.isEmpty) {
      quickActionLabel = 'Prepare';
      quickActionIcon = LucideIcons.utensils;
      quickActionColor = Colors.orange;
    } else if (ks == 'preparing' || ks == 'accepted') {
      quickActionLabel = 'Ready';
      quickActionIcon = LucideIcons.bell;
      quickActionColor = Colors.amber;
    } else if (ks == 'ready') {
      quickActionLabel = 'Serve';
      quickActionIcon = LucideIcons.check;
      quickActionColor = Colors.green;
    } else if (ks == 'served' && !order.isPaid) {
      quickActionLabel = 'Pay';
      quickActionIcon = LucideIcons.creditCard;
      quickActionColor = AppColors.primary;
    }

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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkElevated : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        order.tableCode != null ? order.tableCode! : (order.tableNumber ?? '?'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.tableCode != null ? 'Table ${order.tableCode}' : 'Order #${order.id}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          if (order.needsRemittance) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'UNREMITTED',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ),
                          ],
                        ],
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
                  if (order.tipAmount > 0)
                    Text(
                      '+\$${order.tipAmount.toStringAsFixed(2)} tip',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber),
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

          if (quickActionLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onQuickAction,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: quickActionColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: quickActionColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(quickActionIcon, size: 12, color: quickActionColor),
                        const SizedBox(width: 4),
                        Text(
                          quickActionLabel,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: quickActionColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Modal for Waitstaff taking in-house table orders
class _TakeInHouseOrderModal extends ConsumerStatefulWidget {
  final Future<void> Function(String tableCode, List<Map<String, dynamic>> items, String? customerName) onSubmit;

  const _TakeInHouseOrderModal({required this.onSubmit});

  @override
  ConsumerState<_TakeInHouseOrderModal> createState() => _TakeInHouseOrderModalState();
}

class _TakeInHouseOrderModalState extends ConsumerState<_TakeInHouseOrderModal> {
  final _tableCodeController = TextEditingController(text: 'T-1');
  final _customerNameController = TextEditingController();
  final Map<int, int> _selectedQuantities = {};
  bool _submitting = false;

  final List<String> _tableSuggestions = ['T-1', 'T-2', 'T-3', 'T-4', 'T-5', 'T-6', 'Bar-1', 'Patio-1'];

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allItems = menuState.categories.expand((c) => c.items).where((i) => i.isAvailable).toList();

    double currentTotal = 0;
    int totalItemsCount = 0;
    _selectedQuantities.forEach((itemId, qty) {
      if (qty > 0) {
        final item = allItems.firstWhere((i) => i.id == itemId, orElse: () => MenuItem(id: 0, categoryId: 0, name: '', price: 0));
        currentTotal += item.price * qty;
        totalItemsCount += qty;
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Take In-House Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Table Code Input & Chips
                const Text('Table Code / Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _tableCodeController,
                  decoration: InputDecoration(
                    hintText: 'e.g. T-4, Table 12',
                    prefixIcon: const Icon(LucideIcons.hash, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tableSuggestions.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        onPressed: () => setState(() => _tableCodeController.text = t),
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Customer Name (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    hintText: 'Guest Name',
                    prefixIcon: const Icon(LucideIcons.user, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Dishes from Menu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${allItems.length} items', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),

                if (menuState.isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (allItems.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No menu items available. Please add items in the Menu manager.', textAlign: TextAlign.center),
                  ),
                ] else ...[
                  ...allItems.map((item) {
                    final qty = _selectedQuantities[item.id] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkElevated : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: qty > 0 ? AppColors.primary : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          width: qty > 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.minusCircle, size: 20),
                                onPressed: qty > 0
                                    ? () => setState(() => _selectedQuantities[item.id] = qty - 1)
                                    : null,
                              ),
                              Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(LucideIcons.plusCircle, size: 20, color: AppColors.primary),
                                onPressed: () => setState(() => _selectedQuantities[item.id] = qty + 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          // Sticky Bottom Summary & Submit Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(top: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$totalItemsCount Items selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '\$${currentTotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (totalItemsCount > 0 && !_submitting)
                        ? () async {
                            final tableCode = _tableCodeController.text.trim();
                            if (tableCode.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a Table Code')),
                              );
                              return;
                            }

                            final itemsPayload = _selectedQuantities.entries
                                .where((e) => e.value > 0)
                                .map((e) => {'menu_item_id': e.key, 'quantity': e.value})
                                .toList();

                            setState(() => _submitting = true);
                            await widget.onSubmit(tableCode, itemsPayload, _customerNameController.text.trim());
                            if (mounted) setState(() => _submitting = false);
                          }
                        : null,
                    icon: _submitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(LucideIcons.send, size: 16),
                    label: Text(_submitting ? 'Sending...' : 'Send to Kitchen'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
