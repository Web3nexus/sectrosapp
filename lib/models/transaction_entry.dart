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
    return TransactionEntry(
      id: json['id'] ?? '',
      type: json['type'] ?? 'income',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      category: json['category'] ?? 'Other',
      status: json['status'] ?? 'paid',
    );
  }

  bool get isIncome => type == 'income';
}
