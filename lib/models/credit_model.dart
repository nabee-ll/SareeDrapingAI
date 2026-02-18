class CreditTransaction {
  final String id;
  final String userId;
  final int amount; // positive = purchased, negative = spent
  final String type; // 'purchase', 'ai_draping', 'stylish', 'refund'
  final String description;
  final DateTime createdAt;
  final String? paymentId; // Razorpay payment ID for purchases
  final String? orderId;   // Razorpay order ID

  CreditTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    this.paymentId,
    this.orderId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'type': type,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'payment_id': paymentId,
        'order_id': orderId,
      };

  factory CreditTransaction.fromJson(Map<String, dynamic> json) =>
      CreditTransaction(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        amount: json['amount'] ?? 0,
        type: json['type'] ?? 'purchase',
        description: json['description'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        paymentId: json['payment_id'],
        orderId: json['order_id'],
      );
}

/// Credit packs available for purchase via Razorpay
class CreditPack {
  final String id;
  final String name;
  final int credits;
  final int priceInPaise; // price in paise (₹1 = 100 paise)
  final String bonus;
  final bool isBestValue;
  final int sortOrder;

  const CreditPack({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceInPaise,
    this.bonus = '',
    this.isBestValue = false,
    this.sortOrder = 0,
  });

  int get priceInRupees => priceInPaise ~/ 100;
  double get pricePerCredit => priceInPaise / 100 / credits;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'credits': credits,
        'price_in_paise': priceInPaise,
        'bonus': bonus,
        'is_best_value': isBestValue,
        'sort_order': sortOrder,
      };

  factory CreditPack.fromJson(Map<String, dynamic> json) => CreditPack(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        credits: json['credits'] ?? 0,
        priceInPaise: json['price_in_paise'] ?? 0,
        bonus: json['bonus'] ?? '',
        isBestValue: json['is_best_value'] ?? false,
        sortOrder: json['sort_order'] ?? 0,
      );
}

/// Predefined credit packs
const List<CreditPack> kCreditPacks = [
  CreditPack(
    id: 'starter',
    name: 'Starter',
    credits: 10,
    priceInPaise: 4900, // ₹49
    bonus: '',
  ),
  CreditPack(
    id: 'popular',
    name: 'Popular',
    credits: 50,
    priceInPaise: 19900, // ₹199
    bonus: '+5 Bonus',
    isBestValue: false,
  ),
  CreditPack(
    id: 'pro',
    name: 'Pro',
    credits: 120,
    priceInPaise: 39900, // ₹399
    bonus: '+20 Bonus',
    isBestValue: true,
  ),
  CreditPack(
    id: 'ultimate',
    name: 'Ultimate',
    credits: 300,
    priceInPaise: 79900, // ₹799
    bonus: '+50 Bonus',
    isBestValue: false,
  ),
];

/// How many credits each feature costs.
/// Default values are used as fallback; actual values are loaded from Firestore
/// (app_config/credits document: { ai_draping_cost, stylish_look_cost }).
class CreditCost {
  static int aiDraping = 5;
  static int stylishLook = 2;

  /// Update from Firestore app config
  static void updateFromConfig(Map<String, dynamic> config) {
    if (config['ai_draping_cost'] != null) {
      aiDraping = config['ai_draping_cost'] as int;
    }
    if (config['stylish_look_cost'] != null) {
      stylishLook = config['stylish_look_cost'] as int;
    }
  }
}
