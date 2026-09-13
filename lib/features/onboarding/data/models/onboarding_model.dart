// ignore_for_file: public_member_api_docs, sort_constructors_first

class OnboardingModel {
  final String title;
  final String description;
  OnboardingModel({required this.title, required this.description});
}

final List<OnboardingModel> onboardingItems = [
  OnboardingModel(
    title: 'onboarding.manage_your_business.title',
    description: 'onboarding.manage_your_business.description',
  ),
  OnboardingModel(
    title: 'onboarding.track_your_business.title',
    description: 'onboarding.track_your_business.description',
  ),
  OnboardingModel(
    title: 'onboarding.your_data_is_safe.title',
    description: 'onboarding.your_data_is_safe.description',
  ),
];
