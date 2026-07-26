import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/constants/keys.dart';

class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(PrefKeys.onboardingCompleted, true);
  }

  bool isCompleted() {
    return _prefs.getBool(PrefKeys.onboardingCompleted) ?? false;
  }
}
