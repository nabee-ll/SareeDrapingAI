import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/credit_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';

enum CreditState { idle, loading, processing, insufficientCredits, error }

class CreditProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  int _credits = 0;
  String? _loadedUserId; // guard against re-fetching for same user
  final List<CreditTransaction> _transactions = [];
  CreditState _state = CreditState.idle;
  String? _errorMessage;
  PaymentService? _paymentService;

  int get credits => _credits;
  List<CreditTransaction> get transactions =>
      List.unmodifiable(_transactions);
  CreditState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CreditState.loading || _state == CreditState.processing;

  // ─── Initialise / Load ──────────────────────────────────────────────────────

  void loadFromUser(UserModel user) {
    _credits = user.credits;
    notifyListeners();
  }

  /// Clear state on logout so the next user loads fresh data.
  void reset() {
    _credits = 0;
    _loadedUserId = null;
    _transactions.clear();
    _state = CreditState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Load credits balance and transaction history from Firestore.
  Future<void> loadForUser(String userId) async {
    if (_loadedUserId == userId) return; // already loaded
    _loadedUserId = userId;
    _state = CreditState.loading;
    notifyListeners();
    try {
      final userDoc = await _firestoreService.getUser(userId);
      if (userDoc != null) _credits = userDoc.credits;

      final txList = await _firestoreService.getTransactions(userId);
      _transactions
        ..clear()
        ..addAll(txList);

      _state = CreditState.idle;
    } catch (_) {
      _state = CreditState.idle;
    }
    notifyListeners();
  }

  // ─── Deduct credits for a feature ───────────────────────────────────────────

  /// Returns true if credits were successfully deducted.
  Future<bool> deductCredits({
    required String userId,
    required int cost,
    required String type,
    required String description,
  }) async {
    if (_credits < cost) {
      _state = CreditState.insufficientCredits;
      _errorMessage = 'Not enough credits. Please purchase more.';
      notifyListeners();
      return false;
    }
    _credits -= cost;
    final tx = CreditTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: -cost,
      type: type,
      description: description,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);
    _state = CreditState.idle;
    _errorMessage = null;
    notifyListeners();

    // Persist to Firestore
    try {
      await Future.wait([
        _firestoreService.updateUserCredits(userId, _credits),
        _firestoreService.saveTransaction(tx),
      ]);
    } catch (_) {
      // Non-blocking — local state is already updated
    }
    return true;
  }

  bool canAfford(int cost) => _credits >= cost;

  void clearError() {
    _state = CreditState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Purchase credits via Razorpay ──────────────────────────────────────────

  void purchaseCreditPack({
    required CreditPack pack,
    required String userId,
    String userName = '',
    String userEmail = '',
    String userPhone = '',
  }) {
    _state = CreditState.processing;
    _errorMessage = null;
    notifyListeners();

    _paymentService?.dispose();
    _paymentService = PaymentService(
      onSuccess: (response) => _onPaymentSuccess(
        response: response,
        pack: pack,
        userId: userId,
      ),
      onFailure: (response) => _onPaymentFailure(response),
      onExternalWallet: (response) => _onExternalWallet(response),
    );

    _paymentService!.openCreditCheckout(
      amountInPaise: pack.priceInPaise,
      description: '${pack.credits} AI Credits — ${pack.name} Pack',
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }

  Future<void> _onPaymentSuccess({
    required PaymentSuccessResponse response,
    required CreditPack pack,
    required String userId,
  }) async {
    // In production: verify signature on your server before crediting.
    final totalCredits = pack.credits;
    _credits += totalCredits;

    final tx = CreditTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: totalCredits,
      type: 'purchase',
      description: 'Purchased ${pack.name} Pack (×$totalCredits credits)',
      createdAt: DateTime.now(),
      paymentId: response.paymentId,
      orderId: response.orderId,
    );
    _transactions.insert(0, tx);

    _state = CreditState.idle;
    _errorMessage = null;
    notifyListeners();

    // Persist to Firestore
    try {
      await Future.wait([
        _firestoreService.updateUserCredits(userId, _credits),
        _firestoreService.saveTransaction(tx),
      ]);
    } catch (_) {}
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    _state = CreditState.error;
    _errorMessage = response.message ?? 'Payment failed. Please try again.';
    notifyListeners();
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _state = CreditState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentService?.dispose();
    super.dispose();
  }
}
