import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_task/routes/app_routes.dart';
import 'package:provider/provider.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  late UserProvider _userProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    Future.delayed(
      const Duration(seconds: 3),
      () {
        // context.router.replace(const OnBoardingRoute());
        context.router.replace(const HomeRoute());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BgContainer(
          child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.5),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.ICON,
              height: 250,
              width: 250,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              "MAPBOX",
              style: TextStyle(
                color: ColorPallet.whiteColor,
                fontFamily: AppConstants.FONT_FAMILY,
                fontSize: Dimensions.FONT_SIZE_LARGE_24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
