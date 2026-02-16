import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/design_pattern_model.dart';
import '../models/store_model.dart';

class StoreProvider extends ChangeNotifier {
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
    _loadSampleData();
  }

  void _loadSampleData() {
    _stores = [
      StoreModel(
        id: '1',
        tenantId: 'tenant_1',
        name: 'Silk Palace',
        address: '123 MG Road',
        city: 'Bangalore',
        state: 'Karnataka',
        phone: '+91 9876543210',
        email: 'info@silkpalace.com',
      ),
      StoreModel(
        id: '2',
        tenantId: 'tenant_1',
        name: 'Royal Sarees',
        address: '456 Anna Nagar',
        city: 'Chennai',
        state: 'Tamil Nadu',
        phone: '+91 9876543211',
        email: 'info@royalsarees.com',
      ),
    ];

    _designPatterns = [
      DesignPatternModel(
        id: '1',
        tenantId: 'tenant_1',
        storeId: '1',
        name: 'Kanchipuram Gold Border',
        description: 'Traditional gold zari border pattern',
        category: 'Kanchipuram',
        price: 15000,
        createdAt: DateTime.now(),
      ),
      DesignPatternModel(
        id: '2',
        tenantId: 'tenant_1',
        storeId: '1',
        name: 'Banarasi Silk Pallu',
        description: 'Intricate Banarasi pallu with floral motifs',
        category: 'Banarasi',
        price: 22000,
        createdAt: DateTime.now(),
      ),
      DesignPatternModel(
        id: '3',
        tenantId: 'tenant_1',
        storeId: '2',
        name: 'Mysore Silk Classic',
        description: 'Classic Mysore silk with checked pattern',
        category: 'Mysore',
        price: 8000,
        createdAt: DateTime.now(),
      ),
    ];

    _selectedStore = _stores.isNotEmpty ? _stores[0] : null;
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final newDesign = design.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _designPatterns.indexWhere((d) => d.id == design.id);
      if (index != -1) {
        _designPatterns[index] = design.copyWith(updatedAt: DateTime.now());
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

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
      await Future.delayed(const Duration(seconds: 1));

      final newStore = store.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
