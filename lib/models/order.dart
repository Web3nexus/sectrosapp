class Order {
  final int id;
  final String? tableNumber;
  final String status;
  final String kitchenStatus;
  final double totalAmount;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    this.tableNumber,
    required this.status,
    required this.kitchenStatus,
    required this.totalAmount,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final rawAmount = json['total_amount'] ?? json['total'] ?? 0;
    final totalAmount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse('$rawAmount') ?? 0.0);

    return Order(
      id: id,
      tableNumber: json['table'] is Map ? json['table']['name']?.toString() : json['restaurant_table_id']?.toString(),
      status: (json['status'] ?? 'pending').toString(),
      kitchenStatus: (json['kitchen_status'] ?? 'pending').toString(),
      totalAmount: totalAmount,
      createdAt: (json['created_at'] ?? '').toString(),
      items: (json['items'] as List?)
              ?.whereType<Map>()
              .map((i) => OrderItem.fromJson(Map<String, dynamic>.from(i)))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final rawQty = json['quantity'] ?? 1;
    final quantity = rawQty is int ? rawQty : (int.tryParse('$rawQty') ?? 1);
    final rawPrice = json['unit_price'] ?? json['price'] ?? 0;
    final price = rawPrice is num ? rawPrice.toDouble() : (double.tryParse('$rawPrice') ?? 0.0);

    return OrderItem(
      id: id,
      name: (json['menu_item'] is Map ? json['menu_item']['name'] : json['name'] ?? 'Item').toString(),
      quantity: quantity,
      price: price,
    );
  }
}
