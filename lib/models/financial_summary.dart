class FinancialSummary {
  final double balance;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int orderCount;
  final double aov;
  final double profitMargin;
  final List<CategoryBreakdown> categoryBreakdown;
  final SettlementData? latestSettlement;

  FinancialSummary({
    required this.balance,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.orderCount,
    required this.aov,
    required this.profitMargin,
    required this.categoryBreakdown,
    this.latestSettlement,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      balance: (json['balance'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      orderCount: (json['order_count'] ?? 0).toInt(),
      aov: (json['aov'] ?? 0).toDouble(),
      profitMargin: (json['profit_margin'] ?? 0).toDouble(),
      categoryBreakdown: (json['category_breakdown'] as List?)
              ?.map((e) => CategoryBreakdown.fromJson(e))
              .toList() ??
          [],
      latestSettlement: json['latest_settlement'] != null
          ? SettlementData.fromJson(json['latest_settlement'])
          : null,
    );
  }
}

class CategoryBreakdown {
  final String category;
  final double total;

  CategoryBreakdown({required this.category, required this.total});

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] ?? 'Other',
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class SettlementData {
  final String date;
  final double openingBalance;
  final double closingBalance;
  final double? cashCollected;
  final double? cardCollected;
  final double? tipsCollected;
  final double? expensesTotal;
  final double? netTotal;
  final double? discrepancy;
  final String? notes;

  SettlementData({
    required this.date,
    required this.openingBalance,
    required this.closingBalance,
    this.cashCollected,
    this.cardCollected,
    this.tipsCollected,
    this.expensesTotal,
    this.netTotal,
    this.discrepancy,
    this.notes,
  });

  factory SettlementData.fromJson(Map<String, dynamic> json) {
    return SettlementData(
      date: json['date'] ?? '',
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      closingBalance: (json['closing_balance'] ?? 0).toDouble(),
      cashCollected: (json['cash_collected'] ?? 0).toDouble(),
      cardCollected: (json['card_collected'] ?? 0).toDouble(),
      tipsCollected: (json['tips_collected'] ?? 0).toDouble(),
      expensesTotal: (json['expenses_total'] ?? 0).toDouble(),
      netTotal: (json['net_total'] ?? 0).toDouble(),
      discrepancy: (json['discrepancy'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }
}
