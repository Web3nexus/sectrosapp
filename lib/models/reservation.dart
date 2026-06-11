class Reservation {
  final int id;
  final String customerName;
  final String? tableNumber;
  final String date;
  final String time;
  final int guests;
  final String status; // confirmed, pending, cancelled, arrived

  Reservation({
    required this.id,
    required this.customerName,
    this.tableNumber,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      customerName: json['customer_name'] ?? 'Guest',
      tableNumber: json['table']?['name'] ?? json['restaurant_table_id']?.toString(),
      date: json['reservation_date'],
      time: json['reservation_time'],
      guests: json['guests'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }
}
