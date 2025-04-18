import 'package:flutter/material.dart';

import '../../config/dimensions.dart';

class ThemeLoader extends StatelessWidget {
  const ThemeLoader({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: Dimensions.RADIUS_SMALL),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    ));
  }
}
