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
    final rawTime = json['reservation_time'] ?? '';
    String dateVal = '';
    String timeVal = '';
    if (rawTime is String && rawTime.isNotEmpty) {
      if (rawTime.contains('T')) {
        final parts = rawTime.split('T');
        dateVal = parts[0];
        if (parts.length > 1) {
          timeVal = parts[1].split('.')[0]; // remove milliseconds
        }
      } else if (rawTime.contains(' ')) {
        final parts = rawTime.split(' ');
        dateVal = parts[0];
        timeVal = parts[1];
      } else {
        dateVal = rawTime;
      }
      if (timeVal.length > 5) {
        timeVal = timeVal.substring(0, 5);
      }
    }

    return Reservation(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? 'Guest',
      tableNumber: json['table']?['name'] ?? json['restaurant_table_id']?.toString(),
      date: json['reservation_date'] ?? dateVal,
      time: timeVal.isNotEmpty ? timeVal : (json['reservation_time'] ?? ''),
      guests: json['party_size'] ?? json['guests'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }
}
