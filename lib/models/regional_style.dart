class RegionalStyle {
  final String id;
  final String name;
  final String region;
  final String description;
  final String imageAsset;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final int stepCount;

  const RegionalStyle({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.imageAsset,
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
      difficulty: json['difficulty'] ?? 'beginner',
      stepCount: json['step_count'] ?? 0,
    );
  }
}
