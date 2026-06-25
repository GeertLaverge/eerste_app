import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';

class OpmetingRaamTStijlHelper {
  static void tekenTStijl({
    required Canvas canvas,
    required OpmetingRaamTStijl stijl,
    required Rect buitenKader,
    required int breedteMm,
  }) {
    final breedtePx = (buitenKader.width / breedteMm) * stijl.breedteMm;
    final halveBreedte = breedtePx / 2;

    final profiel = Rect.fromLTRB(
      stijl.start.dx - halveBreedte,
      stijl.start.dy,
      stijl.start.dx + halveBreedte,
      stijl.einde.dy,
    );

    final vulling = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(profiel, vulling);
    canvas.drawRect(profiel, lijn);
  }
}
