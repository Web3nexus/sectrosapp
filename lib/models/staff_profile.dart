class StaffProfile {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final bool isActive;
  final String? avatarUrl;

  StaffProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role = 'waiter',
    this.isActive = true,
    this.avatarUrl,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) {
    return StaffProfile(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'waiter',
      isActive: json['is_active'] ?? true,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'is_active': isActive,
  };
}
