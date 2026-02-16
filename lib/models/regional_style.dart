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

  static List<RegionalStyle> get sampleStyles => [
        const RegionalStyle(
          id: 'nivi',
          name: 'Nivi Style',
          region: 'Andhra Pradesh',
          description:
              'The most popular draping style across India. Elegant and easy to wear.',
          imageAsset: 'nivi',
          difficulty: 'beginner',
          stepCount: 8,
        ),
        const RegionalStyle(
          id: 'bengali',
          name: 'Bengali Style',
          region: 'West Bengal',
          description:
              'Traditional Bengali drape with the distinctive pallu over the left shoulder.',
          imageAsset: 'bengali',
          difficulty: 'intermediate',
          stepCount: 12,
        ),
        const RegionalStyle(
          id: 'maharashtrian',
          name: 'Maharashtrian Nauvari',
          region: 'Maharashtra',
          description:
              'The nine-yard saree draped in a dhoti style, perfect for festive occasions.',
          imageAsset: 'maharashtrian',
          difficulty: 'advanced',
          stepCount: 15,
        ),
        const RegionalStyle(
          id: 'gujarati',
          name: 'Gujarati Seedha Pallu',
          region: 'Gujarat',
          description:
              'Front pallu style that showcases the saree\'s design beautifully.',
          imageAsset: 'gujarati',
          difficulty: 'beginner',
          stepCount: 9,
        ),
        const RegionalStyle(
          id: 'south_indian',
          name: 'South Indian / Madisar',
          region: 'Tamil Nadu',
          description:
              'Traditional Brahmin style using a 9-yard saree, typically for ceremonies.',
          imageAsset: 'south_indian',
          difficulty: 'advanced',
          stepCount: 18,
        ),
        const RegionalStyle(
          id: 'rajasthani',
          name: 'Rajasthani Style',
          region: 'Rajasthan',
          description:
              'Royal Rajasthani drape with intricate tucking and pallu arrangement.',
          imageAsset: 'rajasthani',
          difficulty: 'intermediate',
          stepCount: 11,
        ),
        const RegionalStyle(
          id: 'coorgi',
          name: 'Coorgi Style',
          region: 'Karnataka',
          description:
              'Unique back-pleating style from the Kodava community of Coorg.',
          imageAsset: 'coorgi',
          difficulty: 'intermediate',
          stepCount: 10,
        ),
        const RegionalStyle(
          id: 'lehenga',
          name: 'Lehenga Style',
          region: 'Pan India',
          description:
              'Modern fusion drape that gives a lehenga-like appearance.',
          imageAsset: 'lehenga',
          difficulty: 'beginner',
          stepCount: 7,
        ),
      ];
}
