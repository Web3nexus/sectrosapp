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
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final rawCap = json['capacity'] ?? json['seats'];
    final capacity = rawCap is int ? rawCap : (int.tryParse('$rawCap') ?? 0);

    return TableModel(
      id: id,
      name: (json['name'] ?? 'Table $id').toString(),
      capacity: capacity,
      status: (json['status'] ?? 'available').toString(),
      currentOrderId: json['current_order_id']?.toString(),
    );
  }
}
