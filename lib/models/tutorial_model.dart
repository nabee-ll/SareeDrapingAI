class TutorialModel {
  final String id;
  final String title;
  final String duration;
  final int steps;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String category; // 'Beginner Tutorials', 'Intermediate Tutorials', 'Advanced Tutorials'

  const TutorialModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.steps,
    required this.difficulty,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'steps': steps,
      'difficulty': difficulty,
      'category': category,
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
    );
  }
}
