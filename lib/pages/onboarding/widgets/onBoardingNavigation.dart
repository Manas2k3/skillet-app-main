import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../state_management/controllers/onboarding_controller.dart';

class onBoardingNavigation extends StatelessWidget {
  const onBoardingNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      bottom: kBottomNavigationBarHeight + 5,
      left: 25,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(
            activeDotColor: Colors.blueAccent, dotHeight: 6),
      ),
    );
  }
}
