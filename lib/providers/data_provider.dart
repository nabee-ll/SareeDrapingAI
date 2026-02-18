import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../models/regional_style.dart';
import '../models/subscription_plan.dart';
import '../models/tutorial_model.dart';
import '../services/firestore_service.dart';

/// Provides all shared/config data fetched from Firestore.
/// Replaces all hardcoded static data across the app.
class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<RegionalStyle> _regionalStyles = [];
  List<TutorialModel> _tutorials = [];
  List<SubscriptionPlan> _subscriptionPlans = [];
  List<CreditPack> _creditPacks = kCreditPacks; // fallback to const defaults
  bool _isLoading = false;
  String? _errorMessage;

  List<RegionalStyle> get regionalStyles => _regionalStyles;
  List<TutorialModel> get tutorials => _tutorials;
  List<SubscriptionPlan> get subscriptionPlans => _subscriptionPlans;
  List<CreditPack> get creditPacks => _creditPacks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all shared data from Firestore
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getRegionalStyles(),
        _firestoreService.getTutorials(),
        _firestoreService.getSubscriptionPlans(),
        _firestoreService.getCreditPacks(),
        _firestoreService.getCreditsConfig(),
      ]);

      _regionalStyles = results[0] as List<RegionalStyle>;
      _tutorials = results[1] as List<TutorialModel>;
      _subscriptionPlans = results[2] as List<SubscriptionPlan>;

      final packs = results[3] as List<CreditPack>;
      if (packs.isNotEmpty) _creditPacks = packs;

      // Apply credit costs from Firestore config, overriding static defaults
      final config = results[4] as Map<String, dynamic>;
      if (config.isNotEmpty) CreditCost.updateFromConfig(config);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }

  /// Get tutorials filtered by difficulty
  List<TutorialModel> getTutorialsByDifficulty(String difficulty) {
    return _tutorials.where((t) => t.difficulty == difficulty).toList();
  }

  /// Get tutorials grouped by category
  Map<String, List<TutorialModel>> get tutorialsByCategory {
    final map = <String, List<TutorialModel>>{};
    for (final tutorial in _tutorials) {
      map.putIfAbsent(tutorial.category, () => []).add(tutorial);
    }
    return map;
  }

  /// Get first N styles for preview
  List<RegionalStyle> getStylesPreview(int count) {
    return _regionalStyles.take(count).toList();
  }

  /// Get styles filtered by difficulty
  List<RegionalStyle> getStylesByDifficulty(String difficulty) {
    if (difficulty == 'all') return _regionalStyles;
    return _regionalStyles.where((s) => s.difficulty == difficulty).toList();
  }
}
