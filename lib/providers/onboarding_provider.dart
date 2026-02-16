import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  String? _selectedLanguage;
  String? _selectedRegion;
  String? _selectedBodyType;
  String? _selectedExperience;
  int _currentStep = 0;
  bool _onboardingComplete = false;

  String? get selectedLanguage => _selectedLanguage;
  String? get selectedRegion => _selectedRegion;
  String? get selectedBodyType => _selectedBodyType;
  String? get selectedExperience => _selectedExperience;
  int get currentStep => _currentStep;
  bool get onboardingComplete => _onboardingComplete;

  static const List<Map<String, String>> languages = [
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
  ];

  static const List<Map<String, String>> regions = [
    {'id': 'north', 'name': 'North India', 'icon': '🏔️'},
    {'id': 'south', 'name': 'South India', 'icon': '🌴'},
    {'id': 'east', 'name': 'East India', 'icon': '🌿'},
    {'id': 'west', 'name': 'West India', 'icon': '🏖️'},
    {'id': 'central', 'name': 'Central India', 'icon': '🏛️'},
    {'id': 'northeast', 'name': 'North East India', 'icon': '⛰️'},
  ];

  static const List<Map<String, String>> bodyTypes = [
    {'id': 'petite', 'name': 'Petite', 'description': 'Under 5\'2"'},
    {'id': 'average', 'name': 'Average', 'description': '5\'2" - 5\'6"'},
    {'id': 'tall', 'name': 'Tall', 'description': 'Above 5\'6"'},
    {'id': 'plus', 'name': 'Plus Size', 'description': 'Curvy body type'},
  ];

  static const List<Map<String, String>> experienceLevels = [
    {
      'id': 'beginner',
      'name': 'Beginner',
      'description': 'New to saree draping',
      'icon': '🌱'
    },
    {
      'id': 'intermediate',
      'name': 'Intermediate',
      'description': 'Know basics, want to learn more',
      'icon': '🌿'
    },
    {
      'id': 'advanced',
      'name': 'Advanced',
      'description': 'Experienced, exploring new styles',
      'icon': '🌳'
    },
  ];

  void selectLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  void selectRegion(String regionId) {
    _selectedRegion = regionId;
    notifyListeners();
  }

  void selectBodyType(String bodyTypeId) {
    _selectedBodyType = bodyTypeId;
    notifyListeners();
  }

  void selectExperience(String experienceId) {
    _selectedExperience = experienceId;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedLanguage != null;
      case 1:
        return _selectedRegion != null;
      case 2:
        return _selectedBodyType != null;
      case 3:
        return _selectedExperience != null;
      default:
        return false;
    }
  }

  void completeOnboarding() {
    _onboardingComplete = true;
    notifyListeners();
  }

  void reset() {
    _selectedLanguage = null;
    _selectedRegion = null;
    _selectedBodyType = null;
    _selectedExperience = null;
    _currentStep = 0;
    _onboardingComplete = false;
    notifyListeners();
  }
}
