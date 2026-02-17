import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/design_pattern_model.dart';
import '../models/store_model.dart';
import '../services/firestore_service.dart';

class StoreProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<StoreModel> _stores = [];
  List<DesignPatternModel> _designPatterns = [];
  StoreModel? _selectedStore;
  bool _isLoading = false;
  String? _errorMessage;

  // Image uploads for VSD
  XFile? _borderImage;
  XFile? _palluImage;
  XFile? _pleatsImage;

  List<StoreModel> get stores => _stores;
  List<DesignPatternModel> get designPatterns => _designPatterns;
  StoreModel? get selectedStore => _selectedStore;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  XFile? get borderImage => _borderImage;
  XFile? get palluImage => _palluImage;
  XFile? get pleatsImage => _pleatsImage;

  StoreProvider() {
    loadData();
  }

  /// Load stores and design patterns from Firestore
  Future<void> loadData({String? tenantId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getStores(tenantId: tenantId),
        _firestoreService.getDesignPatterns(tenantId: tenantId),
      ]);

      _stores = results[0] as List<StoreModel>;
      _designPatterns = results[1] as List<DesignPatternModel>;
      _selectedStore = _stores.isNotEmpty ? _stores[0] : null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }

  void selectStore(StoreModel store) {
    _selectedStore = store;
    notifyListeners();
  }

  List<DesignPatternModel> getDesignsForStore(String storeId) {
    return _designPatterns.where((d) => d.storeId == storeId).toList();
  }

  Future<void> addDesignPattern(DesignPatternModel design) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _firestoreService.addDesignPattern(design.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final newDesign = design.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _designPatterns.add(newDesign);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add design pattern.';
      notifyListeners();
    }
  }

  Future<void> updateDesignPattern(DesignPatternModel design) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = design.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateDesignPattern(updated);
      final index = _designPatterns.indexWhere((d) => d.id == design.id);
      if (index != -1) {
        _designPatterns[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update design pattern.';
      notifyListeners();
    }
  }

  Future<void> deleteDesignPattern(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteDesignPattern(id);
      _designPatterns.removeWhere((d) => d.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete design pattern.';
      notifyListeners();
    }
  }

  Future<void> addStore(StoreModel store) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _firestoreService.addStore(store.copyWith(
        createdAt: DateTime.now(),
      ));
      final newStore = store.copyWith(
        id: id,
        createdAt: DateTime.now(),
      );
      _stores.add(newStore);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add store.';
      notifyListeners();
    }
  }

  void setBorderImage(XFile? image) {
    _borderImage = image;
    notifyListeners();
  }

  void setPalluImage(XFile? image) {
    _palluImage = image;
    notifyListeners();
  }

  void setPleatsImage(XFile? image) {
    _pleatsImage = image;
    notifyListeners();
  }

  void clearVsdImages() {
    _borderImage = null;
    _palluImage = null;
    _pleatsImage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
