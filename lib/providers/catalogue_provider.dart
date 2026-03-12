import 'package:flutter/material.dart';
import '../core/mock/mock_data.dart';
import '../models/saree_asset_model.dart';
import '../services/catalogue_service.dart';

class CatalogueProvider extends ChangeNotifier {
  final CatalogueService _catalogueService = const CatalogueService();

  List<SareeAsset> _assets = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _search = '';
  String? _fabricFilter;
  String? _regionFilter;

  List<SareeAsset> get assets => List.unmodifiable(_assets);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get search => _search;
  String? get fabricFilter => _fabricFilter;
  String? get regionFilter => _regionFilter;

  Future<void> load() async {
    if (_isLoading) return; // prevent concurrent calls
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _assets = await _catalogueService.getAssets(
        fabricType: _fabricFilter,
        region: _regionFilter,
        search: _search.isEmpty ? null : _search,
      );
    } catch (_) {
      // Backend unreachable — show demo catalogue
      _assets = _filterMock(MockData.catalogue);
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    load();
  }

  void setFabricFilter(String? value) {
    _fabricFilter = value;
    load();
  }

  void setRegionFilter(String? value) {
    _regionFilter = value;
    load();
  }

  void clearFilters() {
    _search = '';
    _fabricFilter = null;
    _regionFilter = null;
    load();
  }

  List<SareeAsset> _filterMock(List<SareeAsset> all) {
    return all.where((a) {
      if (_fabricFilter != null && a.fabricType != _fabricFilter) {
        return false;
      }
      if (_regionFilter != null && a.region != _regionFilter) {
        return false;
      }
      if (_search.isNotEmpty &&
          !a.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }
}
