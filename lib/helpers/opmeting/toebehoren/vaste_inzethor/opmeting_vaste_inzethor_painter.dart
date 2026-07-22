import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_vaste_inzethor_model.dart';

class OpmetingVasteInzethorPainter extends CustomPainter {
  const OpmetingVasteInzethorPainter({
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingVasteInzethorModel model;

  /// Extra schaalfactor voor compacte weergaven zoals het overzicht.
  /// De gewone fiche blijft standaard op 1.0 staan.
  final double schaalFactor;

  static const Color _lijn = Color(0xFF111827);
  static const Color _profiel = Color(0xFFF3F4F6);
  static const Color _gaasAchtergrond = Color(0xFFFCFCFD);
  static const Color _gaasLijn = Color(0xFFCBD5E1);
  static const Color _maatLijn = Color(0xFF4B5563);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    // De titel staat voortaan in de bovenrand van de tekencontainer.
    // Daardoor kan de hor groter en hoger in het beschikbare vlak staan.
    const double margeBoven = 24;
    final double margeRechts = model.isBinnenmaat ? 24 : 34;
    final double margeOnder = model.isBinnenmaat ? 24 : 62;
    final double margeLinks = model.isBinnenmaat ? 24 : 68;

    final buitenBreedteMm = model.buitenBreedteMm;
    final buitenHoogteMm = model.buitenHoogteMm;

    final beschikbareBreedte = math
        .max(40.0, size.width - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(40.0, size.height - margeBoven - margeOnder)
        .toDouble();

    final schaalX = beschikbareBreedte / buitenBreedteMm;
    final schaalY = beschikbareHoogte / buitenHoogteMm;
    final basisSchaal = math.min(schaalX, schaalY).toDouble();
    final veiligeSchaalFactor = schaalFactor.clamp(0.35, 1.0).toDouble();
    final schaal = basisSchaal * veiligeSchaalFactor;

    final getekendeBreedte = buitenBreedteMm * schaal;
    final getekendeHoogte = buitenHoogteMm * schaal;

    final links =
        margeLinks +
        ((beschikbareBreedte - getekendeBreedte) / 2)
            .clamp(0.0, double.infinity)
            .toDouble();
    // De hor staat vast en gecentreerd in de beschikbare tekenruimte.
    final boven =
        margeBoven +
        ((beschikbareHoogte - getekendeHoogte) / 2)
            .clamp(0.0, double.infinity)
            .toDouble();

    final buitenRect = Rect.fromLTWH(
      links,
      boven,
      getekendeBreedte,
      getekendeHoogte,
    );

    final profielPx = model.profielAanzichtMm * schaal;
    final traversePx = math.max(1.2, model.traverseAanzichtMm * schaal);

    final binnenRect = Rect.fromLTRB(
      buitenRect.left + profielPx,
      buitenRect.top + profielPx,
      buitenRect.right - profielPx,
      buitenRect.bottom - profielPx,
    );

    final profielPaint = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;
    final gaasAchtergrondPaint = Paint()
      ..color = _gaasAchtergrond
      ..style = PaintingStyle.fill;
    final contourPaint = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    final verstekPaint = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95;
    final gaasPaint = Paint()
      ..color = _gaasLijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.45;

    canvas.drawRect(buitenRect, profielPaint);
    canvas.drawRect(binnenRect, gaasAchtergrondPaint);

    if (model.heeftGaas) {
      canvas.save();
      canvas.clipRect(binnenRect);

      final rasterStapPx = math.max(3.5, 12 * schaal).toDouble();

      for (
        double x = binnenRect.left;
        x <= binnenRect.right + 0.1;
        x += rasterStapPx
      ) {
        canvas.drawLine(
          Offset(x, binnenRect.top),
          Offset(x, binnenRect.bottom),
          gaasPaint,
        );
      }

      for (
        double y = binnenRect.top;
        y <= binnenRect.bottom + 0.1;
        y += rasterStapPx
      ) {
        canvas.drawLine(
          Offset(binnenRect.left, y),
          Offset(binnenRect.right, y),
          gaasPaint,
        );
      }

      canvas.restore();
    }

    final traverseFill = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;

    for (final positieMm in model.actieveTraversePositiesMm) {
      final verhouding = (positieMm / model.hoogteMm).clamp(0.0, 1.0);
      final y = binnenRect.bottom - (binnenRect.height * verhouding);
      final traverseRect = Rect.fromLTWH(
        binnenRect.left,
        y - (traversePx / 2),
        binnenRect.width,
        traversePx,
      );
      canvas.drawRect(traverseRect, traverseFill);
      canvas.drawRect(traverseRect, contourPaint);
    }

    canvas.drawRect(buitenRect, contourPaint);
    canvas.drawRect(binnenRect, contourPaint);

    canvas.drawLine(buitenRect.topLeft, binnenRect.topLeft, verstekPaint);
    canvas.drawLine(buitenRect.topRight, binnenRect.topRight, verstekPaint);
    canvas.drawLine(buitenRect.bottomLeft, binnenRect.bottomLeft, verstekPaint);
    canvas.drawLine(
      buitenRect.bottomRight,
      binnenRect.bottomRight,
      verstekPaint,
    );

    if (model.isBinnenmaat) {
      _tekenBreedteMaatBinnen(canvas, binnenRect);
      _tekenHoogteMaatBinnen(canvas, binnenRect);
    } else {
      _tekenBreedteMaatBuiten(canvas, buitenRect);
      _tekenHoogteMaatBuiten(canvas, buitenRect);
    }
  }

  void _tekenBreedteMaatBuiten(Canvas canvas, Rect rect) {
    final y = rect.bottom + 30;
    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: rect.left,
      eindX: rect.right,
      y: y,
      tekst: '${model.breedteMm} mm',
      hulplijnStartY: rect.bottom + 6,
      hulplijnEindY: y + 5,
    );
  }

  void _tekenHoogteMaatBuiten(Canvas canvas, Rect rect) {
    final x = rect.left - 38;
    _tekenVerticaleMaat(
      canvas: canvas,
      x: x,
      startY: rect.top,
      eindY: rect.bottom,
      tekst: '${model.hoogteMm} mm',
      hulplijnStartX: x - 5,
      hulplijnEindX: rect.left - 6,
    );
  }

  void _tekenBreedteMaatBinnen(Canvas canvas, Rect rect) {
    final y = rect.bottom - 18;
    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: rect.left + 4,
      eindX: rect.right - 4,
      y: y,
      tekst: '${model.breedteMm} mm',
    );
  }

