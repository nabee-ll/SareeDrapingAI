import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
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

  Future<void> loadOptions() async {
    _isLoading = true;
    notifyListeners();

    _languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'ta', 'name': 'Tamil'},
      {'code': 'te', 'name': 'Telugu'},
      {'code': 'kn', 'name': 'Kannada'},
      {'code': 'ml', 'name': 'Malayalam'},
      {'code': 'bn', 'name': 'Bengali'},
      {'code': 'mr', 'name': 'Marathi'},
      {'code': 'gu', 'name': 'Gujarati'},
    ];

    _regions = [
      {'code': 'north', 'name': 'North India'},
      {'code': 'south', 'name': 'South India'},
      {'code': 'east', 'name': 'East India'},
      {'code': 'west', 'name': 'West India'},
      {'code': 'ne', 'name': 'North East India'},
    ];

    _bodyTypes = [
      {'code': 'petite', 'name': 'Petite'},
      {'code': 'slim', 'name': 'Slim'},
      {'code': 'average', 'name': 'Average'},
      {'code': 'curvy', 'name': 'Curvy'},
      {'code': 'plus', 'name': 'Plus Size'},
    ];

    _experienceLevels = [
      {'code': 'beginner', 'name': 'Beginner', 'description': 'New to sarees'},
      {'code': 'intermediate', 'name': 'Intermediate', 'description': 'Know the basics'},
      {'code': 'expert', 'name': 'Expert', 'description': 'Drape with confidence'},
    ];

    _isLoading = false;
    notifyListeners();
  }

  void selectLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  void selectRegion(String regionCode) {
    _selectedRegion = regionCode;
    notifyListeners();
  }

  void selectBodyType(String bodyTypeCode) {
    _selectedBodyType = bodyTypeCode;
    notifyListeners();
  }

  void selectExperience(String experienceCode) {
    _selectedExperience = experienceCode;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
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
        return true;
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
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
