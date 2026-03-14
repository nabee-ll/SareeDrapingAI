class ApiConfig {
  ApiConfig._();

  // Base URL for the NestJS backend.
  // Replace with production URL before deploying.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Use WiFi IP so real devices can reach the local backend.
    // 10.0.2.2 only works on the Android emulator; 10.196.244.24 is this machine's WiFi IP.
    defaultValue: 'http://10.196.244.24:3000',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Jobs
  static const String jobs = '/jobs';
  static String jobById(String id) => '/jobs/$id';

  // Catalogue
  static const String assets = '/assets';
  static String assetById(String id) => '/assets/$id';

  // Gallery
  static const String gallery = '/gallery';
  static String galleryItemById(String id) => '/gallery/$id';

  // Credits
  static const String credits = '/credits';
  static const String creditHistory = '/credits/history';
  static const String createCheckout = '/credits/checkout';
}
