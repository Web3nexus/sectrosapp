import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/transaction_entry.dart';
import '../../../models/settlement_record.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/design_system/metric_card.dart';
import 'finance_notifier.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Finance & Cash Book'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(financeProvider.notifier).fetchAll();
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: state.isLoading && state.overview == null
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.pagePadding),
              child: SkeletonLoader(type: SkeletonType.card, itemCount: 4),
            )
          : state.error != null && state.overview == null
              ? Center(
                  child: ErrorView(
                    message: state.error!,
                    onRetry: () => ref.read(financeProvider.notifier).fetchAll(),
                  ),
                )
              : _buildContent(context, ref, state, isDark),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, FinanceState state, bool isDark) {
    final overview = state.overview;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFmt = DateFormat('MMM d, yyyy');

    if (overview == null) {
      return const Center(
        child: EmptyState(
          icon: LucideIcons.dollarSign,
          title: 'No financial data',
          subtitle: 'Daily settlements and ledger records will appear here',
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await ref.read(financeProvider.notifier).fetchAll();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.s8, AppSpacing.pagePadding, 100),
        children: [
          // Dark Navy Contextual Card: Main Balance
          AppNavyCard(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: AppColors.navyCardTextMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(LucideIcons.wallet, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  fmt.format(overview.balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                if (overview.latestSettlement != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'As of ${dateFmt.format(DateTime.parse(overview.latestSettlement!.date))}',
                    style: const TextStyle(
                      color: AppColors.navyCardTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // 2x2 Metric Cards Grid
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Revenue',
                  value: fmt.format(overview.totalRevenue),
                  trend: '+${overview.profitMargin.toStringAsFixed(1)}%',
                  isPositiveTrend: overview.profitMargin >= 0,
                  icon: LucideIcons.trendingUp,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: MetricCard(
                  title: 'Expenses',
                  value: fmt.format(overview.totalExpenses),
                  subtitle: 'Operating costs',
                  icon: LucideIcons.trendingDown,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s12),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Net Profit',
                  value: fmt.format(overview.netProfit),
                  subtitle: 'Operating margin',
                  icon: LucideIcons.dollarSign,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: MetricCard(
                  title: 'Avg Order',
                  value: fmt.format(overview.aov),
                  subtitle: '${overview.orderCount} total orders',
                  icon: LucideIcons.shoppingBag,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s24),

          // Recent Transactions Section
          if (state.transactions.isNotEmpty) ...[
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            ...state.transactions.take(10).map((tx) => _TransactionCard(tx: tx, fmt: fmt, isDark: isDark)),
            const SizedBox(height: AppSpacing.s16),
          ],

          // Daily Settlements Section
          if (state.settlements.isNotEmpty) ...[
            Text(
              'Daily Settlements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            ...state.settlements.take(5).map((s) => _SettlementCard(s: s, fmt: fmt, dateFmt: dateFmt, isDark: isDark)),
          ],
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntry tx;
  final NumberFormat fmt;
  final bool isDark;

  const _TransactionCard({required this.tx, required this.fmt, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.isIncome;
    final color = isIncome ? AppColors.success : AppColors.error;
    final dateStr = tx.date.length >= 10 ? tx.date.substring(0, 10) : tx.date;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isIncome ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tx.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${fmt.format(tx.amount)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final SettlementRecord s;
  final NumberFormat fmt;
  final DateFormat dateFmt;
  final bool isDark;

  const _SettlementCard({required this.s, required this.fmt, required this.dateFmt, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.s14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkElevated : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    LucideIcons.banknote,
                    color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFmt.format(DateTime.parse(s.date)),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      if (s.staff != null)
                        Text(
                          'Closed by ${s.staff!.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmt.format(s.closingBalance),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    if (s.netTotal != null)
                      Text(
                        'Net: ${fmt.format(s.netTotal!)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: s.netTotal! >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s10),
            Row(
              children: [
                _MiniTag(label: 'Cash: ${fmt.format(s.cashCollected ?? 0)}', isDark: isDark),
                const SizedBox(width: 8),
                _MiniTag(label: 'Card: ${fmt.format(s.cardCollected ?? 0)}', isDark: isDark),
                if ((s.tipsCollected ?? 0) > 0) ...[
                  const SizedBox(width: 8),
                  _MiniTag(label: 'Tips: ${fmt.format(s.tipsCollected!)}', isDark: isDark),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final bool isDark;

  const _MiniTag({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
