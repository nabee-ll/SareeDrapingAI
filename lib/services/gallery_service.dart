import '../core/config/api_config.dart';
import '../models/gallery_item_model.dart';
import 'api_client.dart';

class GalleryService {
  const GalleryService();
  static final _api = ApiClient.instance;

  Future<List<GalleryItem>> getGallery() async {
    final res = await _api.get(ApiConfig.gallery);
    if (res.ok && res.data is List) {
      return (res.data as List)
          .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> deleteItem(String itemId) async {
    final res = await _api.delete(ApiConfig.galleryItemById(itemId));
    return res.ok;
  }
}
