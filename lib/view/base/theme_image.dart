import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../config/assets.dart';

class ThemeImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  const ThemeImage({
    Key? key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Image.asset(Assets.PLACEHOLDER,
          height: height, width: width, fit: fit),
      errorWidget: (context, url, error) => Image.asset(Assets.PLACEHOLDER,
          height: height, width: width, fit: fit),
    );
  }
}
