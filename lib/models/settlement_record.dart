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

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  factory SettlementRecord.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);

    return SettlementRecord(
      id: id,
      date: (json['date'] ?? '').toString(),
      openingBalance: _toDouble(json['opening_balance']) ?? 0.0,
      closingBalance: _toDouble(json['closing_balance']) ?? 0.0,
      cashCollected: _toDouble(json['cash_collected']),
      cardCollected: _toDouble(json['card_collected']),
      tipsCollected: _toDouble(json['tips_collected']),
      expensesTotal: _toDouble(json['expenses_total']),
      netTotal: _toDouble(json['net_total']),
      discrepancy: _toDouble(json['discrepancy']),
      notes: json['notes']?.toString(),
      staff: json['staff'] is Map ? StaffInfo.fromJson(Map<String, dynamic>.from(json['staff'])) : null,
    );
  }
}

class StaffInfo {
  final int id;
  final String name;

  StaffInfo({required this.id, required this.name});

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    return StaffInfo(
      id: id,
      name: (json['name'] ?? '').toString(),
    );
  }
}
