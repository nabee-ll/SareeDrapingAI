import '../core/config/api_config.dart';
import '../models/credit_model.dart';
import 'api_client.dart';

class CreditService {
  const CreditService();
  static final _api = ApiClient.instance;

  Future<int> getBalance() async {
    final res = await _api.get(ApiConfig.credits);
    if (res.ok && res.data is Map) {
      return (res.data['balance'] as int?) ?? 0;
    }
    return 0;
  }

  Future<List<CreditTransaction>> getHistory() async {
    final res = await _api.get(ApiConfig.creditHistory);
    if (res.ok && res.data is List) {
      return (res.data as List)
          .map((e) => CreditTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Creates a Stripe Checkout session. Returns the checkout URL.
  Future<String?> createCheckoutSession(CreditPack pack) async {
    final res = await _api.post(
      ApiConfig.createCheckout,
      {'pack_id': pack.id},
    );
    if (res.ok && res.data is Map) {
      return res.data['url'] as String?;
    }
    return null;
  }
}
