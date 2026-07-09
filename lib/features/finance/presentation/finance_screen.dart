import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/transaction_entry.dart';
import '../../../models/settlement_record.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/error_view.dart';
import 'finance_notifier.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Finance'), centerTitle: true),
      body: state.isLoading && state.overview == null
          ? const Center(child: SkeletonLoader(type: SkeletonType.card))
          : state.error != null && state.overview == null
              ? ErrorView(message: state.error!, onRetry: () => ref.read(financeProvider.notifier).fetchAll())
              : _buildContent(context, ref, state, theme),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, FinanceState state, ThemeData theme) {
    final overview = state.overview;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFmt = DateFormat('MMM d, yyyy');

    return RefreshIndicator(
      onRefresh: () => ref.read(financeProvider.notifier).fetchAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (overview != null) ...[
            _BalanceCard(
              balance: overview.balance,
              date: overview.latestSettlement != null
                  ? dateFmt.format(DateTime.parse(overview.latestSettlement!.date))
                  : null,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _KpiRow(
              revenue: overview.totalRevenue,
              expenses: overview.totalExpenses,
              profit: overview.netProfit,
              margin: overview.profitMargin,
              theme: theme,
            ),
            const SizedBox(height: 12),
            if (overview.orderCount > 0)
              _MetaRow(
                orders: overview.orderCount,
                aov: overview.aov,
                theme: theme,
              ),
            if (state.transactions.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader(icon: LucideIcons.list, title: 'Recent Transactions', theme: theme),
              const SizedBox(height: 8),
              ...state.transactions.take(10).map((tx) => _TransactionTile(tx: tx, fmt: fmt, theme: theme)),
            ],
            if (state.settlements.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader(icon: LucideIcons.banknote, title: 'Daily Settlements', theme: theme),
              const SizedBox(height: 8),
              ...state.settlements.take(5).map((s) => _SettlementTile(s: s, fmt: fmt, dateFmt: dateFmt, theme: theme)),
            ],
          ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final String? date;
  final ThemeData theme;
  const _BalanceCard({required this.balance, this.date, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.wallet, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text('BALANCE', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(balance),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
          if (date != null) ...[
            const SizedBox(height: 4),
            Text('As of $date', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final double revenue;
  final double expenses;
  final double profit;
  final double margin;
  final ThemeData theme;
  const _KpiRow({required this.revenue, required this.expenses, required this.profit, required this.margin, required this.theme});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Row(
      children: [
        Expanded(child: _KpiCard(icon: LucideIcons.trendingUp, label: 'Revenue', value: fmt.format(revenue), color: const Color(0xFF2563EB), theme: theme)),
        const SizedBox(width: 8),
        Expanded(child: _KpiCard(icon: LucideIcons.trendingDown, label: 'Expenses', value: fmt.format(expenses), color: const Color(0xFFDC2626), theme: theme)),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            icon: LucideIcons.dollarSign,
            label: 'Profit',
            value: fmt.format(profit),
            color: margin >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
            theme: theme,
            badge: '${margin >= 0 ? '+' : ''}${margin.toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;
  final String? badge;
  const _KpiCard({required this.icon, required this.label, required this.value, required this.color, required this.theme, this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(badge!, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final int orders;
  final double aov;
  final ThemeData theme;
  const _MetaRow({required this.orders, required this.aov, required this.theme});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MetaChip(icon: LucideIcons.shoppingCart, label: '$orders Orders', theme: theme),
          const SizedBox(width: 24),
          _MetaChip(icon: LucideIcons.barChart2, label: '${fmt.format(aov)} AOV', theme: theme),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  const _MetaChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedForeground),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
      ],
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

class _TransactionTile extends StatelessWidget {
  final TransactionEntry tx;
  final NumberFormat fmt;
  final ThemeData theme;
  const _TransactionTile({required this.tx, required this.fmt, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = tx.isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final dateStr = tx.date.length >= 10 ? tx.date.substring(0, 10) : tx.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(tx.isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(dateStr, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mutedForeground.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(tx.category, style: TextStyle(fontSize: 9, color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${tx.isIncome ? '+' : '-'}${fmt.format(tx.amount)}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  final SettlementRecord s;
  final NumberFormat fmt;
  final DateFormat dateFmt;
  final ThemeData theme;
  const _SettlementTile({required this.s, required this.fmt, required this.dateFmt, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.banknote, color: theme.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateFmt.format(DateTime.parse(s.date)), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (s.staff != null) Text(s.staff!.name, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Close: ${fmt.format(s.closingBalance)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  if (s.netTotal != null)
                    Text(
                      'Net: ${fmt.format(s.netTotal!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: s.netTotal! >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Chip(label: 'Cash ${fmt.format(s.cashCollected ?? 0)}', theme: theme),
              const SizedBox(width: 8),
              _Chip(label: 'Card ${fmt.format(s.cardCollected ?? 0)}', theme: theme),
              const SizedBox(width: 8),
              if ((s.tipsCollected ?? 0) > 0) _Chip(label: 'Tips ${fmt.format(s.tipsCollected!)}', theme: theme),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _Chip({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mutedForeground.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
    );
  }
}
