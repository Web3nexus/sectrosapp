class Order {
  final int id;
  final String? tableNumber;
  final String? tableCode;
  final String status;
  final String kitchenStatus;
  final String paymentStatus;
  final String? paymentMethod;
  final double totalAmount;
  final double tipAmount;
  final bool cashRemitted;
  final int? staffProfileId;
  final String? staffName;
  final String? customerName;
  final String? diningMode;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    this.tableNumber,
    this.tableCode,
    required this.status,
    required this.kitchenStatus,
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    required this.totalAmount,
    this.tipAmount = 0.0,
    this.cashRemitted = false,
    this.staffProfileId,
    this.staffName,
    this.customerName,
    this.diningMode,
    required this.createdAt,
    this.items = const [],
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isCash => (paymentMethod ?? '').toLowerCase() == 'cash';
  bool get needsRemittance => isPaid && isCash && !cashRemitted;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final rawAmount = json['total_amount'] ?? json['total'] ?? 0;
    final totalAmount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse('$rawAmount') ?? 0.0);
    final rawTip = json['tip_amount'] ?? 0;
    final tipAmount = rawTip is num ? rawTip.toDouble() : (double.tryParse('$rawTip') ?? 0.0);

    String? resolvedTableCode = json['table_code']?.toString();
    String? resolvedTableNum = json['table'] is Map 
        ? json['table']['name']?.toString() 
        : json['restaurant_table_id']?.toString();

    String? staffName;
    if (json['staff'] is Map) {
      if (json['staff']['user'] is Map) {
        staffName = json['staff']['user']['name']?.toString();
      } else {
        staffName = json['staff']['name']?.toString();
      }
    }

    return Order(
      id: id,
      tableNumber: resolvedTableNum,
      tableCode: resolvedTableCode ?? resolvedTableNum,
      status: (json['status'] ?? 'pending').toString(),
      kitchenStatus: (json['kitchen_status'] ?? 'pending').toString(),
      paymentStatus: (json['payment_status'] ?? 'unpaid').toString(),
      paymentMethod: json['payment_method']?.toString(),
      totalAmount: totalAmount,
      tipAmount: tipAmount,
      cashRemitted: json['cash_remitted'] == true || json['cash_remitted'] == 1,
      staffProfileId: json['staff_profile_id'] != null ? int.tryParse('${json['staff_profile_id']}') : null,
      staffName: staffName,
      customerName: json['customer_name']?.toString(),
      diningMode: json['dining_mode']?.toString(),
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
  final int? menuItemId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    this.menuItemId,
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
    final menuItemId = json['menu_item_id'] != null ? int.tryParse('${json['menu_item_id']}') : null;

    return OrderItem(
      id: id,
      menuItemId: menuItemId,
      name: (json['menu_item'] is Map ? json['menu_item']['name'] : json['name'] ?? 'Item').toString(),
      quantity: quantity,
      price: price,
    );
  }
}
