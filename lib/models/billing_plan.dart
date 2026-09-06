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
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    final rawPrice = json['price'];
    final price = rawPrice is num ? rawPrice.toDouble() : (double.tryParse('$rawPrice') ?? 0.0);

    final rawFeatures = json['features'];
    List<String> features = [];
    if (rawFeatures is List) {
      features = rawFeatures.map((e) => e.toString()).toList();
    } else if (rawFeatures is Map) {
      features = rawFeatures.entries
          .where((e) => e.value == true || e.value == 1 || e.value == '1' || e.value is String)
          .map((e) => e.key.toString().replaceAll('_', ' '))
          .toList();
    }

    return BillingPlan(
      id: id,
      name: (json['name'] ?? 'Plan').toString(),
      description: json['description']?.toString(),
      price: price,
      interval: (json['interval'] ?? 'month').toString(),
      features: features,
      isCurrent: json['is_current'] == true || json['is_current'] == 1 || json['is_current'] == '1',
    );
  }
}
