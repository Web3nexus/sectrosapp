class Reservation {
  final int id;
  final String customerName;
  final String? tableNumber;
  final String date;
  final String time;
  final int guests;
  final String status; // confirmed, pending, cancelled, arrived
  final String? phone;
  final String? email;
  final String? notes;

  Reservation({
    required this.id,
    required this.customerName,
    this.tableNumber,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
    this.phone,
    this.email,
    this.notes,
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

    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);

    final rawGuests = json['party_size'] ?? json['guests'];
    final guests = rawGuests is int ? rawGuests : (int.tryParse('$rawGuests') ?? 0);

    return Reservation(
      id: id,
      customerName: (json['customer_name'] ?? 'Guest').toString(),
      tableNumber: json['table'] is Map ? json['table']['name']?.toString() : json['restaurant_table_id']?.toString(),
      date: (json['reservation_date'] ?? dateVal).toString(),
      time: timeVal.isNotEmpty ? timeVal : (json['reservation_time'] ?? '').toString(),
      guests: guests,
      status: (json['status'] ?? 'pending').toString(),
      phone: json['phone']?.toString() ?? json['customer_phone']?.toString(),
      email: json['email']?.toString() ?? json['customer_email']?.toString(),
      notes: json['notes']?.toString() ?? json['special_requests']?.toString(),
    );
  }
}
