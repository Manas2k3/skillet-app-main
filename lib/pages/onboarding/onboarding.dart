// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillet/pages/onboarding/widgets/onBoardingNavigation.dart';
import 'package:skillet/pages/onboarding/widgets/onboarding_circular_button.dart';
import 'package:skillet/pages/onboarding/widgets/onboarding_page.dart';
import 'package:skillet/pages/onboarding/widgets/onboarding_skip.dart';

import '../../core/utils/constants/image_constants.dart';
import '../../core/utils/constants/text_strings.dart';
import '../../state_management/controllers/onboarding_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OnboardingController());

    /// Preloading images to cache them before displaying
    Future.delayed(Duration.zero, () {
      precacheImage(AssetImage(ImageStrings.onBoardingImage1), context);
      precacheImage(AssetImage(ImageStrings.onBoardingImage2), context);
      precacheImage(AssetImage(ImageStrings.onBoardingImage3), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.upDatePageIndicator,
            children: [
              onBoardingPage(
                image: ImageStrings.onBoardingImage1,
                title: TextStrings.onBoardingTitle1,
                subTitle: TextStrings.onBoardingSubTitle1,
              ),
              onBoardingPage(
                image: ImageStrings.onBoardingImage2,
                title: TextStrings.onBoardingTitle2,
                subTitle: TextStrings.onBoardingSubTitle2,
              ),
              onBoardingPage(
                image: ImageStrings.onBoardingImage3,
                title: TextStrings.onBoardingTitle3,
                subTitle: TextStrings.onBoardingSubTitle3,
              ),
            ],
          ),

          // Skip Button
          onBoardingSkip(),

          // Dot Navigation SmoothPageIndicator
          onBoardingNavigation(),

          // Circular Button
          onBoardingCircularButton()
        ],
      ),
    );
  }
}
