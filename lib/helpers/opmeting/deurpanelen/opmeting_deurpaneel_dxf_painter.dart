import 'package:flutter/material.dart';

import 'opmeting_deurpaneel_dxf_fit_helper.dart';
import 'opmeting_deurpaneel_dxf_model.dart';

class OpmetingDeurpaneelDxfPainterHelper {
  const OpmetingDeurpaneelDxfPainterHelper._();

  static void tekenDxf({
    required Canvas canvas,
    required Rect paneelVlak,
    required OpmetingDeurpaneelDxfTekening tekening,
    Color kleur = const Color(0xFF111827),
    double margePx = 0,
    double strokeWidth = 1.3,
    bool behoudVerhouding = true,
  }) {
    if (paneelVlak.width <= 0 || paneelVlak.height <= 0 || tekening.isLeeg) {
      return;
    }

    final bounds = tekening.bounds;

    if (bounds.isLeeg) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = kleur;

    canvas.save();
    canvas.clipRect(paneelVlak);

    for (final entity in tekening.entities) {
      final punten = OpmetingDeurpaneelDxfFitHelper.entityNaarCanvasPunten(
        entity: entity,
        bounds: bounds,
        doelRect: paneelVlak,
        margePx: margePx,
        behoudVerhouding: behoudVerhouding,
      );

      if (punten.length < 2) {
        continue;
      }

      final path = Path()..moveTo(punten.first.dx, punten.first.dy);

      for (final punt in punten.skip(1)) {
        path.lineTo(punt.dx, punt.dy);
      }

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }
}
