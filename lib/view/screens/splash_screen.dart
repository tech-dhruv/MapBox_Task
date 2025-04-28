import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_task/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_constants.dart';
import '../../config/assets.dart';
import '../../config/color.dart';
import '../../config/dimensions.dart';
import '../../providers/user_provider.dart';
import '../base/bg_container.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late UserProvider _userProvider;
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // Text animations
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );
    
    _textSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Navigate after animation
    Future.delayed(
      const Duration(seconds: 3),
      () {
        navigateToNext();
      },
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void navigateToNext() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final isBoardingCompleted = pref.getBool(AppConstants.ONBOARDING_DONE) ?? false;
    if(isBoardingCompleted){
      context.router.replace(const HomeRoute());
    }else {
      context.router.replace(const OnBoardingRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BgContainer(
          child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Image.asset(
                      Assets.ICON,
                      height: 250,
                      width: 250,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SlideTransition(
                  position: _textSlideAnimation,
                  child: Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Text(
                      "MAPBOX",
                      style: TextStyle(
                        color: ColorPallet.whiteColor,
                        fontFamily: AppConstants.FONT_FAMILY,
                        fontSize: Dimensions.FONT_SIZE_LARGE_24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      )),
    );
  }
}
