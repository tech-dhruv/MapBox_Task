// Routes
// ignore_for_file: constant_identifier_names

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_task/view/screens/home/home_screen.dart';
import 'package:mapbox_task/view/screens/no_internet/no_internet.dart';
import 'package:mapbox_task/view/screens/onBoarding_screen.dart';

import '../view/screens/splash_screen.dart';

part 'app_routes.gr.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
late BuildContext buildContext;

class Routes {
  static const String SPLASH_SCREEN = "/";
  static const String HOME = "/Home";
  static const String ON_BOARDING = "/OnBoarding";
  static const String NO_INTERNET = "/NO_INTERNET";
}

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRoutes extends _$AppRoutes {
  @override
  List<AutoRoute> get routes => [
         AutoRoute(path: Routes.SPLASH_SCREEN,page: SplashRoute.page, initial: true),
        AutoRoute(path: Routes.ON_BOARDING, page: OnBoardingRoute.page),
        AutoRoute(path: Routes.HOME, page: HomeRoute.page),
        AutoRoute(path: Routes.NO_INTERNET, page: NoInternetRoute.page),
      ];
}
