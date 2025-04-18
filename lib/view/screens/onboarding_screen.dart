import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapbox_task/config/assets.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/view/base/bg_container.dart';
import 'package:mapbox_task/view/base/theme_button.dart';

import '../../config/app_constants.dart';
import '../../config/di_container.dart';

@RoutePage()
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int liveIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      liveIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: height * 0.18,
        child: Column(
          children: [
            SizedBox(height: height * 0.01),
            // Dots to show current page index
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (dotIndex) => liveIndex != dotIndex
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorPallet.whiteColor),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorPallet.whiteColor),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorPallet.whiteColor),
                        ),
                      ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: ThemeButton(
                shadow: false,
                title: 'Next',
                onTap: () {
                  liveIndex++;

                  if (liveIndex == 3) {
                    sl<SharedPreferences>()
                        .setBool(AppConstants.ONBOARDING_DONE, true);
                    // context.router.replace(const SignupRoute());
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      body: BgContainer(
        topPosition: MediaQuery.of(context).size.height / 5,
        roundContainerHeight: 300,
        roundContainerWidth: 300,
        child: Stack(
          children: [
            // Container(
            //   height: height * 0.6,
            //   width: size.width,
            //   decoration: BoxDecoration(
            //     color: ColorPallet.primaryColor.withOpacity(0.12),
            //     borderRadius: const BorderRadius.only(
            //       bottomLeft: Radius.circular(40),
            //       bottomRight: Radius.circular(40),
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: height * 0.10),
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPageContent(
                    image: Assets.ONBOARDING_1,
                    title: 'Hey! Welcome',
                    subtitle:
                        'We provide you the best mining experience\nwith our simulation app ',
                  ),
                  _buildPageContent(
                    image: Assets.ONBOARDING_2,
                    title: 'Boost Rig Performance',
                    subtitle:
                        'Boost the Rig performance by increasing time\nand boost energy',
                  ),
                  _buildPageContent(
                    image: Assets.ONBOARDING_3,
                    title: 'Flip & Win Super Coins',
                    subtitle:
                        'Win Super coins by playing a simple Flip & Win\ngame',
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              right: 18,
              child: TextButton(
                onPressed: () {
                  // sl<SharedPreferences>().setBool(AppConstants.ONBOARDING_COMPLETED, true);
                  // context.router.replace(const SignupRoute());
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                      color: ColorPallet.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// Helper method to build each onboarding page
  Widget _buildPageContent({
    required String image,
    required String title,
    required String subtitle,
  }) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: height * .45,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: height * .1),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: ColorPallet.whiteColor),
          ),
          SizedBox(height: height * .02),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorPallet.whiteColor),
          ),
        ],
      ),
    );
  }
}
