import 'package:flutter/material.dart';
import 'package:mapbox_task/config/app_constants.dart';
import 'package:mapbox_task/config/color.dart';
import 'dimensions.dart';

class TextStyles {
  static Text normal({required String text, required Color color}) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: null,
      style: TextStyle(
        fontSize: Dimensions.FONT_SIZE_DEFAULT,
        color: color,
      ),
    );
  }

  //! Body Text style
  static TextStyle bodyText1({Color? color}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_LARGE_17,
      fontWeight: FontWeight.w600,
      fontFamily: AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }
  static TextStyle bodyText2({Color? color,bool isBold = false}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_15,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      fontFamily: isBold ? AppConstants.FONT_FAMILY : AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }
  static TextStyle bodyText3({Color? color}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_13,
      fontWeight: FontWeight.w500,
      fontFamily: AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }
  static TextStyle bodyText4({Color? color}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_13,
      fontWeight: FontWeight.w400,
      fontFamily: AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }
  static TextStyle bodyText5({Color? color}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_SMALL,
      fontWeight: FontWeight.w400,
      fontFamily: AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }

  static TextStyle mainHeader1({Color? color}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_LARGE_20,
      fontWeight: FontWeight.w600,
      fontFamily: AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }
  
  static TextStyle mainHeader2({Color? color}) {
    return TextStyle(
      fontSize: Dimensions.FONT_SIZE_LARGE_18,
      fontWeight: FontWeight.w600,
      fontFamily: AppConstants.FONT_FAMILY,
      color: color ?? ColorPallet.blackColor
    );
  }

  static TextStyle headlineLarge({Color? color}) {
    return const TextStyle(
      fontSize: Dimensions.FONT_SIZE_MAX,
      fontWeight: FontWeight.w600,
    );
  }
}
