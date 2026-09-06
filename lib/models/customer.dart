class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int totalBookings;
  final String? lastVisit;
  final String status; // vip, regular, new
  final String? notes;
  final double totalSpend;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.totalBookings = 1,
    this.lastVisit,
    this.status = 'regular',
    this.notes,
    this.totalSpend = 0.0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? json['customer_name'] ?? 'Guest',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      totalBookings: json['total_bookings'] is int ? json['total_bookings'] : int.tryParse('${json['total_bookings']}') ?? 1,
      lastVisit: json['last_visit'] ?? json['updated_at'],
      status: json['status'] ?? (json['is_vip'] == true ? 'vip' : 'regular'),
      notes: json['notes'] ?? json['special_requests'],
      totalSpend: json['total_spend'] is num ? (json['total_spend'] as num).toDouble() : double.tryParse('${json['total_spend']}') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'total_bookings': totalBookings,
    'last_visit': lastVisit,
    'status': status,
    'notes': notes,
    'total_spend': totalSpend,
  };
}
