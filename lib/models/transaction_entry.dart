class TransactionEntry {
  final String id;
  final String type;
  final String description;
  final double amount;
  final String date;
  final String category;
  final String status;

  TransactionEntry({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.status,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? 0;
    final amount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse('$rawAmount') ?? 0.0);

    return TransactionEntry(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'income').toString(),
      description: (json['description'] ?? '').toString(),
      amount: amount,
      date: (json['date'] ?? '').toString(),
      category: (json['category'] ?? 'Other').toString(),
      status: (json['status'] ?? 'paid').toString(),
    );
  }

  bool get isIncome => type == 'income';
}
