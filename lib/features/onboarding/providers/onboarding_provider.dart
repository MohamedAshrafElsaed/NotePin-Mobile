// lib/features/onboarding/providers/onboarding_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  int _currentPage = 0;
  bool _isComplete = false;

  static const String _onboardingKey = 'onboarding_complete';

  int get currentPage => _currentPage;

  bool get isComplete => _isComplete;

  int get totalPages => 3;

  bool get isLastPage => _currentPage == totalPages - 1;

  OnboardingProvider(this._prefs) {
    _loadOnboardingStatus();
  }

  void _loadOnboardingStatus() {
    _isComplete = _prefs.getBool(_onboardingKey) ?? false;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    _currentPage = page.clamp(0, totalPages - 1);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isComplete = true;
    await _prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  // For testing/development: reset onboarding
  Future<void> resetOnboarding() async {
    _isComplete = false;
    _currentPage = 0;
    await _prefs.setBool(_onboardingKey, false);
    notifyListeners();
  }
}
