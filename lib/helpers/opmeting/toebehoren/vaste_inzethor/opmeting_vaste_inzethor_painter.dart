import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_vaste_inzethor_model.dart';

class OpmetingVasteInzethorPainter extends CustomPainter {
  const OpmetingVasteInzethorPainter({
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingVasteInzethorModel model;
  final double schaalFactor;

  static const Color _lijn = Color(0xFF111827);
  static const Color _profiel = Color(0xFFF3F4F6);
  static const Color _gaasAchtergrond = Color(0xFFFCFCFD);
  static const Color _maatLijn = Color(0xFF4B5563);
  static const Color _flens = Color(0xFFE5E7EB);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const margeBoven = 28.0;
    const margeOnder = 62.0;
    const margeLinks = 74.0;
    const margeRechts = 74.0;

    final buitenBreedteMm = model.buitenBreedteMm.clamp(1, 100000).toDouble();
    final buitenHoogteMm = model.buitenHoogteMm.clamp(1, 100000).toDouble();
    final beschikbareBreedte = math
        .max(40.0, size.width - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(40.0, size.height - margeBoven - margeOnder)
        .toDouble();
    final schaal =
        math.min(
          beschikbareBreedte / buitenBreedteMm,
          beschikbareHoogte / buitenHoogteMm,
        ) *
        schaalFactor.clamp(0.35, 1.0).toDouble();

    final getekendeBreedte = buitenBreedteMm * schaal;
    final getekendeHoogte = buitenHoogteMm * schaal;
    final links = margeLinks + (beschikbareBreedte - getekendeBreedte) / 2;
    final boven = margeBoven + (beschikbareHoogte - getekendeHoogte) / 2;
    final totaalRect = Rect.fromLTWH(
      links,
      boven,
      getekendeBreedte,
      getekendeHoogte,
    );

    final flensPx = model.flensUitsteekMm * schaal;
    final frameLinks = totaalRect.left + flensPx;
    final frameBoven = totaalRect.top + flensPx;
    final frameBreedte = model.kaderBuitenBreedteMm * schaal;
    final profielPx = math
        .max(1.8, model.profielAanzichtMm * schaal)
        .toDouble();
    final traversePx = math
        .max(1.2, model.traverseAanzichtMm * schaal)
        .toDouble();

    if (model.flensUitsteekMm > 0) {
      final flensPaint = Paint()
        ..color = _flens
        ..style = PaintingStyle.fill;
      final flensContour = Paint()
        ..color = _maatLijn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9;
      canvas.drawRect(totaalRect, flensPaint);
      canvas.drawRect(totaalRect, flensContour);
    }

    final hoofdBuitenRect = Rect.fromLTWH(
      frameLinks,
      frameBoven,
      frameBreedte,
      model.hoofdKaderBuitenHoogteMm * schaal,
    );
    final hoofdBinnenRect = _binnenRect(hoofdBuitenRect, profielPx);
    _tekenVolledigRaam(
      canvas: canvas,
      buitenRect: hoofdBuitenRect,
      binnenRect: hoofdBinnenRect,
      schaal: schaal,
      traversePx: traversePx,
      traversePositiesMm: model.actieveTraversePositiesMm,
      referentieHoogteMm: model.hoogteMm.toDouble(),
    );

    Rect? ondersteBuitenRect;
    Rect? ondersteBinnenRect;
    if (model.isVliegenraamDubbel) {
      ondersteBuitenRect = Rect.fromLTWH(
        frameLinks,
        hoofdBuitenRect.bottom,
        frameBreedte,
        model.ondersteKaderBuitenHoogteMm * schaal,
      );
      ondersteBinnenRect = _binnenRect(ondersteBuitenRect, profielPx);
      _tekenVolledigRaam(
        canvas: canvas,
        buitenRect: ondersteBuitenRect,
        binnenRect: ondersteBinnenRect,
        schaal: schaal,
        traversePx: traversePx,
        traversePositiesMm: <double>[model.hoogteOndersteKaderMm / 2],
        referentieHoogteMm: model.hoogteOndersteKaderMm.toDouble(),
      );
    }

    if (model.isVliegenraamDubbel &&
        ondersteBuitenRect != null &&
        ondersteBinnenRect != null) {
      _tekenBreedteMaatBinnen(
        canvas,
        hoofdBinnenRect,
        'B ${model.breedteMm} mm',
      );
      _tekenVerticaleMaat(
        canvas: canvas,
        x: hoofdBinnenRect.left + 18,
        startY: hoofdBinnenRect.top + 4,
        eindY: hoofdBinnenRect.bottom - 4,
        tekst: 'H ${model.hoogteMm} mm',
      );
      _tekenVerticaleMaat(
        canvas: canvas,
        x: ondersteBuitenRect.right + 28,
        startY: ondersteBinnenRect.top + 4,
        eindY: ondersteBinnenRect.bottom - 4,
        tekst: 'L5 ${model.hoogteOndersteKaderMm} mm',
        hulplijnStartX: ondersteBuitenRect.right + 6,
        hulplijnEindX: ondersteBuitenRect.right + 34,
      );
    } else if (model.isBinnenmaat) {
      _tekenBreedteMaatBinnen(canvas, hoofdBinnenRect, '${model.breedteMm} mm');
      _tekenHoogteMaatBinnen(canvas, hoofdBinnenRect, '${model.hoogteMm} mm');
    } else {
      _tekenBreedteMaatBuiten(canvas, hoofdBuitenRect, '${model.breedteMm} mm');
      _tekenHoogteMaatBuiten(canvas, hoofdBuitenRect, '${model.hoogteMm} mm');
    }
  }

  Rect _binnenRect(Rect buitenRect, double profielPx) {
    final veiligeProfiel = math
        .min(profielPx, math.min(buitenRect.width, buitenRect.height) / 3)
        .toDouble();
    return Rect.fromLTRB(
      buitenRect.left + veiligeProfiel,
      buitenRect.top + veiligeProfiel,
      buitenRect.right - veiligeProfiel,
      buitenRect.bottom - veiligeProfiel,
    );
  }

  void _tekenVolledigRaam({
    required Canvas canvas,
    required Rect buitenRect,
    required Rect binnenRect,
    required double schaal,
    required double traversePx,
    required List<double> traversePositiesMm,
    required double referentieHoogteMm,
  }) {
    final profielPaint = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;
    final achtergrondPaint = Paint()
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

    canvas.drawRect(buitenRect, profielPaint);
    canvas.drawRect(binnenRect, achtergrondPaint);
    _tekenGaas(canvas: canvas, binnenRect: binnenRect, schaal: schaal);

    final traverseFill = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;
    for (final positieMm in traversePositiesMm) {
      final verhouding = referentieHoogteMm <= 0
          ? 0.5
          : (positieMm / referentieHoogteMm).clamp(0.0, 1.0).toDouble();
      final y = binnenRect.bottom - binnenRect.height * verhouding;
      final traverseRect = Rect.fromLTWH(
        binnenRect.left,
        y - traversePx / 2,
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
  }

  void _tekenGaas({
    required Canvas canvas,
    required Rect binnenRect,
    required double schaal,
  }) {
    if (!model.heeftGaas || binnenRect.isEmpty) return;
    canvas.save();
    canvas.clipRect(binnenRect);
    if (model.isGaasClearview) {
      _tekenClearviewGaas(canvas, binnenRect, schaal);
    } else if (model.isGaasPetscreenZwart) {
      _tekenPetscreenGaas(
        canvas,
        binnenRect,
        schaal,
        achtergrond: const Color(0xFFF1F2F3),
        lijnkleur: const Color(0xFF374151),
      );
    } else if (model.isGaasPetscreenGrijs || model.isGaasPetscreen) {
      _tekenPetscreenGaas(
        canvas,
        binnenRect,
        schaal,
        achtergrond: const Color(0xFFF4F5F6),
        lijnkleur: const Color(0xFF7A838F),
      );
    } else if (model.isGaasInox) {
      _tekenInoxGaas(canvas, binnenRect, schaal);
    } else {
      _tekenStandaardGaas(canvas, binnenRect, schaal);
    }
    canvas.restore();
  }

  void _tekenStandaardGaas(Canvas canvas, Rect rect, double schaal) {
    final stap = math.max(3.5, 12 * schaal).toDouble();
    _tekenRechthoekigRaster(
      canvas: canvas,
      rect: rect,
      stapX: stap,
      stapY: stap,
      paint: Paint()
        ..color = const Color(0xFFBFC8D3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.45,
    );
  }

  void _tekenClearviewGaas(Canvas canvas, Rect rect, double schaal) {
    final stap = math.max(5.0, 18 * schaal).toDouble();
    _tekenRechthoekigRaster(
      canvas: canvas,
      rect: rect,
      stapX: stap * 1.25,
      stapY: stap,
      paint: Paint()
        ..color = const Color(0xFFAAB8C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.32,
    );
  }

  void _tekenPetscreenGaas(
    Canvas canvas,
    Rect rect,
    double schaal, {
    required Color achtergrond,
    required Color lijnkleur,
  }) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = achtergrond
        ..style = PaintingStyle.fill,
    );
    final stap = math.max(3.2, 9 * schaal).toDouble();
    _tekenRechthoekigRaster(
      canvas: canvas,
      rect: rect,
      stapX: stap,
      stapY: stap,
      paint: Paint()
        ..color = lijnkleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.72,
    );
    final accentPaint = Paint()
      ..color = lijnkleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35;
    for (
      double beginX = rect.left - rect.height;
      beginX <= rect.right;
      beginX += stap * 2
    ) {
      canvas.drawLine(
        Offset(beginX, rect.bottom),
        Offset(beginX + rect.height, rect.top),
        accentPaint,
      );
    }
  }

  void _tekenInoxGaas(Canvas canvas, Rect rect, double schaal) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFFF5F6F7)
        ..style = PaintingStyle.fill,
    );
    final stap = math.max(4.0, 13 * schaal).toDouble();
    final lichtePaint = Paint()
      ..color = const Color(0xFF9AA3AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55;
    final donkerePaint = Paint()
      ..color = const Color(0xFF66707C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.48;
    for (
      double beginX = rect.left - rect.height;
      beginX <= rect.right;
      beginX += stap
    ) {
      canvas.drawLine(
        Offset(beginX, rect.bottom),
        Offset(beginX + rect.height, rect.top),
        lichtePaint,
      );
    }
    for (
      double beginX = rect.left;
      beginX <= rect.right + rect.height;
      beginX += stap
    ) {
      canvas.drawLine(
        Offset(beginX, rect.top),
        Offset(beginX - rect.height, rect.bottom),
        donkerePaint,
      );
    }
  }

  void _tekenRechthoekigRaster({
    required Canvas canvas,
    required Rect rect,
    required double stapX,
    required double stapY,
    required Paint paint,
  }) {
    for (double x = rect.left; x <= rect.right + 0.1; x += stapX) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    for (double y = rect.top; y <= rect.bottom + 0.1; y += stapY) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _tekenBreedteMaatBuiten(Canvas canvas, Rect rect, String tekst) {
    final y = rect.bottom + 30;
    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: rect.left,
      eindX: rect.right,
      y: y,
      tekst: tekst,
      hulplijnStartY: rect.bottom + 6,
      hulplijnEindY: y + 5,
    );
  }

  void _tekenHoogteMaatBuiten(Canvas canvas, Rect rect, String tekst) {
    final x = rect.left - 38;
    _tekenVerticaleMaat(
      canvas: canvas,
      x: x,
      startY: rect.top,
      eindY: rect.bottom,
      tekst: tekst,
      hulplijnStartX: x - 5,
      hulplijnEindX: rect.left - 6,
    );
  }

  void _tekenBreedteMaatBinnen(Canvas canvas, Rect rect, String tekst) {
    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: rect.left + 4,
      eindX: rect.right - 4,
      y: rect.bottom - 18,
      tekst: tekst,
    );
  }

  void _tekenHoogteMaatBinnen(Canvas canvas, Rect rect, String tekst) {
    _tekenVerticaleMaat(
      canvas: canvas,
      x: rect.left + 18,
      startY: rect.top + 4,
      eindY: rect.bottom - 4,
      tekst: tekst,
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
        midden.dx - textPainter.width / 2,
        midden.dy - textPainter.height / 2,
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
      Paint()..color = const Color(0xEBFFFFFF),
    );
  }

  void _tekenPijlpunt(
    Canvas canvas,
    Offset punt,
    bool naarRechts,
    Paint paint,
  ) {
    final richting = naarRechts ? 1.0 : -1.0;
    canvas.drawLine(punt, Offset(punt.dx + 7 * richting, punt.dy - 4), paint);
    canvas.drawLine(punt, Offset(punt.dx + 7 * richting, punt.dy + 4), paint);
  }

  void _tekenVerticalePijlpunt(
    Canvas canvas,
    Offset punt,
    bool naarBeneden,
    Paint paint,
  ) {
    final richting = naarBeneden ? 1.0 : -1.0;
    canvas.drawLine(punt, Offset(punt.dx - 4, punt.dy + 7 * richting), paint);
    canvas.drawLine(punt, Offset(punt.dx + 4, punt.dy + 7 * richting), paint);
  }

  @override
  bool shouldRepaint(covariant OpmetingVasteInzethorPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.schaalFactor != schaalFactor;
  }
}
