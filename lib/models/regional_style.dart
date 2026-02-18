class RegionalStyle {
  final String id;
  final String name;
  final String region;
  final String description;
  final String imageAsset;  // local asset name (fallback)
  final String? imageUrl;   // remote URL uploaded by admin
  final String difficulty;
  final int stepCount;

  const RegionalStyle({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.imageAsset,
    this.imageUrl,
    required this.difficulty,
    required this.stepCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'description': description,
      'image_asset': imageAsset,
      'image_url': imageUrl,
      'difficulty': difficulty,
      'step_count': stepCount,
    };
  }

  factory RegionalStyle.fromJson(Map<String, dynamic> json) {
    return RegionalStyle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      description: json['description'] ?? '',
      imageAsset: json['image_asset'] ?? '',
      imageUrl: json['image_url'],
      difficulty: json['difficulty'] ?? 'beginner',
      stepCount: json['step_count'] ?? 0,
    );
  }

  RegionalStyle copyWith({
    String? id,
    String? name,
    String? region,
    String? description,
    String? imageAsset,
    String? imageUrl,
    String? difficulty,
    int? stepCount,
  }) {
    return RegionalStyle(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      stepCount: stepCount ?? this.stepCount,
    );
  }
}
