import '../core/config/api_config.dart';
import '../models/saree_asset_model.dart';
import 'api_client.dart';

class CatalogueService {
  const CatalogueService();
  static final _api = ApiClient.instance;

  /// Fetch catalogue with optional filters.
  Future<List<SareeAsset>> getAssets({
    String? fabricType,
    String? region,
    String? search, 
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (fabricType != null) params['fabric_type'] = fabricType;
    if (region != null) params['region'] = region;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final query = Uri(queryParameters: params).query;
    final res = await _api.get('${ApiConfig.assets}?$query');

    if (res.ok && res.data is List) {
      return (res.data as List)
          .map((e) => SareeAsset.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res.ok && res.data is Map && res.data['data'] is List) {
      return (res.data['data'] as List)
          .map((e) => SareeAsset.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch detail for a single asset.
  Future<SareeAsset?> getAsset(String assetId) async {
    final res = await _api.get(ApiConfig.assetById(assetId));
    if (res.ok && res.data is Map) {
      return SareeAsset.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }
}
