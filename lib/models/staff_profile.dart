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
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final rawActive = json['is_active'];
    final isActive = rawActive == null ? true : (rawActive == true || rawActive == 1 || rawActive == '1');

    return StaffProfile(
      id: id,
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: (json['role'] ?? 'waiter').toString(),
      isActive: isActive,
      avatarUrl: json['avatar_url']?.toString(),
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
