import 'package:flutter/material.dart';

class KlantenficheFotoTekeningPainter extends CustomPainter {
  final List<Offset?> punten;
  final Color kleur;

  const KlantenficheFotoTekeningPainter({
    required this.punten,
    required this.kleur,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paintLijn = Paint()
      ..color = kleur
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < punten.length - 1; i++) {
      final huidig = punten[i];
      final volgend = punten[i + 1];

      if (huidig != null && volgend != null) {
        canvas.drawLine(
          huidig,
          volgend,
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
