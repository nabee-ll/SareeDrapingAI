class TutorialModel {
  final String id;
  final String title;
  final String duration;
  final int steps;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String category;  // 'Beginner Tutorials', 'Intermediate Tutorials', 'Advanced Tutorials'
  final String? videoUrl;  // YouTube or direct mp4 URL
  final String? thumbnailUrl; // thumbnail image URL
  final String? description;

  const TutorialModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.steps,
    required this.difficulty,
    required this.category,
    this.videoUrl,
    this.thumbnailUrl,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'steps': steps,
      'difficulty': difficulty,
      'category': category,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'description': description,
    };
  }

  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      steps: json['steps'] ?? 0,
      difficulty: json['difficulty'] ?? 'beginner',
      category: json['category'] ?? '',
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
    );
  }

  TutorialModel copyWith({
    String? id,
    String? title,
    String? duration,
    int? steps,
    String? difficulty,
    String? category,
    String? videoUrl,
    String? thumbnailUrl,
    String? description,
  }) {
    return TutorialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      steps: steps ?? this.steps,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
    );
  }
}
