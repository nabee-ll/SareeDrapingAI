class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle; // 'free', 'monthly', 'quarterly', 'annual'
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.features,
    this.isPopular = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'billing_cycle': billingCycle,
      'features': features,
      'is_popular': isPopular,
    };
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      billingCycle: json['billing_cycle'] ?? 'free',
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['is_popular'] ?? false,
    );
  }
}
