import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_vliegendeur_model.dart';

class OpmetingVliegendeurPainter extends CustomPainter {
  const OpmetingVliegendeurPainter({
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingVliegendeurModel model;
  final double schaalFactor;

  static const Color _lijn = Color(0xFF111827);
  static const Color _profiel = Color(0xFFF3F4F6);
  static const Color _gaasAchtergrond = Color(0xFFFCFCFD);
  static const Color _onderpaneel = Color(0xFFDCEAF2);
  static const Color _maatLijn = Color(0xFF4B5563);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const margeLinks = 68.0;
    const margeRechts = 34.0;
    const margeBoven = 50.0;
    const margeOnder = 62.0;
    final buitenBreedteMm = math.max(1, model.breedteMm).toDouble();
    final buitenHoogteMm = math.max(1, model.hoogteMm).toDouble();
    final beschikbareBreedte = math.max(
      40.0,
      size.width - margeLinks - margeRechts,
    );
    final beschikbareHoogte = math.max(
      40.0,
      size.height - margeBoven - margeOnder,
    );
    final basisSchaal = math.min(
      beschikbareBreedte / buitenBreedteMm,
      beschikbareHoogte / buitenHoogteMm,
    );
    final schaal = basisSchaal * schaalFactor.clamp(0.35, 1.0).toDouble();

    final getekendeBreedte = buitenBreedteMm * schaal;
    final getekendeHoogte = buitenHoogteMm * schaal;
    final buitenRect = Rect.fromLTWH(
      margeLinks +
          ((beschikbareBreedte - getekendeBreedte) / 2)
              .clamp(0.0, double.infinity)
              .toDouble(),
      margeBoven +
          ((beschikbareHoogte - getekendeHoogte) / 2)
              .clamp(0.0, double.infinity)
              .toDouble(),
      getekendeBreedte,
      getekendeHoogte,
    );

    final buitenStijlMm = model.isZonderKader
        ? 0
        : model.isSmalleKader
        ? 11
        : OpmetingVliegendeurModel.buitenStijlAanzichtMm;
    final buitenStijlPx = math.max(0.0, buitenStijlMm * schaal).toDouble();
    final deurProfielPx = math
        .max(1.2, OpmetingVliegendeurModel.deurProfielAanzichtMm * schaal)
        .toDouble();
    final traversePx = math
        .max(2.0, OpmetingVliegendeurModel.middenregelAanzichtMm * schaal)
        .toDouble();

    final deurRect = Rect.fromLTRB(
      buitenRect.left + buitenStijlPx,
      buitenRect.top,
      buitenRect.right - buitenStijlPx,
      buitenRect.bottom,
    );

    final profielPaint = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;
    final contourPaint = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    if (!model.isZonderKader) {
      final linkerBuitenStijl = Rect.fromLTWH(
        buitenRect.left,
        buitenRect.top,
        buitenStijlPx,
        buitenRect.height,
      );
      final rechterBuitenStijl = Rect.fromLTWH(
        buitenRect.right - buitenStijlPx,
        buitenRect.top,
        buitenStijlPx,
        buitenRect.height,
      );
      canvas.drawRect(linkerBuitenStijl, profielPaint);
      canvas.drawRect(rechterBuitenStijl, profielPaint);
      canvas.drawRect(linkerBuitenStijl, contourPaint);
      canvas.drawRect(rechterBuitenStijl, contourPaint);

      if (model.kaderuitvoering == OpmetingVliegendeurModel.kaderRondom) {
        final onderKader = Rect.fromLTWH(
          buitenRect.left,
          buitenRect.bottom - buitenStijlPx,
          buitenRect.width,
          buitenStijlPx,
        );
        canvas.drawRect(onderKader, profielPaint);
        canvas.drawRect(onderKader, contourPaint);
      }
    }

    final frameDelen = <Rect>[
      Rect.fromLTWH(deurRect.left, deurRect.top, deurRect.width, deurProfielPx),
      Rect.fromLTWH(
        deurRect.left,
        deurRect.bottom - deurProfielPx,
        deurRect.width,
        deurProfielPx,
      ),
      Rect.fromLTWH(
        deurRect.left,
        deurRect.top,
        deurProfielPx,
        deurRect.height,
      ),
      Rect.fromLTWH(
        deurRect.right - deurProfielPx,
        deurRect.top,
        deurProfielPx,
        deurRect.height,
      ),
    ];

    for (final rect in frameDelen) {
      canvas.drawRect(rect, profielPaint);
      canvas.drawRect(rect, contourPaint);
    }

    final binnenRect = Rect.fromLTRB(
      deurRect.left + deurProfielPx,
      deurRect.top + deurProfielPx,
      deurRect.right - deurProfielPx,
      deurRect.bottom - deurProfielPx,
    );

    final traverseBovenkantenMm =
        model.actieveDoorgangHoogtesMm
            .map((hoogte) {
              return (hoogte +
                      OpmetingVliegendeurModel.deurProfielAanzichtMm +
                      OpmetingVliegendeurModel.middenregelAanzichtMm +
                      OpmetingVliegendeurModel.buitenStijlAanzichtMm)
                  .clamp(
                    150,
                    model.hoogteMm -
                        OpmetingVliegendeurModel.deurProfielAanzichtMm -
                        1,
                  )
                  .toDouble();
            })
            .toList(growable: false)
          ..sort();

    final traverseRects = <Rect>[];
    for (final bovenkantVanafOnderMm in traverseBovenkantenMm) {
      final top = deurRect.bottom - (bovenkantVanafOnderMm * schaal);
      final rect = Rect.fromLTWH(
        deurRect.left,
        top,
        deurRect.width,
        traversePx,
      );
      traverseRects.add(rect);
    }

    final schopplaatBovenkantMm = model.schopplaatBovenkantVanafOnderMm;
    Rect? schopplaatRect;
    Rect? schopplaatTussenregelRect;

    if (model.heeftSchopplaat && schopplaatBovenkantMm > 0) {
      final bovenkant = deurRect.bottom - (schopplaatBovenkantMm * schaal);
      final totTussenstijl =
          model.schopplaat == OpmetingVliegendeurModel.schopplaatTotTussenstijl;
      final tussenregelTop = totTussenstijl
          ? (traverseRects.isEmpty ? bovenkant : traverseRects.first.bottom)
          : bovenkant;

      if (!totTussenstijl) {
        schopplaatTussenregelRect = Rect.fromLTWH(
          deurRect.left,
          tussenregelTop,
          deurRect.width,
          deurProfielPx,
        );
      }

      final paneelTop = schopplaatTussenregelRect?.bottom ?? tussenregelTop;
      schopplaatRect = Rect.fromLTRB(
        binnenRect.left,
        paneelTop,
        binnenRect.right,
        binnenRect.bottom,
      );
    }

    final horizontaleBlokkades = <Rect>[
      ...traverseRects,
      if (schopplaatTussenregelRect != null) schopplaatTussenregelRect,
    ]..sort((eerste, tweede) => eerste.top.compareTo(tweede.top));

    var segmentTop = binnenRect.top;
    for (var index = 0; index <= horizontaleBlokkades.length; index++) {
      final segmentBottom = index < horizontaleBlokkades.length
          ? horizontaleBlokkades[index].top
          : binnenRect.bottom;
      final segment = Rect.fromLTRB(
        binnenRect.left,
        segmentTop,
        binnenRect.right,
        segmentBottom,
      );

      if (segment.width > 0 && segment.height > 0) {
        final bedektDoorSchopplaat =
            schopplaatRect != null && segment.bottom > schopplaatRect.top + 0.1;
        if (!bedektDoorSchopplaat) {
          final onderEersteTraverse =
              traverseRects.isNotEmpty &&
              segment.center.dy > traverseRects.first.center.dy;
          _tekenGaas(
            canvas,
            segment,
            schaal,
            onderEersteTraverse ? model.gaasOnderT1 : model.gaas,
            contourPaint,
          );
        }
      }

      if (index < horizontaleBlokkades.length) {
        segmentTop = horizontaleBlokkades[index].bottom;
      }
    }

    if (schopplaatRect != null &&
        schopplaatRect.width > 0 &&
        schopplaatRect.height > 0) {
      canvas.drawRect(
        schopplaatRect,
        Paint()
          ..color = _onderpaneel
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(schopplaatRect, contourPaint);
    }

    for (final rect in horizontaleBlokkades) {
      canvas.drawRect(rect, profielPaint);
      canvas.drawRect(rect, contourPaint);
    }

    final isDubbeleDeur = model.isDubbeleDeur;
    final scharnierLinks =
        model.scharnierkant.trim().toLowerCase() ==
        OpmetingVliegendeurModel.scharnierLinks.toLowerCase();

    if (isDubbeleDeur) {
      final middenStijl = Rect.fromLTWH(
        binnenRect.center.dx - (deurProfielPx / 2),
        deurRect.top,
        deurProfielPx,
        deurRect.height,
      );
      canvas.drawRect(middenStijl, profielPaint);
      canvas.drawRect(middenStijl, contourPaint);
    }

    _tekenDraairichting(
      canvas,
      binnenRect,
      deurProfielPx,
      isDubbeleDeur: isDubbeleDeur,
      scharnierLinks: scharnierLinks,
    );
    _tekenScharnieren(
      canvas,
      deurRect,
      schaal,
      contourPaint,
      isDubbeleDeur: isDubbeleDeur,
      scharnierLinks: scharnierLinks,
    );
    _tekenDierenluik(canvas, binnenRect, schopplaatRect, contourPaint);
    canvas.drawRect(buitenRect, contourPaint);
    _tekenBuitenzicht(canvas, buitenRect);
    _tekenBreedteMaatBuiten(canvas, buitenRect);
    _tekenHoogteMaatBuiten(canvas, buitenRect);
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

  void _tekenBuitenzicht(Canvas canvas, Rect buitenRect) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Buitenzicht',
        style: TextStyle(
          color: _lijn,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final x = buitenRect.center.dx - (textPainter.width / 2);
    final y = math
        .max(6.0, buitenRect.top - textPainter.height - 12)
        .toDouble();
    textPainter.paint(canvas, Offset(x, y));
  }

  void _tekenDraairichting(
    Canvas canvas,
    Rect binnenRect,
    double deurProfielPx, {
    required bool isDubbeleDeur,
    required bool scharnierLinks,
  }) {
    final symboolVlak = binnenRect.deflate(3);
    if (symboolVlak.width <= 8 || symboolVlak.height <= 8) return;

    if (isDubbeleDeur) {
      final halveMiddenStijl = deurProfielPx / 2;
      final linkerVleugel = Rect.fromLTRB(
        symboolVlak.left,
        symboolVlak.top,
        symboolVlak.center.dx - halveMiddenStijl,
        symboolVlak.bottom,
      );
      final rechterVleugel = Rect.fromLTRB(
        symboolVlak.center.dx + halveMiddenStijl,
        symboolVlak.top,
        symboolVlak.right,
        symboolVlak.bottom,
      );

      if (linkerVleugel.width > 8) {
        _tekenDraaiLinks(canvas, linkerVleugel);
      }
      if (rechterVleugel.width > 8) {
        _tekenDraaiRechts(canvas, rechterVleugel);
      }
      return;
    }

    // Bij een enkele deur vertrekken de richtingslijnen vanaf de
    // scharnierzijde en komen ze samen aan de sluitzijde.
    // Daarom is de tekenrichting tegengesteld aan de scharnierzijde.
    if (scharnierLinks) {
      _tekenDraaiRechts(canvas, symboolVlak);
    } else {
      _tekenDraaiLinks(canvas, symboolVlak);
    }
  }

  void _tekenDraaiLinks(Canvas canvas, Rect vlak) {
    final lijn = _draairichtingPaint();
    final puntLinks = Offset(vlak.left, vlak.center.dy);
    canvas.drawLine(vlak.topRight, puntLinks, lijn);
    canvas.drawLine(vlak.bottomRight, puntLinks, lijn);
  }

  void _tekenDraaiRechts(Canvas canvas, Rect vlak) {
    final lijn = _draairichtingPaint();
    final puntRechts = Offset(vlak.right, vlak.center.dy);
    canvas.drawLine(vlak.topLeft, puntRechts, lijn);
    canvas.drawLine(vlak.bottomLeft, puntRechts, lijn);
  }

  Paint _draairichtingPaint() {
    return Paint()
      ..color = _lijn.withOpacity(0.82)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  void _tekenGaas(
    Canvas canvas,
    Rect rect,
    double schaal,
    String gaastype,
    Paint contourPaint,
  ) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = _gaasAchtergrond
        ..style = PaintingStyle.fill,
    );

    final isPetscreen =
        gaastype == OpmetingVliegendeurModel.gaasPetscreenGrijs ||
        gaastype == OpmetingVliegendeurModel.gaasPetscreenZwart;
    final isZwart = gaastype == OpmetingVliegendeurModel.gaasPetscreenZwart;
    final isClearview = gaastype == OpmetingVliegendeurModel.gaasClearview;
    final gaasPaint = Paint()
      ..color = isZwart
          ? const Color(0xFF6B7280)
          : isPetscreen
          ? const Color(0xFF94A3B8)
          : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPetscreen ? 0.65 : 0.45;
    final stapMm = isClearview
        ? 16.0
        : isPetscreen
        ? 8.0
        : 12.0;
    final rasterStapPx = math.max(3.2, stapMm * schaal).toDouble();

    canvas.save();
    canvas.clipRect(rect);
    for (double x = rect.left; x <= rect.right + 0.1; x += rasterStapPx) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gaasPaint);
    }
    for (double y = rect.top; y <= rect.bottom + 0.1; y += rasterStapPx) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gaasPaint);
    }
    canvas.restore();
    canvas.drawRect(rect, contourPaint);
  }

  void _tekenScharnieren(
    Canvas canvas,
    Rect deurRect,
    double schaal,
    Paint contourPaint, {
    required bool isDubbeleDeur,
    required bool scharnierLinks,
  }) {
    final scharnierBreedte = math.max(3.0, 12 * schaal).toDouble();
    final scharnierHoogte = math.max(7.0, 38 * schaal).toDouble();

    if (isDubbeleDeur) {
      _tekenScharnierenAanZijde(
        canvas: canvas,
        deurRect: deurRect,
        scharnierBreedte: scharnierBreedte,
        scharnierHoogte: scharnierHoogte,
        links: true,
        contourPaint: contourPaint,
      );
      _tekenScharnierenAanZijde(
        canvas: canvas,
        deurRect: deurRect,
        scharnierBreedte: scharnierBreedte,
        scharnierHoogte: scharnierHoogte,
        links: false,
        contourPaint: contourPaint,
      );
      return;
    }

    _tekenScharnierenAanZijde(
      canvas: canvas,
      deurRect: deurRect,
      scharnierBreedte: scharnierBreedte,
      scharnierHoogte: scharnierHoogte,
      links: scharnierLinks,
      contourPaint: contourPaint,
    );
  }

  void _tekenScharnierenAanZijde({
    required Canvas canvas,
    required Rect deurRect,
    required double scharnierBreedte,
    required double scharnierHoogte,
    required bool links,
    required Paint contourPaint,
  }) {
    final x = links
        ? deurRect.left - (scharnierBreedte * 0.15)
        : deurRect.right + (scharnierBreedte * 0.15);

    for (final verhouding in <double>[0.18, 0.5, 0.82]) {
      final rect = Rect.fromCenter(
        center: Offset(x, deurRect.top + (deurRect.height * verhouding)),
        width: scharnierBreedte,
        height: scharnierHoogte,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()
          ..color = const Color(0xFFD1D5DB)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        contourPaint,
      );
    }
  }

  void _tekenDierenluik(
    Canvas canvas,
    Rect binnenRect,
    Rect? schopplaatRect,
    Paint contourPaint,
  ) {
    if (!model.heeftDierenluik) return;

    final factor = switch (model.dierenluik) {
      OpmetingVliegendeurModel.dierenluikSmall => 0.22,
      OpmetingVliegendeurModel.dierenluikMedium => 0.28,
      OpmetingVliegendeurModel.dierenluikXl => 0.36,
      _ => 0.22,
    };
    final breedte = math
        .min(binnenRect.width * factor, binnenRect.width - 12)
        .toDouble();
    final hoogte = breedte * 1.18;
    final basisBottom = (schopplaatRect?.bottom ?? binnenRect.bottom) - 8;
    final rect = Rect.fromLTWH(
      binnenRect.center.dx - (breedte / 2),
      basisBottom - hoogte,
      breedte,
      hoogte,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(rect, contourPaint);
    canvas.drawLine(rect.topLeft, rect.bottomRight, contourPaint);
    canvas.drawLine(rect.topRight, rect.bottomLeft, contourPaint);
  }

  @override
  bool shouldRepaint(covariant OpmetingVliegendeurPainter oldDelegate) {
    return oldDelegate.schaalFactor != schaalFactor ||
        oldDelegate.model.soort != model.soort ||
        oldDelegate.model.scharnierkant != model.scharnierkant ||
        oldDelegate.model != model;
  }
}
