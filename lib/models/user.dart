import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String businessType;
  final List<String> features;
  final String plan;
  final String? platformName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.businessType,
    this.features = const [],
    this.plan = 'free',
    this.platformName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'staff',
      businessType: json['business_type'] ?? 'restaurant',
      features: json['features'] is List
          ? List<String>.from((json['features'] as List).map((e) => e.toString()))
          : [],
      plan: json['plan'] ?? 'free',
      platformName: json['platform_name'],
    );
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get isStaff => !isOwner && !isAdmin;

  bool hasFeature(String feature) => features.contains(feature);
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void logout() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
