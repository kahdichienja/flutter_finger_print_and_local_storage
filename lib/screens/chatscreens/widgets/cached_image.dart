import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_flutter/utils/ColorLoaders.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;

  final BoxFit fit;

  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

  CachedImage(
    this.imageUrl, {
    this.isRound = false,
    this.radius = 0,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(isRound ? 50 : radius),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              placeholder: (context, url) =>
                  Center(child: ColorLoader2(
                          color3: Colors.green,
                          color2: Colors.greenAccent,
                          color1: Colors.lightGreenAccent,
                        ),),
              errorWidget: (context, url, error) => Image.network(
                noImageAvailable,
                height: 25,
                width: 25,
                fit: BoxFit.cover,
              ),
            )),
      );
    } catch (e) {
      print(e);
      return Image.network(
        noImageAvailable,
        height: 25,
        width: 25,
        fit: BoxFit.cover,
      );
    }
  }
}
