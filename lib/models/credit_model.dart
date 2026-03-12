class CreditTransaction {
  final String id;
  final String userId;
  final int amount; // positive = purchased, negative = spent
  final String type; // 'purchase', 'tryon', 'refund', 'free_grant'
  final String description;
  final DateTime createdAt;
  final String? stripeSessionId;

  CreditTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    this.stripeSessionId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'type': type,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'stripe_session_id': stripeSessionId,
      };

  factory CreditTransaction.fromJson(Map<String, dynamic> json) =>
      CreditTransaction(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        type: json['type']?.toString() ?? 'purchase',
        description: json['description']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        stripeSessionId: json['stripe_session_id']?.toString(),
      );
}

/// Credit bundles available for purchase via Stripe Checkout.
/// As defined in the platform architecture.
class CreditPack {
  final String id;
  final String name;
  final int credits;
  final double priceUsd;
  final String bonus;
  final bool isBestValue;

  const CreditPack({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceUsd,
    this.bonus = '',
    this.isBestValue = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'credits': credits,
        'price_usd': priceUsd,
        'bonus': bonus,
        'is_best_value': isBestValue,
      };

  factory CreditPack.fromJson(Map<String, dynamic> json) => CreditPack(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        credits: (json['credits'] as num?)?.toInt() ?? 0,
        priceUsd: (json['price_usd'] as num?)?.toDouble() ?? 0.0,
        bonus: json['bonus']?.toString() ?? '',
        isBestValue: json['is_best_value'] as bool? ?? false,
      );
}

/// Platform-defined credit bundles (architecture section 6).
const List<CreditPack> kCreditPacks = [
  CreditPack(
    id: 'pack_10',
    name: 'Starter',
    credits: 10,
    priceUsd: 4.99,
  ),
  CreditPack(
    id: 'pack_50',
    name: 'Popular',
    credits: 50,
    priceUsd: 19.99,
    bonus: 'Best Value',
    isBestValue: true,
  ),
  CreditPack(
    id: 'pack_200',
    name: 'Pro',
    credits: 200,
    priceUsd: 59.99,
    bonus: 'Most Credits',
  ),
];

/// Credit cost per feature.
class CreditCost {
  static const int tryOn = 1; // 1 credit per virtual try-on job
}
