import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mapbox_task/config/color.dart';

class BgContainer extends StatefulWidget {
  const BgContainer({super.key, required this.child, this.topPosition, this.rightPosition, this.roundContainerHeight, this.roundContainerWidth,});

  final Widget child;
  final double? topPosition;
  final double? rightPosition;
  final double? roundContainerHeight;
  final double? roundContainerWidth;

  @override
  State<BgContainer> createState() => _BgContainerState();
}

class _BgContainerState extends State<BgContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: ColorPallet.primaryColor,
            child: Stack(
              children: [
                Positioned(
                  top: widget.topPosition ?? MediaQuery.of(context).size.height / 3,
                  right: widget.rightPosition ?? MediaQuery.of(context).size.width / 4.5,
                  child: Container(
                    height: widget.roundContainerHeight ?? 215,
                    width: widget.roundContainerWidth ?? 215,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        Color(0xff0DA6C2).withOpacity(0.3),
                        Color(0xff0DA6C2).withOpacity(0.12),
                        //Color(0xff0DA6C2).withOpacity(0.02),
                      ]),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 300,
                          blurStyle: BlurStyle.outer,
                          color: Color(0xff0DA6C2).withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: widget.child,
        ),
      ],
    );
  }
}
