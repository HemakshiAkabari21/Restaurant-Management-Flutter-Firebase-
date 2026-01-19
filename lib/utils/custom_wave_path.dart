import 'package:flutter/material.dart';

class YellowWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    // M0,320  →  bottom-left corner
    path.moveTo(0, size.height);

    // L48,293.3
    path.lineTo(size.width * 48 / 1440, size.height * 293.3 / 320);

    // C96,267 192,213 288,208
    path.cubicTo(
      size.width * 96 / 1440,  size.height * 267 / 320,
      size.width * 192 / 1440, size.height * 213 / 320,
      size.width * 288 / 1440, size.height * 208 / 320,
    );

    // C384,203 480,245 576,218.7
    path.cubicTo(
      size.width * 384 / 1440, size.height * 203 / 320,
      size.width * 480 / 1440, size.height * 245 / 320,
      size.width * 576 / 1440, size.height * 218.7 / 320,
    );

    // C672,192 768,96 864,96
    path.cubicTo(
      size.width * 672 / 1440, size.height * 192 / 320,
      size.width * 768 / 1440, size.height * 96  / 320,
      size.width * 864 / 1440, size.height * 96  / 320,
    );

    // C960,96 1056,192 1152,208
    path.cubicTo(
      size.width * 960  / 1440, size.height * 96  / 320,
      size.width * 1056 / 1440, size.height * 192 / 320,
      size.width * 1152 / 1440, size.height * 208 / 320,
    );

    // C1248,224 1344,160 1392,128
    path.cubicTo(
      size.width * 1248 / 1440, size.height * 224 / 320,
      size.width * 1344 / 1440, size.height * 160 / 320,
      size.width * 1392 / 1440, size.height * 128 / 320,
    );

    // L1440,96 1440,0 … back to origin
    path.lineTo(size.width, size.height * 96 / 320);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
