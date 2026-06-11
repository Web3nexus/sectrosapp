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
    return Order(
      id: json['id'],
      tableNumber: json['table']?['name'] ?? json['restaurant_table_id']?.toString(),
      status: json['status'],
      kitchenStatus: json['kitchen_status'] ?? 'pending',
      totalAmount: double.parse(json['total_amount'].toString()),
      createdAt: json['created_at'],
      items: (json['items'] as List?)
              ?.map((i) => OrderItem.fromJson(i))
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
    return OrderItem(
      id: json['id'],
      name: json['menu_item']?['name'] ?? 'Item',
      quantity: json['quantity'],
      price: double.parse(json['unit_price'].toString()),
    );
  }
}
