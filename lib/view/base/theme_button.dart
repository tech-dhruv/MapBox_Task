import 'package:flutter/material.dart';
import 'package:mapbox_task/config/app_constants.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/config/text_style.dart';

import '../../config/dimensions.dart';

class ThemeButton extends StatelessWidget {
  final String title;
  final double buttonHeight;
  final double? buttonWidth;
  final Color color;
  final Function() onTap;
  final bool shadow;
  final bool showBorder;
  final Color borderColor;
  final Color textColor;
  final TextStyle? style;
  final bool disable;
  final BorderRadius? radius;
  final EdgeInsets? padding;
  const ThemeButton({
    Key? key,
    this.buttonHeight = 51,
    required this.onTap,
    required this.title,
    this.padding,
    this.color = ColorPallet.secondaryColor,
    this.shadow = true,
    this.buttonWidth = double.maxFinite,
    this.showBorder = false,
    this.borderColor = ColorPallet.secondaryColor,
    this.textColor = ColorPallet.whiteColor,
    this.style,
    this.disable = false,
    this.radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius ?? Dimensions.RADIUS_12,
        color: color,
        border: showBorder ? Border.all(color: borderColor,width: 1) : null,
        boxShadow: shadow ? [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
            color: ColorPallet.blackColor.withOpacity(0.4),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius ?? Dimensions.RADIUS_12,
          splashColor:disable ? null : ColorPallet.onPrimaryColor,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: style ?? TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppConstants.FONT_FAMILY,
                  fontSize: Dimensions.FONT_SIZE_LARGE),
            ),
          ),
        ),
      ),
    );
  }
}

class CCIconButton extends StatelessWidget {
  final String title;
  final double buttonHeight;
  final double? buttonWidth;
  final EdgeInsets? padding;
  final Color color;
  final Color? borderColor;
  final Function() onTap;
  final bool shadow;
  final bool showBorder;
  final Widget? icon;
  final TextStyle? style;
  final BorderRadius? radius;
  final Color textColor;
  const CCIconButton({
    Key? key,
    this.buttonHeight = 51,
    required this.onTap,
    required this.title,
    this.padding,
    this.color = ColorPallet.secondaryColor,
    this.shadow = true,
    this.buttonWidth = double.maxFinite,
    this.showBorder = false,
    this.style,
    this.icon,
    this.radius,
    this.borderColor,
    this.textColor = ColorPallet.blackColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius ?? Dimensions.RADIUS_12,
        color: color,
        border: showBorder ? Border.all(color:borderColor?? ColorPallet.secondaryColor,width: 1) : null,
        boxShadow: shadow ? [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
            color: ColorPallet.blackColor.withOpacity(0.4),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius ?? Dimensions.RADIUS_12,
          splashColor: ColorPallet.primaryColor,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            padding: padding,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon ?? Container(),
                  const SizedBox(
                    width: 6,
                  ),
                ],
                Text(
                  title,
                  style: style ?? TextStyles.bodyText3(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeIconButton extends StatelessWidget {
  final Function() onTap;
  final String icon;
  final double height;
  final Color color;
  const ThemeIconButton(
      {super.key,
      required this.onTap,
      required this.icon,
      required this.height,
      this.color = ColorPallet.whiteColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            icon,
            color: color,
          ),
        ),
      ),
    );
  }
}