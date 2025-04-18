import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_task/config/app_constants.dart';

import 'color.dart';
import 'text_style.dart';

class Style {
  static ThemeData appTheme = ThemeData(
    primaryColor: ColorPallet.primaryColor,
    scaffoldBackgroundColor: ColorPallet.backgroundColor,
    fontFamily: AppConstants.FONT_FAMILY,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPallet.transparent,
      foregroundColor: ColorPallet.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: ColorPallet.primaryColor,
      ),
      titleTextStyle: TextStyle(
        color: ColorPallet.primaryColor,
      ),
    ),
    iconTheme: const IconThemeData(
      color: ColorPallet.darkBlackColor,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyles.headlineLarge(),
      headlineMedium: TextStyles.mainHeader1(),
      headlineSmall: TextStyles.mainHeader2(),
      bodyLarge: TextStyles.bodyText1(),
      bodyMedium: TextStyles.bodyText3(),
      bodySmall: TextStyles.bodyText5(),
      displayLarge: TextStyles.mainHeader1(),
      displaySmall: TextStyles.mainHeader2(),
      labelLarge: TextStyles.bodyText2(),
      labelMedium: TextStyles.bodyText4(),
      labelSmall: TextStyles.bodyText5(),
      titleLarge: TextStyles.bodyText1(),
      titleMedium: TextStyles.bodyText3(),
      titleSmall: TextStyles.bodyText5(),
    ),
  );

  static SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    systemNavigationBarColor: ColorPallet.backgroundColor,
    statusBarColor: ColorPallet.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,

    // Status bar brightness (optional)
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.light, // For iOS (dark icons)
  );

  static SystemUiOverlayStyle systemUiOverlayStyleManual(
          BuildContext context, Brightness brightness) =>
      SystemUiOverlayStyle(
        systemNavigationBarColor: brightness == Brightness.light
            ? ColorPallet.blackColor
            : ColorPallet.whiteColor,
        statusBarColor: ColorPallet.transparent,
        systemNavigationBarIconBrightness: brightness,

        // Status bar brightness (optional)
        statusBarIconBrightness: brightness, // For Android (dark icons)
        statusBarBrightness: brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light, // For iOS (dark icons)
      );
}
