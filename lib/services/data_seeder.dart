import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/regional_style.dart';
import '../models/subscription_plan.dart';
import '../models/tutorial_model.dart';
import '../models/store_model.dart';
import '../models/design_pattern_model.dart';
import 'firestore_service.dart';

/// Seeds the Firestore database with initial data.
/// Only runs once — checks a `_meta/seeded` flag in Firestore.
class DataSeeder {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedIfNeeded() async {
    final metaDoc = await _db.collection('_meta').doc('seeded').get();
    if (metaDoc.exists) return; // Already seeded

    await _seedRegionalStyles();
    await _seedTutorials();
    await _seedSubscriptionPlans();
    await _seedOnboardingOptions();
    await _seedSampleStores();
    await _seedSampleDesignPatterns();

    // Mark as seeded
    await _db.collection('_meta').doc('seeded').set({
      'seeded_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _seedRegionalStyles() async {
    final styles = [
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

    for (final style in styles) {
      await _firestoreService.addRegionalStyle(style);
    }
  }

  Future<void> _seedTutorials() async {
    final tutorials = [
      // Beginner
      const TutorialModel(
        id: 'tut_1',
        title: 'Nivi Drape Basics',
        duration: '12 min',
        steps: 8,
        difficulty: 'beginner',
        category: 'Beginner Tutorials',
      ),
      const TutorialModel(
        id: 'tut_2',
        title: 'Understanding Fabric',
        duration: '8 min',
        steps: 5,
        difficulty: 'beginner',
        category: 'Beginner Tutorials',
      ),
      const TutorialModel(
        id: 'tut_3',
        title: 'Pleating 101',
        duration: '10 min',
        steps: 6,
        difficulty: 'beginner',
        category: 'Beginner Tutorials',
      ),
      // Intermediate
      const TutorialModel(
        id: 'tut_4',
        title: 'Bengali Style Complete',
        duration: '18 min',
        steps: 12,
        difficulty: 'intermediate',
        category: 'Intermediate Tutorials',
      ),
      const TutorialModel(
        id: 'tut_5',
        title: 'Gujarati Seedha Pallu',
        duration: '15 min',
        steps: 9,
        difficulty: 'intermediate',
        category: 'Intermediate Tutorials',
      ),
      const TutorialModel(
        id: 'tut_6',
        title: 'Coorgi Drape',
        duration: '16 min',
        steps: 10,
        difficulty: 'intermediate',
        category: 'Intermediate Tutorials',
      ),
      // Advanced
      const TutorialModel(
        id: 'tut_7',
        title: 'Maharashtrian Nauvari',
        duration: '25 min',
        steps: 15,
        difficulty: 'advanced',
        category: 'Advanced Tutorials',
      ),
      const TutorialModel(
        id: 'tut_8',
        title: 'Madisar (9-yard)',
        duration: '30 min',
        steps: 18,
        difficulty: 'advanced',
        category: 'Advanced Tutorials',
      ),
      const TutorialModel(
        id: 'tut_9',
        title: 'Bridal Draping',
        duration: '28 min',
        steps: 16,
        difficulty: 'advanced',
        category: 'Advanced Tutorials',
      ),
    ];

    for (final tutorial in tutorials) {
      await _firestoreService.addTutorial(tutorial);
    }
  }

  Future<void> _seedSubscriptionPlans() async {
    final plans = [
      const SubscriptionPlan(
        id: 'free',
        name: 'Free',
        description: 'Get started with basic tutorials',
        price: 0,
        billingCycle: 'free',
        features: [
          'Access to 3 basic draping styles',
          'Step-by-step text guides',
          'Community forum access',
        ],
      ),
      const SubscriptionPlan(
        id: 'basic',
        name: 'Basic',
        description: 'Full access to all tutorials',
        price: 299,
        billingCycle: 'monthly',
        features: [
          'All regional draping styles',
          'HD video tutorials',
          'Beginner to advanced modes',
          'Offline access',
          'Email support',
        ],
      ),
      const SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Time-bound premium access with AI features',
        price: 599,
        billingCycle: 'monthly',
        isPopular: true,
        features: [
          'Everything in Basic',
          'AI-powered virtual draping',
          'Personalized recommendations',
          'Live expert sessions',
          'Priority support',
          'Store management (B2B)',
        ],
      ),
      const SubscriptionPlan(
        id: 'annual',
        name: 'Annual Premium',
        description: 'Best value — save 40%',
        price: 4299,
        billingCycle: 'annual',
        features: [
          'Everything in Premium',
          '40% savings over monthly',
          'Exclusive annual collections',
          'Multi-store management',
          'Dedicated account manager',
          'API access',
        ],
      ),
    ];

    for (final plan in plans) {
      await _firestoreService.addSubscriptionPlan(plan);
    }
  }

  Future<void> _seedOnboardingOptions() async {
    await _firestoreService.setOnboardingOptions('languages', [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
      {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
      {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
      {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
      {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
      {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
      {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    ]);

    await _firestoreService.setOnboardingOptions('regions', [
      {'id': 'north', 'name': 'North India', 'icon': '🏔️'},
      {'id': 'south', 'name': 'South India', 'icon': '🌴'},
      {'id': 'east', 'name': 'East India', 'icon': '🌿'},
      {'id': 'west', 'name': 'West India', 'icon': '🏖️'},
      {'id': 'central', 'name': 'Central India', 'icon': '🏛️'},
      {'id': 'northeast', 'name': 'North East India', 'icon': '⛰️'},
    ]);

    await _firestoreService.setOnboardingOptions('body_types', [
      {'id': 'petite', 'name': 'Petite', 'description': 'Under 5\'2"'},
      {'id': 'average', 'name': 'Average', 'description': '5\'2" - 5\'6"'},
      {'id': 'tall', 'name': 'Tall', 'description': 'Above 5\'6"'},
      {'id': 'plus', 'name': 'Plus Size', 'description': 'Curvy body type'},
    ]);

    await _firestoreService.setOnboardingOptions('experience_levels', [
      {
        'id': 'beginner',
        'name': 'Beginner',
        'description': 'New to saree draping',
        'icon': '🌱',
      },
      {
        'id': 'intermediate',
        'name': 'Intermediate',
        'description': 'Know basics, want to learn more',
        'icon': '🌿',
      },
      {
        'id': 'advanced',
        'name': 'Advanced',
        'description': 'Experienced, exploring new styles',
        'icon': '🌳',
      },
    ]);
  }

  Future<void> _seedSampleStores() async {
    final stores = [
      StoreModel(
        id: 'store_1',
        tenantId: 'tenant_1',
        name: 'Silk Palace',
        address: '123 MG Road',
        city: 'Bangalore',
        state: 'Karnataka',
        phone: '+91 9876543210',
        email: 'info@silkpalace.com',
        createdAt: DateTime.now(),
      ),
      StoreModel(
        id: 'store_2',
        tenantId: 'tenant_1',
        name: 'Royal Sarees',
        address: '456 Anna Nagar',
        city: 'Chennai',
        state: 'Tamil Nadu',
        phone: '+91 9876543211',
        email: 'info@royalsarees.com',
        createdAt: DateTime.now(),
      ),
    ];

    for (final store in stores) {
      await _db
          .collection('stores')
          .doc(store.id)
          .set(store.toJson());
    }
  }

  Future<void> _seedSampleDesignPatterns() async {
    final designs = [
      DesignPatternModel(
        id: 'design_1',
        tenantId: 'tenant_1',
        storeId: 'store_1',
        name: 'Kanchipuram Gold Border',
        description: 'Traditional gold zari border pattern',
        category: 'Kanchipuram',
        price: 15000,
        createdAt: DateTime.now(),
      ),
      DesignPatternModel(
        id: 'design_2',
        tenantId: 'tenant_1',
        storeId: 'store_1',
        name: 'Banarasi Silk Pallu',
        description: 'Intricate Banarasi pallu with floral motifs',
        category: 'Banarasi',
        price: 22000,
        createdAt: DateTime.now(),
      ),
      DesignPatternModel(
        id: 'design_3',
        tenantId: 'tenant_1',
        storeId: 'store_2',
        name: 'Mysore Silk Classic',
        description: 'Classic Mysore silk with checked pattern',
        category: 'Mysore',
        price: 8000,
        createdAt: DateTime.now(),
      ),
    ];

    for (final design in designs) {
      await _db
          .collection('design_patterns')
          .doc(design.id)
          .set(design.toJson());
    }
  }
}
