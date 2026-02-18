import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../models/regional_style.dart';
import '../models/tutorial_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

enum AdminState { idle, loading, saving, error }

class AdminProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  // ── State ──
  AdminState _state = AdminState.idle;
  String? _errorMessage;

  // ── Data ──
  List<TutorialModel> _tutorials = [];
  List<RegionalStyle> _styles = [];
  List<CreditPack> _creditPacks = [];
  Map<String, dynamic> _creditConfig = {};
  List<UserModel> _users = [];
  List<CreditTransaction> _transactions = [];

  // ── Getters ──
  AdminState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AdminState.loading;
  bool get isSaving => _state == AdminState.saving;

  List<TutorialModel> get tutorials => _tutorials;
  List<RegionalStyle> get styles => _styles;
  List<CreditPack> get creditPacks => _creditPacks;
  Map<String, dynamic> get creditConfig => _creditConfig;
  List<UserModel> get users => _users;
  List<CreditTransaction> get transactions => _transactions;

  int get aiDrapingCost =>
      (_creditConfig['ai_draping_cost'] as int?) ?? CreditCost.aiDraping;
  int get stylishLookCost =>
      (_creditConfig['stylish_look_cost'] as int?) ?? CreditCost.stylishLook;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════════════

  Future<void> loadTutorials() async {
    _setState(AdminState.loading);
    try {
      _tutorials = await _db.getTutorials();
      _setState(AdminState.idle);
    } catch (e) {
      _setError('Failed to load tutorials: $e');
    }
  }

  Future<void> loadStyles() async {
    _setState(AdminState.loading);
    try {
      _styles = await _db.getRegionalStyles();
      _setState(AdminState.idle);
    } catch (e) {
      _setError('Failed to load styles: $e');
    }
  }

  Future<void> loadCreditConfig() async {
    _setState(AdminState.loading);
    try {
      _creditConfig = await _db.getCreditsConfig();
      _creditPacks = await _db.getCreditPacks();
      _setState(AdminState.idle);
    } catch (e) {
      _setError('Failed to load credit config: $e');
    }
  }

  Future<void> loadUsers() async {
    _setState(AdminState.loading);
    try {
      _users = await _db.getAllUsers();
      _setState(AdminState.idle);
    } catch (e) {
      _setError('Failed to load users: $e');
    }
  }

  Future<void> loadTransactions() async {
    _setState(AdminState.loading);
    try {
      _transactions = await _db.getAllTransactions();
      _setState(AdminState.idle);
    } catch (e) {
      _setError('Failed to load transactions: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // TUTORIALS
  // ══════════════════════════════════════════════════════════

  Future<bool> saveTutorial(TutorialModel tutorial) async {
    _setState(AdminState.saving);
    try {
      await _db.updateTutorial(tutorial);
      // Update local list
      final idx = _tutorials.indexWhere((t) => t.id == tutorial.id);
      if (idx >= 0) {
        _tutorials[idx] = tutorial;
      } else {
        _tutorials.insert(0, tutorial);
      }
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to save tutorial: $e');
      return false;
    }
  }

  Future<bool> deleteTutorial(String id) async {
    _setState(AdminState.saving);
    try {
      await _db.deleteTutorial(id);
      _tutorials.removeWhere((t) => t.id == id);
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to delete tutorial: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // REGIONAL STYLES
  // ══════════════════════════════════════════════════════════

  Future<bool> saveStyle(RegionalStyle style) async {
    _setState(AdminState.saving);
    try {
      await _db.updateRegionalStyle(style);
      final idx = _styles.indexWhere((s) => s.id == style.id);
      if (idx >= 0) {
        _styles[idx] = style;
      } else {
        _styles.insert(0, style);
      }
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to save style: $e');
      return false;
    }
  }

  Future<bool> deleteStyle(String id) async {
    _setState(AdminState.saving);
    try {
      await _db.deleteRegionalStyle(id);
      _styles.removeWhere((s) => s.id == id);
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to delete style: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // CREDIT CONFIG
  // ══════════════════════════════════════════════════════════

  Future<bool> saveCreditConfig(
      {required int aiDraping, required int stylishLook}) async {
    _setState(AdminState.saving);
    try {
      final config = {
        'ai_draping_cost': aiDraping,
        'stylish_look_cost': stylishLook,
      };
      await _db.setCreditsConfig(config);
      _creditConfig = config;
      CreditCost.updateFromConfig(config);
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to save credit config: $e');
      return false;
    }
  }

  Future<bool> saveCreditPack(CreditPack pack) async {
    _setState(AdminState.saving);
    try {
      await _db.updateCreditPack(pack);
      final idx = _creditPacks.indexWhere((p) => p.id == pack.id);
      if (idx >= 0) {
        _creditPacks[idx] = pack;
      } else {
        _creditPacks.add(pack);
      }
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to save credit pack: $e');
      return false;
    }
  }

  Future<bool> deleteCreditPack(String id) async {
    _setState(AdminState.saving);
    try {
      await _db.deleteCreditPack(id);
      _creditPacks.removeWhere((p) => p.id == id);
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to delete credit pack: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // USERS
  // ══════════════════════════════════════════════════════════

  Future<bool> updateUserCredits(String userId, int credits) async {
    _setState(AdminState.saving);
    try {
      await _db.adminUpdateUserCredits(userId, credits);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx >= 0) {
        _users[idx] = _users[idx].copyWith(credits: credits);
      }
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to update user credits: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    _setState(AdminState.saving);
    try {
      await _db.adminUpdateUserRole(userId, role);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx >= 0) {
        _users[idx] = _users[idx].copyWith(role: role);
      }
      _setState(AdminState.idle);
      return true;
    } catch (e) {
      _setError('Failed to update user role: $e');
      return false;
    }
  }

  // ── Helpers ──
  void _setState(AdminState s) {
    _state = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _state = AdminState.error;
    _errorMessage = msg;
    notifyListeners();
  }
}
