import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ColorPallet {
  // Theme Colors
  static const Color primaryColor = Color(0xff19173D);
  static const Color onPrimaryColor = Color(0xff262450);
  static const Color secondaryColor = Color(0xff00D7FF);
  static const Color onSecondaryColor = Colors.white;


  // Background Colors
  static const Color backgroundColor = Color(0xff19173D);

  // Icon Color
  static const Color iconColor = Color(0xff7B78AA);

  // State Colors
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.yellow;
  static const Color errorColor = Colors.red;
  static const Color selectionColor = primaryColor;
  static const Color inactiveColor = primaryColor;

  // Black Color
  static const Color blackColor = Color(0xff000000);
  static const Color darkBlackColor = Color(0xff181A1C);
  static const Color secondaryDarkBlackColor = Color(0xff323436);

  // Grey Color
  static const Color greyColor = Color(0xffC5C6D0);

  // White Colors
  static const Color whiteColor = Color(0xffffffff);
  static const Color secondaryWhiteColor = Color(0xffECEBED);

  // Transparent Color
  static const Color transparent = Colors.transparent;

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  static Color themeBackgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF2B2B2B)
        : const Color(0xffffffff);
  }
}
