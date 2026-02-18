import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/credit_model.dart';
import '../models/design_pattern_model.dart';
import '../models/regional_style.dart';
import '../models/store_model.dart';
import '../models/subscription_plan.dart';
import '../models/tutorial_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collections ───
  static const String _regionalStyles = 'regional_styles';
  static const String _tutorials = 'tutorials';
  static const String _subscriptionPlans = 'subscription_plans';
  static const String _onboardingOptions = 'onboarding_options';
  static const String _stores = 'stores';
  static const String _designPatterns = 'design_patterns';
  static const String _users = 'users';
  static const String _creditPacks = 'credit_packs';
  static const String _appConfig = 'app_config';
  static const String _transactions = 'credit_transactions';

  // ══════════════════════════════════════════════════════════
  // REGIONAL STYLES
  // ══════════════════════════════════════════════════════════

  Future<List<RegionalStyle>> getRegionalStyles() async {
    final snapshot = await _db.collection(_regionalStyles).get();
    return snapshot.docs
        .map((doc) => RegionalStyle.fromJson(doc.data()))
        .toList();
  }

  Future<void> addRegionalStyle(RegionalStyle style) async {
    await _db.collection(_regionalStyles).doc(style.id).set(style.toJson());
  }

  // ══════════════════════════════════════════════════════════
  // TUTORIALS
  // ══════════════════════════════════════════════════════════

  Future<List<TutorialModel>> getTutorials() async {
    final snapshot = await _db.collection(_tutorials).get();
    return snapshot.docs
        .map((doc) => TutorialModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> addTutorial(TutorialModel tutorial) async {
    await _db.collection(_tutorials).doc(tutorial.id).set(tutorial.toJson());
  }

  // ══════════════════════════════════════════════════════════
  // SUBSCRIPTION PLANS
  // ══════════════════════════════════════════════════════════

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final snapshot = await _db.collection(_subscriptionPlans).get();
    return snapshot.docs
        .map((doc) => SubscriptionPlan.fromJson(doc.data()))
        .toList();
  }

  Future<void> addSubscriptionPlan(SubscriptionPlan plan) async {
    await _db
        .collection(_subscriptionPlans)
        .doc(plan.id)
        .set(plan.toJson());
  }

  // ══════════════════════════════════════════════════════════
  // ONBOARDING OPTIONS
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getOnboardingOptions(
      String optionType) async {
    final doc =
        await _db.collection(_onboardingOptions).doc(optionType).get();
    if (!doc.exists) return [];
    final data = doc.data();
    if (data == null || data['items'] == null) return [];
    return List<Map<String, dynamic>>.from(data['items']);
  }

  Future<void> setOnboardingOptions(
      String optionType, List<Map<String, String>> items) async {
    await _db.collection(_onboardingOptions).doc(optionType).set({
      'items': items,
    });
  }

  // ══════════════════════════════════════════════════════════
  // STORES
  // ══════════════════════════════════════════════════════════

  Future<List<StoreModel>> getStores({String? tenantId}) async {
    Query<Map<String, dynamic>> query = _db.collection(_stores);
    if (tenantId != null) {
      query = query.where('tenant_id', isEqualTo: tenantId);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => StoreModel.fromJson(doc.data()))
        .toList();
  }

  Future<String> addStore(StoreModel store) async {
    final docRef = _db.collection(_stores).doc();
    final storeWithId = store.copyWith(id: docRef.id);
    await docRef.set(storeWithId.toJson());
    return docRef.id;
  }

  Future<void> updateStore(StoreModel store) async {
    if (store.id == null) return;
    await _db.collection(_stores).doc(store.id).update(store.toJson());
  }

  Future<void> deleteStore(String id) async {
    await _db.collection(_stores).doc(id).delete();
  }

  // ══════════════════════════════════════════════════════════
  // DESIGN PATTERNS
  // ══════════════════════════════════════════════════════════

  Future<List<DesignPatternModel>> getDesignPatterns(
      {String? tenantId, String? storeId}) async {
    Query<Map<String, dynamic>> query = _db.collection(_designPatterns);
    if (tenantId != null) {
      query = query.where('tenant_id', isEqualTo: tenantId);
    }
    if (storeId != null) {
      query = query.where('store_id', isEqualTo: storeId);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DesignPatternModel.fromJson(doc.data()))
        .toList();
  }

  Future<String> addDesignPattern(DesignPatternModel design) async {
    final docRef = _db.collection(_designPatterns).doc();
    final designWithId = design.copyWith(id: docRef.id);
    await docRef.set(designWithId.toJson());
    return docRef.id;
  }

  Future<void> updateDesignPattern(DesignPatternModel design) async {
    if (design.id == null) return;
    await _db
        .collection(_designPatterns)
        .doc(design.id)
        .update(design.toJson());
  }

  Future<void> deleteDesignPattern(String id) async {
    await _db.collection(_designPatterns).doc(id).delete();
  }

  // ══════════════════════════════════════════════════════════
  // USERS
  // ══════════════════════════════════════════════════════════

  Future<void> saveUser(UserModel user) async {
    if (user.id == null) return;
    await _db.collection(_users).doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection(_users).doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  Future<void> updateUser(UserModel user) async {
    if (user.id == null) return;
    await _db.collection(_users).doc(user.id).update(user.toJson());
  }

  // ══════════════════════════════════════════════════════════
  // CREDIT PACKS
  // ══════════════════════════════════════════════════════════

  Future<List<CreditPack>> getCreditPacks() async {
    final snapshot = await _db
        .collection(_creditPacks)
        .orderBy('sort_order')
        .get();
    return snapshot.docs
        .map((doc) => CreditPack.fromJson(doc.data()))
        .toList();
  }

  Future<void> addCreditPack(CreditPack pack) async {
    await _db.collection(_creditPacks).doc(pack.id).set(pack.toJson());
  }

  // ══════════════════════════════════════════════════════════
  // APP CONFIG
  // ══════════════════════════════════════════════════════════

  /// Returns the 'credits' config document (credit costs per feature).
  Future<Map<String, dynamic>> getCreditsConfig() async {
    final doc = await _db.collection(_appConfig).doc('credits').get();
    if (!doc.exists) return {};
    return doc.data() ?? {};
  }

  Future<void> setCreditsConfig(Map<String, dynamic> data) async {
    await _db.collection(_appConfig).doc('credits').set(data);
  }

  // ══════════════════════════════════════════════════════════
  // CREDIT TRANSACTIONS
  // ══════════════════════════════════════════════════════════

  Future<void> saveTransaction(CreditTransaction tx) async {
    await _db.collection(_transactions).doc(tx.id).set(tx.toJson());
  }

  Future<List<CreditTransaction>> getTransactions(String userId) async {
    final snapshot = await _db
        .collection(_transactions)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => CreditTransaction.fromJson(doc.data()))
        .toList();
  }

  /// Update only the credits field on a user document.
  Future<void> updateUserCredits(String userId, int credits) async {
    await _db.collection(_users).doc(userId).update({'credits': credits});
  }
}
