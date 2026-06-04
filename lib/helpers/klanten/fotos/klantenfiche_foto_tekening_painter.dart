import 'package:flutter/material.dart';

import 'klantenfiche_foto_editor_controller.dart';

class KlantenficheFotoTekeningPainter extends CustomPainter {
  final List<TekenLijn> lijnen;

  const KlantenficheFotoTekeningPainter({
    required this.lijnen,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    for (final lijn in lijnen) {
      if (lijn.punten.length < 2) continue;

      final paintLijn = Paint()
        ..color = lijn.geselecteerd ? Colors.yellow : lijn.kleur
        ..strokeWidth = lijn.geselecteerd ? 6 : 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < lijn.punten.length - 1; i++) {
        canvas.drawLine(
          lijn.punten[i],
          lijn.punten[i + 1],
          paintLijn,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant KlantenficheFotoTekeningPainter oldDelegate,
  ) {
    return true;
  }
}