  void _tekenHoogteMaatBinnen(Canvas canvas, Rect rect) {
    final x = rect.left + 18;
    _tekenVerticaleMaat(
      canvas: canvas,
      x: x,
      startY: rect.top + 4,
      eindY: rect.bottom - 4,
      tekst: '${model.hoogteMm} mm',
    );
  }

  void _tekenHorizontaleMaat({
    required Canvas canvas,
    required double startX,
    required double eindX,
    required double y,
    required String tekst,
    double? hulplijnStartY,
    double? hulplijnEindY,
  }) {
    final paint = Paint()
      ..color = _maatLijn
      ..strokeWidth = 0.9;

    if (hulplijnStartY != null && hulplijnEindY != null) {
      canvas.drawLine(
        Offset(startX, hulplijnStartY),
        Offset(startX, hulplijnEindY),
        paint,
      );
      canvas.drawLine(
        Offset(eindX, hulplijnStartY),
        Offset(eindX, hulplijnEindY),
        paint,
      );
    }

    final start = Offset(startX, y);
    final einde = Offset(eindX, y);
    canvas.drawLine(start, einde, paint);
    _tekenPijlpunt(canvas, start, true, paint);
    _tekenPijlpunt(canvas, einde, false, paint);
    _tekenMaatTekst(canvas, tekst, Offset((startX + eindX) / 2, y));
  }

  void _tekenVerticaleMaat({
    required Canvas canvas,
    required double x,
    required double startY,
    required double eindY,
    required String tekst,
    double? hulplijnStartX,
    double? hulplijnEindX,
  }) {
    final paint = Paint()
      ..color = _maatLijn
      ..strokeWidth = 0.9;

    if (hulplijnStartX != null && hulplijnEindX != null) {
      canvas.drawLine(
        Offset(hulplijnStartX, startY),
        Offset(hulplijnEindX, startY),
        paint,
      );
      canvas.drawLine(
        Offset(hulplijnStartX, eindY),
        Offset(hulplijnEindX, eindY),
        paint,
      );
    }

    final start = Offset(x, startY);
    final einde = Offset(x, eindY);
    canvas.drawLine(start, einde, paint);
    _tekenVerticalePijlpunt(canvas, start, true, paint);
    _tekenVerticalePijlpunt(canvas, einde, false, paint);

    final textPainter = _maatTextPainter(tekst);
    canvas.save();
    canvas.translate(x, (startY + eindY) / 2);
    canvas.rotate(-math.pi / 2);
    _tekenTekstAchtergrond(
      canvas,
      Rect.fromCenter(
        center: Offset.zero,
        width: textPainter.width + 6,
        height: textPainter.height + 2,
      ),
    );
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  void _tekenMaatTekst(Canvas canvas, String tekst, Offset midden) {
    final textPainter = _maatTextPainter(tekst);
    final rect = Rect.fromCenter(
      center: midden,
      width: textPainter.width + 6,
      height: textPainter.height + 2,
    );
    _tekenTekstAchtergrond(canvas, rect);
    textPainter.paint(
      canvas,
      Offset(
        midden.dx - (textPainter.width / 2),
        midden.dy - (textPainter.height / 2),
      ),
    );
  }

  TextPainter _maatTextPainter(String tekst) {
    return TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: _lijn,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _tekenTekstAchtergrond(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = Colors.white.withOpacity(0.92),
    );
  }

  void _tekenPijlpunt(
    Canvas canvas,
    Offset punt,
    bool naarRechts,
    Paint paint,
  ) {
    final richting = naarRechts ? 1.0 : -1.0;
    canvas.drawLine(punt, Offset(punt.dx + (7 * richting), punt.dy - 4), paint);
    canvas.drawLine(punt, Offset(punt.dx + (7 * richting), punt.dy + 4), paint);
  }

  void _tekenVerticalePijlpunt(
    Canvas canvas,
    Offset punt,
    bool naarBeneden,
    Paint paint,
  ) {
    final richting = naarBeneden ? 1.0 : -1.0;
    canvas.drawLine(punt, Offset(punt.dx - 4, punt.dy + (7 * richting)), paint);
    canvas.drawLine(punt, Offset(punt.dx + 4, punt.dy + (7 * richting)), paint);
  }

  @override
  bool shouldRepaint(covariant OpmetingVasteInzethorPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.schaalFactor != schaalFactor;
  }
}
