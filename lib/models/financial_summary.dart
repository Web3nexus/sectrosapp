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

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      balance: _toDouble(json['balance']),
      totalRevenue: _toDouble(json['total_revenue']),
      totalExpenses: _toDouble(json['total_expenses']),
      netProfit: _toDouble(json['net_profit']),
      orderCount: _toInt(json['order_count']),
      aov: _toDouble(json['aov']),
      profitMargin: _toDouble(json['profit_margin']),
      categoryBreakdown: (json['category_breakdown'] as List?)
              ?.whereType<Map>()
              .map((e) => CategoryBreakdown.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      latestSettlement: json['latest_settlement'] is Map
          ? SettlementData.fromJson(Map<String, dynamic>.from(json['latest_settlement']))
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
      category: (json['category'] ?? 'Other').toString(),
      total: FinancialSummary._toDouble(json['total']),
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
      date: (json['date'] ?? '').toString(),
      openingBalance: FinancialSummary._toDouble(json['opening_balance']),
      closingBalance: FinancialSummary._toDouble(json['closing_balance']),
      cashCollected: json['cash_collected'] != null ? FinancialSummary._toDouble(json['cash_collected']) : null,
      cardCollected: json['card_collected'] != null ? FinancialSummary._toDouble(json['card_collected']) : null,
      tipsCollected: json['tips_collected'] != null ? FinancialSummary._toDouble(json['tips_collected']) : null,
      expensesTotal: json['expenses_total'] != null ? FinancialSummary._toDouble(json['expenses_total']) : null,
      netTotal: json['net_total'] != null ? FinancialSummary._toDouble(json['net_total']) : null,
      discrepancy: json['discrepancy'] != null ? FinancialSummary._toDouble(json['discrepancy']) : null,
      notes: json['notes']?.toString(),
    );
  }
}
