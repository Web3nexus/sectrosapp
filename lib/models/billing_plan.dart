class BillingPlan {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String interval;
  final List<String> features;
  final bool isCurrent;

  BillingPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.interval,
    this.features = const [],
    this.isCurrent = false,
  });

  factory BillingPlan.fromJson(Map<String, dynamic> json) {
    return BillingPlan(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is double ? json['price'] : double.parse('${json['price'] ?? 0}')),
      interval: json['interval'] ?? 'month',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isCurrent: json['is_current'] == true || json['is_current'] == 1,
    );
  }
}
