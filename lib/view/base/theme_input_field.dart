import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_task/config/text_style.dart';

import '../../config/color.dart';

class ThemeInputField extends StatefulWidget {
  const ThemeInputField(
      {Key? key,
      required this.hint,
      this.controller,
      this.icon,
      this.spacing = const EdgeInsets.symmetric(horizontal: 12),
      this.inputFormatters,
      this.keyboardType,
      this.textInputAction,
      this.isSuffix = false,
      this.autofocus = false,
      this.showDivider = true,
      this.node,
      this.backgroundColor = ColorPallet.greyColor,
      this.borderColor = ColorPallet.errorColor,
      this.textStyle,
      this.errorStyle,
      this.hintStyle,
      this.validator,
      this.suffixIcon,
      this.maxLength,
      this.separatorVisible = true,
      this.readOnly = false,
      this.obscureText = false,
      this.onTap,
      this.onSave,
      this.initialValue,
      this.radius = 12,
      this.showShadow = false,
      this.height = 42,
      this.showBorder = false,
      this.maxLines = 1,
      this.onChange,
      this.cursorColor = ColorPallet.blackColor,
      this.cursorHeight = 20})
      : super(key: key);
  final String hint;
  final String? initialValue;
  final Widget? icon;
  final EdgeInsetsGeometry spacing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final bool isSuffix;
  final bool showDivider;
  final bool readOnly;
  final bool showBorder;
  final bool autofocus;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color borderColor;
  final Color backgroundColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? node;
  final double radius;
  final String? Function(String?)? validator;
  final Function(String?)? onSave;
  final Function()? onTap;
  final Function(String)? onChange;
  final bool showShadow;
  final double height;
  final Color cursorColor;
  final double cursorHeight;

  final bool separatorVisible;

  @override
  State<ThemeInputField> createState() => _ThemeInputFieldState();
}

class _ThemeInputFieldState extends State<ThemeInputField> {
  String? errorMsg;
  setError(val) => setState(() => errorMsg = val);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Row(
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(
                  width: 16,
                ),
              ],
              Expanded(
                child: TextFormField(
                  cursorColor: widget.cursorColor,
                  cursorHeight: widget.cursorHeight,
                  readOnly: widget.readOnly,
                  controller: widget.controller,
                  initialValue: widget.initialValue,
                  onChanged: widget.onChange,
                  focusNode: widget.node,
                  style: widget.textStyle ??
                      TextStyles.bodyText2(color: ColorPallet.blackColor),
                  maxLength: widget.maxLength,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  validator: (val) {
                    if (widget.validator != null) {
                      setError(widget.validator!(val));
                      return widget.validator!(val);
                    }
                  },
                  onTap: widget.onTap,
                  onSaved: widget.onSave,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    counterText: "",
                    fillColor: widget.backgroundColor,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: widget.hintStyle ??
                        TextStyles.bodyText2(color: ColorPallet.greyColor),
                    // errorText: "",
                    errorStyle: const TextStyle(fontSize: 0),
                  ),
                ),
              ),
              if (widget.isSuffix) widget.suffixIcon ?? const SizedBox()
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            border: widget.showBorder
                ? Border.all(color: widget.borderColor, width: 1)
                : null,
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                      color: ColorPallet.blackColor.withOpacity(0.08),
                    )
                  ]
                : null,
          ),
          height: widget.height,
        ),
        if (errorMsg != null)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "*${errorMsg ?? ""}",
              style: widget.errorStyle ??
                  TextStyles.bodyText5(color: ColorPallet.errorColor),
            ),
          ),
      ],
    );
  }
}

class VerticalLine extends StatelessWidget {
  const VerticalLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: 30,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xffffffff), Color(0xff323232), Color(0xffffffff)],
            stops: [0.10, 0.5, 0.90],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
    );
  }
}
