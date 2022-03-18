import 'dart:async';
import 'dart:typed_data';

import 'dart:ui';
import 'package:flutter/foundation.dart';

class ComputeCbParams {
  ComputeCbParams({
    required this.maxIterations,
    required this.constX,
    required this.constY,
    required this.escape,
  });

  final int maxIterations;
  final double constX;
  final double constY;
  final double escape;
}

Uint8List computeCb(ComputeCbParams params) {
  const minX = -0.5;
  const maxX = 0.5;
  const minY = -0.5;
  const maxY = 0.5;
  final constX = params.constX;
  final escape = params.escape;
  final constY = params.constY;
  final maxIterations = params.maxIterations;
  double remap(int x, double t1, num t2, double s1, double s2) {
    final f = (x - t1) / (t2 - t1);
    final g = f * (s2 - s1) + s1;
    return g;
  }

  int getColorInt(double c) {
    late double r;
    late double g;
    late double b;
    final p = c / 32;
    final pTimes6 = p * 6;
    final l = pTimes6.floor();
    final condition = l % 6;
    final o = pTimes6 - l;
    final q = 1 - o;

    switch (condition) {
      case 0:
        r = 1;
        g = o;
        b = 0;
        break;
      case 1:
        r = q;
        g = 1;
        b = 0;
        break;
      case 2:
        r = 0;
        g = 1;
        b = o;
        break;
      case 3:
        r = 0;
        g = q;
        b = 1;
        break;
      case 4:
        r = o;
        g = 0;
        b = 1;
        break;
      case 5:
        r = 1;
        g = 0;
        b = q;
        break;
    }

    // ignore: lines_longer_than_80_chars
    return 0xFF000000 + (255 * b).floor() + (65280 * g).floor() + (16711680 * r).floor();
  }

  return Int32List.fromList(
    List.generate(1024 * 1024, (i) {
      var a = remap((i / 1024).floor(), 0, 1024, minX, maxX);
      var b = remap(i % 1024, 0, 1024, minY, maxY);
      var cnt = 0.0;
      while (++cnt < maxIterations) {
        final za = a * a;
        final zb = b * b;
        if (za + zb > escape) break;
        final as = za - zb;
        final bs = 2 * a * b;
        a = as + constX;
        b = bs + constY;
      }
      return getColorInt(cnt);
    }),
  ).buffer.asUint8List();
}

Future<Image> makeImage({
  required int maxIterations,
  required double constX,
  required double constY,
  required double escape,
}) async {
  final c = Completer<Image>();

  final pixels = await compute(
    computeCb,
    ComputeCbParams(
      constX: constX,
      constY: constY,
      escape: escape,
      maxIterations: maxIterations,
    ),
  );

  decodeImageFromPixels(
    pixels,
    1024,
    1024,
    PixelFormat.bgra8888,
    c.complete,
  );

  return c.future;
}
