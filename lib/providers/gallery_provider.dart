import 'package:flutter/material.dart';
import '../models/gallery_item_model.dart';
import '../services/gallery_service.dart';

class GalleryProvider extends ChangeNotifier {
  final GalleryService _galleryService = const GalleryService();

  List<GalleryItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GalleryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    if (_isLoading) return; // prevent concurrent calls
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _galleryService.getGallery();
    } catch (_) {
      _items = [];
      _errorMessage = 'Unable to load gallery right now.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteItem(String itemId) async {
    final ok = await _galleryService.deleteItem(itemId);
    if (ok) {
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    }
    return ok;
  }

  void reset() {
    _items = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
