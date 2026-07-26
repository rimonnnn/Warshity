import 'package:warshity/core/constants/keys.dart';
import 'package:warshity/core/services/shared_pref_service.dart';

class OnboardingLocalDataSource {
  Future<void> completeOnboarding() async {
    await SharedPrefService.setBool(PrefKeys.onboardingCompleted, true);
  }

  bool isCompleted() {
    return SharedPrefService.getBool(PrefKeys.onboardingCompleted);
  }
}
