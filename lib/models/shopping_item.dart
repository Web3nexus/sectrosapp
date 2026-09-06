class ShoppingItem {
  final int id;
  final String name;
  final String? notes;
  final String? unit;
  final double? quantity;
  final bool isPurchased;
  final String? addedBy;
  final DateTime? createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.notes,
    this.unit,
    this.quantity,
    this.isPurchased = false,
    this.addedBy,
    this.createdAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final name = (json['item_name'] ?? json['name'] ?? '').toString();
    final isPurchased = json['is_purchased'] == true ||
        json['is_purchased'] == 1 ||
        json['is_purchased'] == '1' ||
        json['status'] == 'purchased';

    return ShoppingItem(
      id: id,
      name: name,
      notes: json['notes'] as String?,
      unit: json['unit'] as String?,
      quantity: json['quantity'] != null
          ? double.tryParse('${json['quantity']}')
          : null,
      isPurchased: isPurchased,
      addedBy: json['added_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (notes != null) 'notes': notes,
    if (unit != null) 'unit': unit,
    if (quantity != null) 'quantity': quantity,
    'is_purchased': isPurchased,
  };

  ShoppingItem copyWith({
    int? id,
    String? name,
    String? notes,
    String? unit,
    double? quantity,
    bool? isPurchased,
    String? addedBy,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      isPurchased: isPurchased ?? this.isPurchased,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
