class SareeAsset {
  final String assetId;
  final String name;
  final String fabricType;
  final String region;
  final double price;
  final String? retailerId;
  final String imageUrl;
  final String thumbnailUrl;
  final bool isActive;

  const SareeAsset({
    required this.assetId,
    required this.name,
    required this.fabricType,
    required this.region,
    required this.price,
    this.retailerId,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.isActive = true,
  });

  factory SareeAsset.fromJson(Map<String, dynamic> json) {
    return SareeAsset(
      assetId: json['asset_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fabricType: json['fabric_type'] as String? ?? '',
      region: json['region'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      retailerId: json['retailer_id'] as String?,
      imageUrl: json['image_url'] as String? ??
          json['image_key'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ??
          json['thumbnail_key'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'name': name,
        'fabric_type': fabricType,
        'region': region,
        'price': price,
        'retailer_id': retailerId,
        'image_url': imageUrl,
        'thumbnail_url': thumbnailUrl,
        'is_active': isActive,
      };
}
