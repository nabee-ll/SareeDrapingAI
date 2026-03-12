class GalleryItem {
  final String id;
  final String userId;
  final String jobId;
  final String resultImageUrl;
  final String? sareeAssetId;
  final String? sareenName;
  final DateTime createdAt;

  const GalleryItem({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.resultImageUrl,
    this.sareeAssetId,
    this.sareenName,
    required this.createdAt,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      jobId: json['job_id'] as String? ?? '',
      resultImageUrl: json['result_image_url'] as String? ?? '',
      sareeAssetId: json['saree_asset_id'] as String?,
      sareenName: json['saree_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'job_id': jobId,
        'result_image_url': resultImageUrl,
        'saree_asset_id': sareeAssetId,
        'saree_name': sareenName,
        'created_at': createdAt.toIso8601String(),
      };
}
