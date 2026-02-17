import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedLanguage;
  String? _selectedRegion;
  String? _selectedBodyType;
  String? _selectedExperience;
  int _currentStep = 0;
  bool _onboardingComplete = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _bodyTypes = [];
  List<Map<String, dynamic>> _experienceLevels = [];

  String? get selectedLanguage => _selectedLanguage;
  String? get selectedRegion => _selectedRegion;
  String? get selectedBodyType => _selectedBodyType;
  String? get selectedExperience => _selectedExperience;
  int get currentStep => _currentStep;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get languages => _languages;
  List<Map<String, dynamic>> get regions => _regions;
  List<Map<String, dynamic>> get bodyTypes => _bodyTypes;
  List<Map<String, dynamic>> get experienceLevels => _experienceLevels;

  /// Load all onboarding options from Firestore
  Future<void> loadOptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getOnboardingOptions('languages'),
        _firestoreService.getOnboardingOptions('regions'),
        _firestoreService.getOnboardingOptions('body_types'),
        _firestoreService.getOnboardingOptions('experience_levels'),
      ]);

      _languages = results[0];
      _regions = results[1];
      _bodyTypes = results[2];
      _experienceLevels = results[3];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

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
