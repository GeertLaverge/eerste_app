import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'klantenfiche_foto_editor_controller.dart';

class KlantenficheFotoTekeningPainter extends CustomPainter {
  final List<TekenLijn> lijnen;
  final List<TekenTekst> teksten;

  const KlantenficheFotoTekeningPainter({
    required this.lijnen,
    required this.teksten,
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

      if (lijn.type == FotoEditorTool.pijl && lijn.punten.length >= 2) {
        final start = lijn.punten[lijn.punten.length - 2];
        final einde = lijn.punten.last;

        final hoek = math.atan2(
          einde.dy - start.dy,
          einde.dx - start.dx,
        );

        const pijlLengte = 18.0;
        const pijlHoek = math.pi / 6;

        final punt1 = Offset(
          einde.dx - pijlLengte * math.cos(hoek - pijlHoek),
          einde.dy - pijlLengte * math.sin(hoek - pijlHoek),
        );

        final punt2 = Offset(
          einde.dx - pijlLengte * math.cos(hoek + pijlHoek),
          einde.dy - pijlLengte * math.sin(hoek + pijlHoek),
        );

        canvas.drawLine(
          einde,
          punt1,
          paintLijn,
        );

        canvas.drawLine(
          einde,
          punt2,
          paintLijn,
        );
      }

      if (lijn.geselecteerd && lijn.punten.length == 2) {
        final start = lijn.punten.first;
        final einde = lijn.punten.last;

        final handlePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        final borderPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        const grootte = 10.0;

        final startRect = Rect.fromCenter(
          center: start,
          width: grootte,
          height: grootte,
        );

        final eindRect = Rect.fromCenter(
          center: einde,
          width: grootte,
          height: grootte,
        );

        canvas.drawRect(
          startRect,
          handlePaint,
        );

        canvas.drawRect(
          startRect,
          borderPaint,
        );

        canvas.drawRect(
          eindRect,
          handlePaint,
        );

        canvas.drawRect(
          eindRect,
          borderPaint,
        );
      }
    }

    for (final tekstItem in teksten) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: tekstItem.tekst,
          style: TextStyle(
            color: tekstItem.geselecteerd ? Colors.yellow : tekstItem.kleur,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        tekstItem.positie,
      );

      if (tekstItem.geselecteerd) {
        final rect = Rect.fromLTWH(
          tekstItem.positie.dx - 4,
          tekstItem.positie.dy - 4,
          textPainter.width + 8,
          textPainter.height + 8,
        );

        final borderPaint = Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawRect(
          rect,
          borderPaint,
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
