import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loggy/loggy.dart';
//? SystemChrome
// import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:mapbox_task/config/app_constants.dart';
import 'package:mapbox_task/providers/auth_provider.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/providers/theme_provider.dart';
import 'package:mapbox_task/providers/user_provider.dart';
import 'package:mapbox_task/view/screens/home/home_screen.dart';

//? Firebase Notifications
// import 'package:firebase_core/firebase_core.dart';

import 'routes/app_routes.dart';
import 'config/styles.dart';
import './config/di_container.dart' as di;
import 'package:get_it/get_it.dart';

//? Firebase Notifications
// import 'utility/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // status bar and navigation bar color
  // SystemChrome.setSystemUIOverlayStyle(Style.systemUiOverlayStyle);
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // di container initialize
  await di.init();

  // Loggy initialize
  Loggy.initLoggy(
    hierarchicalLogging: true,
    // logPrinter: const PrettyPrinter(showColors: true),
    // hierarchicalLogging: true,
  );

  /** 
   *  # Firebase Configure
   * 
   *  'flutter pub global activate flutterfire_cli'
   *  'flutter pub global run flutterfire_cli:flutterfire configure'
   *  check google service files
   *  check info.plist
   *  done
   *  await Firebase.initializeApp();
   */


  //? Firebase Notifications
  // await NotificationService().init();
  GetIt.instance.registerSingleton<AppRoutes>(AppRoutes());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserProvider>()),
        ChangeNotifierProvider(
            create: (_) => di.sl<ConnectivityProvider>(),
            child: const HomeScreen()),
      ],
      child: MyApp(),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.transparent
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRoutes();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: navigatorKey,
      builder: (context, child) {
        buildContext = context;
        EasyLoading.init();
        return MediaQuery(
          child: child ?? const SizedBox(),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      debugShowCheckedModeBanner: false,
      title: AppConstants.APP_NAME,
      theme: Style.appTheme,
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
