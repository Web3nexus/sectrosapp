class TableModel {
  final int id;
  final String name;
  final int capacity;
  final String status; // available, occupied, reserved
  final String? currentOrderId;

  TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    this.currentOrderId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? 'available',
      currentOrderId: json['current_order_id']?.toString(),
    );
  }
}
