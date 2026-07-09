class SettlementRecord {
  final int id;
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
  final StaffInfo? staff;

  SettlementRecord({
    required this.id,
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
    this.staff,
  });

  factory SettlementRecord.fromJson(Map<String, dynamic> json) {
    return SettlementRecord(
      id: json['id'] ?? 0,
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
      staff: json['staff'] != null ? StaffInfo.fromJson(json['staff']) : null,
    );
  }
}

class StaffInfo {
  final int id;
  final String name;

  StaffInfo({required this.id, required this.name});

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    return StaffInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
