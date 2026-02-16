class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle; // 'free', 'monthly', 'quarterly', 'annual'
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.features,
    this.isPopular = false,
  });

  static List<SubscriptionPlan> get allPlans => [
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
}
