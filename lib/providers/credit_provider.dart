import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/credit_model.dart';
import '../services/credit_service.dart';

enum CreditState { idle, loading, error }

class CreditProvider extends ChangeNotifier {
  final CreditService _creditService = const CreditService();

  int _credits = 0;
  String? _loadedUserId;
  final List<CreditTransaction> _transactions = [];
  CreditState _state = CreditState.idle;
  String? _errorMessage;

  int get credits => _credits;
  List<CreditTransaction> get transactions => List.unmodifiable(_transactions);
  CreditState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CreditState.loading;
  List<CreditPack> get packs => kCreditPacks;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadForUser() async {
    if (_loadedUserId == 'loaded') return;
    _loadedUserId = 'loaded';
    _state = CreditState.loading;
    notifyListeners();
    try {
      final balance = await _creditService.getBalance();
      final txList = await _creditService.getHistory();
      _credits = balance;
      _transactions
        ..clear()
        ..addAll(txList);
      _state = CreditState.idle;
    } catch (_) {
      _credits = 0;
      _transactions.clear();
      _state = CreditState.error;
      _errorMessage = 'Unable to load credits right now.';
    }
    notifyListeners();
  }

  void reset() {
    _credits = 0;
    _loadedUserId = null;
    _transactions.clear();
    _state = CreditState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Purchase via Stripe Checkout ──────────────────────────────────────────

  Future<void> purchasePack(CreditPack pack) async {
    _state = CreditState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await _creditService.createCheckoutSession(pack);
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _errorMessage = 'Could not open payment page.';
        }
      } else {
        _errorMessage = 'Failed to create checkout session.';
      }
    } catch (_) {
      _errorMessage = 'Payment initiation failed. Please try again.';
    }
    _state = CreditState.idle;
    notifyListeners();
  }

  bool canAfford(int cost) => _credits >= cost;

  void clearError() {
    _state = CreditState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
