import 'package:flutter/material.dart';

class OpmetingRaamKaderHelper {
  static const double kaderOffsetMm = 70;

  static Rect buitenKader({
    required Size size,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final marge = 70.0;

    final maxBreedte = size.width - (marge * 2);
    final maxHoogte = size.height - (marge * 2);

    final schaal = [
      maxBreedte / breedteMm,
      maxHoogte / hoogteMm,
    ].reduce((a, b) => a < b ? a : b);

    final w = breedteMm * schaal;
    final h = hoogteMm * schaal;

    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2;

    return Rect.fromLTWH(left, top, w, h);
  }

  static Rect binnenKader({
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final offsetX = (buitenKader.width / breedteMm) * kaderOffsetMm;
    final offsetY = (buitenKader.height / hoogteMm) * kaderOffsetMm;

    return Rect.fromLTRB(
      buitenKader.left + offsetX,
      buitenKader.top + offsetY,
      buitenKader.right - offsetX,
      buitenKader.bottom - offsetY,
    );
  }
}
