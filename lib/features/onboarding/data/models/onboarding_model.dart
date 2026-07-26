// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:warshity/core/styling/app_assets.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String descreption;
  OnboardingModel({
    required this.image,
    required this.title,
    required this.descreption,
  });
}

final List<OnboardingModel> onboardingItems = [
  OnboardingModel(
    image: AppAssets.onboarding_1_1,
    title: "sales management and invoice speed",
    descreption:
        "issue your cash and credit invoices in just a few seconds easily and without any hassle",
  ),
  OnboardingModel(
    image: AppAssets.onboarding_2,
    title: "close monitoring of inventory and the store",
    descreption:
        "instant alerts for low-stock products and wood material management",
  ),
  OnboardingModel(
    image: AppAssets.onboarding_3,
    title: "all your adta is safe and secure",
    descreption:
        "keep working without the internet, and your data will sync automatically later",
  ),
];
