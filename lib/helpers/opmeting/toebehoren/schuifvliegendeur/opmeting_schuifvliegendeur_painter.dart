// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-PIJLEN-BOVEN-T-STIJL-20260728
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_schuifvliegendeur_model.dart';

class OpmetingSchuifvliegendeurPainter extends CustomPainter {
  const OpmetingSchuifvliegendeurPainter({
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingSchuifvliegendeurModel model;
  final double schaalFactor;

  static const Color _lijn = Color(0xFF334155);
  static const Color _profiel = Color(0xFFF1F5F9);
  static const Color _maat = Color(0xFF64748B);
  static const Color _plaat = Color(0xFFDCEAF2);
  static const Color _wit = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const margeLinks = 24.0;
    const margeRechts = 62.0;
    const margeBovenMetRails = 54.0;
    const margeBovenZonderRails = 28.0;
    const margeOnder = 68.0;

    final deurBreedteMm = math.max(1, model.breedteMm).toDouble();
    final totaleHoogteMm = math.max(1, model.hoogteMm).toDouble();
    final railLengteMm = model.heeftRails
        ? math.max(deurBreedteMm, model.railLengteMm.toDouble())
        : deurBreedteMm;
    final margeBoven = model.heeftRails
        ? margeBovenMetRails
        : margeBovenZonderRails;
    final beschikbareBreedte = math
        .max(40.0, size.width - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(40.0, size.height - margeBoven - margeOnder)
        .toDouble();
    final basisSchaal = math.min(
      beschikbareBreedte / railLengteMm,
      beschikbareHoogte / totaleHoogteMm,
    );
    final schaal = basisSchaal * schaalFactor.clamp(0.35, 1.0).toDouble();

    final railBreedte = railLengteMm * schaal;
    final deurBreedte = deurBreedteMm * schaal;
    final totaleHoogte = totaleHoogteMm * schaal;
    final railLinks = margeLinks + ((beschikbareBreedte - railBreedte) / 2);
    final railRechts = railLinks + railBreedte;
    final boven = margeBoven + ((beschikbareHoogte - totaleHoogte) / 2);
    final onder = boven + totaleHoogte;
    final deurLinks = railLinks + ((railBreedte - deurBreedte) / 2);
    final deurRechts = deurLinks + deurBreedte;

    final contour = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final profiel = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;

    final railDikte = model.heeftRails
        ? math.max(4.0, math.min(11.0, 22 * schaal)).toDouble()
        : 0.0;
    final bovenrail = model.heeftRails
        ? Rect.fromLTWH(railLinks, boven, railBreedte, railDikte)
        : null;
    final onderrail = model.heeftRails
        ? Rect.fromLTWH(railLinks, onder - railDikte, railBreedte, railDikte)
        : null;

    if (bovenrail != null && onderrail != null) {
      _tekenRails(
        canvas,
        bovenrail: bovenrail,
        onderrail: onderrail,
        contour: contour,
        profiel: profiel,
      );
    }

    final deurZone = Rect.fromLTRB(
      deurLinks,
      boven + (model.heeftRails ? railDikte + 3.0 : 0.0),
      deurRechts,
      onder - (model.heeftRails ? railDikte + 3.0 : 0.0),
    );

    final aantalVleugels = model.isDubbel ? 2 : 1;
    final tussenruimte = model.isDubbel
        ? math.max(3.0, 12 * schaal).toDouble()
        : 0.0;
    final vleugelBreedte = math
        .max(
          2.0,
          (deurZone.width - ((aantalVleugels - 1) * tussenruimte)) /
              aantalVleugels,
        )
        .toDouble();
    final vleugelRects = <Rect>[];

    for (var index = 0; index < aantalVleugels; index++) {
      final vleugelRect = Rect.fromLTWH(
        deurZone.left + (index * (vleugelBreedte + tussenruimte)),
        deurZone.top,
        vleugelBreedte,
        deurZone.height,
      );
      vleugelRects.add(vleugelRect);
      _tekenVleugel(
        canvas,
        vleugelRect,
        schaal,
        contour,
        profiel,
        tekenDierenluik: index == 0,
      );
    }

    _tekenSchuifrichting(canvas, vleugelRects, schaal);
    _tekenMaatvoering(
      canvas,
      deurRect: Rect.fromLTRB(deurLinks, boven, deurRechts, onder),
      railRect: Rect.fromLTRB(railLinks, boven, railRechts, onder),
    );
  }

  void _tekenRails(
    Canvas canvas, {
    required Rect bovenrail,
    required Rect onderrail,
    required Paint contour,
    required Paint profiel,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(bovenrail, const Radius.circular(1.5)),
      profiel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bovenrail, const Radius.circular(1.5)),
      contour,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(onderrail, const Radius.circular(1.5)),
      profiel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(onderrail, const Radius.circular(1.5)),
      contour,
    );

    final detail = Paint()
      ..color = _maat
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;
    canvas.drawLine(
      Offset(bovenrail.left + 4, bovenrail.center.dy),
      Offset(bovenrail.right - 4, bovenrail.center.dy),
      detail,
    );
    canvas.drawLine(
      Offset(onderrail.left + 4, onderrail.center.dy),
      Offset(onderrail.right - 4, onderrail.center.dy),
      detail,
    );

    _tekenKleinLabel(
      canvas,
      model.bovenrailCode,
      Offset(bovenrail.right - 3, bovenrail.bottom + 2),
      rechtsUitgelijnd: true,
    );
    _tekenKleinLabel(
      canvas,
      model.onderrailCode,
      Offset(onderrail.right - 3, onderrail.top - 11),
      rechtsUitgelijnd: true,
    );
  }

  void _tekenVleugel(
    Canvas canvas,
    Rect vleugelRect,
    double schaal,
    Paint contour,
    Paint profiel, {
    required bool tekenDierenluik,
  }) {
    final kader = math
        .max(3.0, model.kaderAanzichtMm * schaal)
        .clamp(3.0, vleugelRect.shortestSide * 0.22)
        .toDouble();

    canvas.drawRect(vleugelRect, profiel);
    canvas.drawRect(vleugelRect, contour);

    final binnenRect = vleugelRect.deflate(kader);
    if (binnenRect.width <= 2 || binnenRect.height <= 2) return;

    final traverseHoogte = math
        .max(3.0, model.traverseAanzichtMm * schaal)
        .clamp(3.0, binnenRect.height * 0.13)
        .toDouble();
    final traverseRects = <Rect>[];

    for (final hoogteVanafOnder in model.actieveTraverseHoogtesMm) {
      final y = vleugelRect.bottom - (hoogteVanafOnder * schaal);
      final rect = Rect.fromLTWH(
        vleugelRect.left,
        y - (traverseHoogte / 2),
        vleugelRect.width,
        traverseHoogte,
      );
      if (rect.center.dy > binnenRect.top &&
          rect.center.dy < binnenRect.bottom) {
        traverseRects.add(rect);
      }
    }
    traverseRects.sort((a, b) => a.top.compareTo(b.top));

    final plaatHoogte = model.effectievePlaatHoogteMm;
    Rect? plaatRect;
    if (plaatHoogte > 0) {
      final plaatBoven = (binnenRect.bottom - (plaatHoogte * schaal))
          .clamp(binnenRect.top, binnenRect.bottom)
          .toDouble();
      plaatRect = Rect.fromLTRB(
        binnenRect.left,
        plaatBoven,
        binnenRect.right,
        binnenRect.bottom,
      );
    }

    var segmentTop = binnenRect.top;
    for (var index = 0; index <= traverseRects.length; index++) {
      final segmentBottom = index < traverseRects.length
          ? traverseRects[index].top
          : binnenRect.bottom;
      final segment = Rect.fromLTRB(
        binnenRect.left,
        segmentTop,
        binnenRect.right,
        segmentBottom,
      );

      if (segment.width > 0 && segment.height > 0) {
        final zichtbaarOnder = plaatRect == null
            ? segment.bottom
            : math.min(segment.bottom, plaatRect.top).toDouble();
        final zichtbaarSegment = Rect.fromLTRB(
          segment.left,
          segment.top,
          segment.right,
          zichtbaarOnder,
        );
        if (zichtbaarSegment.height > 0) {
          final isOnderT1 =
              traverseRects.isNotEmpty &&
              zichtbaarSegment.center.dy > traverseRects.last.center.dy;
          _tekenGaas(
            canvas,
            zichtbaarSegment,
            isOnderT1 ? model.gaasOnderT1 : model.gaas,
            contour,
          );
        }
      }

      if (index < traverseRects.length) {
        segmentTop = traverseRects[index].bottom;
      }
    }

    if (plaatRect != null && plaatRect.height > 0) {
      canvas.drawRect(plaatRect, Paint()..color = _plaat);
      canvas.drawRect(plaatRect, contour);
    }

    for (final traverse in traverseRects) {
      canvas.drawRect(traverse, profiel);
      canvas.drawRect(traverse, contour);
    }

    if (tekenDierenluik) {
      _tekenDierenluik(canvas, binnenRect, plaatRect, contour);
    }
  }

  void _tekenDierenluik(
    Canvas canvas,
    Rect binnenRect,
    Rect? plaatRect,
    Paint contour,
  ) {
    if (!model.heeftDierenluik) return;

    final factor = switch (model.dierenluik) {
      OpmetingSchuifvliegendeurModel.dierenluikSmall => 0.22,
      OpmetingSchuifvliegendeurModel.dierenluikMedium => 0.28,
      OpmetingSchuifvliegendeurModel.dierenluikXl => 0.36,
      _ => 0.22,
    };
    final maximaleBreedte = math.max(12.0, binnenRect.width - 12).toDouble();
    final breedte = math
        .min(binnenRect.width * factor, maximaleBreedte)
        .clamp(12.0, maximaleBreedte)
        .toDouble();
    final hoogte = math
        .min(breedte * 1.18, binnenRect.height - 10)
        .clamp(14.0, math.max(14.0, binnenRect.height - 10))
        .toDouble();
    final basisOnder = (plaatRect?.bottom ?? binnenRect.bottom) - 7;
    final boven = (basisOnder - hoogte)
        .clamp(binnenRect.top + 4, binnenRect.bottom - hoogte - 4)
        .toDouble();
    final rect = Rect.fromLTWH(
      binnenRect.center.dx - (breedte / 2),
      boven,
      breedte,
      hoogte,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      contour,
    );
    final boog = Path()
      ..moveTo(rect.left + rect.width * 0.18, rect.top + rect.height * 0.31)
      ..quadraticBezierTo(
        rect.center.dx,
        rect.top + 1.5,
        rect.right - rect.width * 0.18,
        rect.top + rect.height * 0.31,
      );
    canvas.drawPath(boog, contour);
    canvas.drawLine(
      Offset(rect.left + 3, rect.bottom - 4),
      Offset(rect.right - 3, rect.bottom - 4),
      contour,
    );
  }

  void _tekenGaas(Canvas canvas, Rect rect, String gaas, Paint contour) {
    canvas.drawRect(rect, Paint()..color = _wit);

    if (gaas == OpmetingSchuifvliegendeurModel.gaasGeen) {
      canvas.drawRect(rect, contour);
      return;
    }

    final isPetscreen =
        gaas == OpmetingSchuifvliegendeurModel.gaasPetscreenGrijs ||
        gaas == OpmetingSchuifvliegendeurModel.gaasPetscreenZwart;
    final isClearview = gaas == OpmetingSchuifvliegendeurModel.gaasClearview;
    final isInox = gaas == OpmetingSchuifvliegendeurModel.gaasInox;
    final isZwart = gaas == OpmetingSchuifvliegendeurModel.gaasPetscreenZwart;

    final raster = Paint()
      ..color = isZwart
          ? const Color(0xFF64748B)
          : isPetscreen
          ? const Color(0xFF94A3B8)
          : isInox
          ? const Color(0xFF9CA3AF)
          : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPetscreen ? 0.65 : 0.45;
    final stap = isClearview
        ? 12.0
        : isPetscreen
        ? 5.5
        : isInox
        ? 7.0
        : 8.5;

    canvas.save();
    canvas.clipRect(rect);
    for (double x = rect.left; x <= rect.right; x += stap) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), raster);
    }
    for (double y = rect.top; y <= rect.bottom; y += stap) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), raster);
    }
    canvas.restore();
    canvas.drawRect(rect, contour);
  }

  void _tekenSchuifrichting(
    Canvas canvas,
    List<Rect> vleugelRects,
    double schaal,
  ) {
    if (vleugelRects.isEmpty) return;

    final pijlPaint = Paint()
      ..color = _maat
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final pijlY = _bepaalSchuifPijlY(vleugelRects.first, schaal);

    if (vleugelRects.length == 1) {
      final rect = vleugelRects.first.deflate(
        math.min(18.0, vleugelRects.first.width * 0.18).toDouble(),
      );
      final start = Offset(rect.left, pijlY);
      final einde = Offset(rect.right, pijlY);
      canvas.drawLine(start, einde, pijlPaint);
      _tekenPijl(canvas, start, true, pijlPaint);
      _tekenPijl(canvas, einde, false, pijlPaint);
      return;
    }

    final links = vleugelRects.first;
    final rechts = vleugelRects.last;
    final middenX = (links.right + rechts.left) / 2;
    final linksStart = Offset(middenX - 3, pijlY);
    final linksEinde = Offset(links.left + links.width * 0.22, pijlY);
    final rechtsStart = Offset(middenX + 3, pijlY);
    final rechtsEinde = Offset(rechts.right - rechts.width * 0.22, pijlY);
    canvas.drawLine(linksStart, linksEinde, pijlPaint);
    canvas.drawLine(rechtsStart, rechtsEinde, pijlPaint);
    _tekenPijl(canvas, linksEinde, true, pijlPaint);
    _tekenPijl(canvas, rechtsEinde, false, pijlPaint);
  }

  double _bepaalSchuifPijlY(Rect vleugelRect, double schaal) {
    final traverseHoogtes = model.actieveTraverseHoogtesMm;
    if (traverseHoogtes.isEmpty) {
      return vleugelRect.center.dy;
    }

    final t1Midden = vleugelRect.bottom - (traverseHoogtes.first * schaal);
    final halveTraverse = math.max(
      2.0,
      (model.traverseAanzichtMm * schaal) / 2,
    );
    final vrijeRuimte = math.max(7.0, halveTraverse + 5.0);
    return (t1Midden - vrijeRuimte)
        .clamp(vleugelRect.top + 13.0, vleugelRect.bottom - 13.0)
        .toDouble();
  }

  void _tekenMaatvoering(
    Canvas canvas, {
    required Rect deurRect,
    required Rect railRect,
  }) {
    final maatPaint = Paint()
      ..color = _maat
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    if (model.heeftRails) {
      final railY = railRect.top - 25;
      _tekenHorizontaleMaat(
        canvas: canvas,
        startX: railRect.left,
        eindX: railRect.right,
        y: railY,
        tekst: '${model.railLengteMm} mm',
        hulplijnStartY: railRect.top - 3,
        hulplijnEindY: railY - 4,
        paint: maatPaint,
      );
    }

    final breedteY = deurRect.bottom + 30;
    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: deurRect.left,
      eindX: deurRect.right,
      y: breedteY,
      tekst: '${model.breedteMm} mm',
      hulplijnStartY: deurRect.bottom + 5,
      hulplijnEindY: breedteY + 5,
      paint: maatPaint,
    );

    final hoogteX = railRect.right + 27;
    canvas.drawLine(
      Offset(deurRect.right + 5, deurRect.top),
      Offset(hoogteX + 5, deurRect.top),
      maatPaint,
    );
    canvas.drawLine(
      Offset(deurRect.right + 5, deurRect.bottom),
      Offset(hoogteX + 5, deurRect.bottom),
      maatPaint,
    );
    canvas.drawLine(
      Offset(hoogteX, deurRect.top),
      Offset(hoogteX, deurRect.bottom),
      maatPaint,
    );
    _tekenPijlVerticaal(canvas, Offset(hoogteX, deurRect.top), true, maatPaint);
    _tekenPijlVerticaal(
      canvas,
      Offset(hoogteX, deurRect.bottom),
      false,
      maatPaint,
    );
    canvas.save();
    canvas.translate(hoogteX + 8, deurRect.center.dy);
    canvas.rotate(-math.pi / 2);
    _tekenMaatTekst(
      canvas,
      '${model.hoogteMm} mm',
      Offset.zero,
      horizontaalGecentreerd: true,
    );
    canvas.restore();
  }

  void _tekenHorizontaleMaat({
    required Canvas canvas,
    required double startX,
    required double eindX,
    required double y,
    required String tekst,
    required double hulplijnStartY,
    required double hulplijnEindY,
    required Paint paint,
  }) {
    canvas.drawLine(Offset(startX, y), Offset(eindX, y), paint);
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
    _tekenPijl(canvas, Offset(startX, y), true, paint);
    _tekenPijl(canvas, Offset(eindX, y), false, paint);
    _tekenMaatTekst(
      canvas,
      tekst,
      Offset((startX + eindX) / 2, y + 2),
      horizontaalGecentreerd: true,
    );
  }

  void _tekenPijl(Canvas canvas, Offset punt, bool naarRechts, Paint paint) {
    final richting = naarRechts ? 1.0 : -1.0;
    canvas.drawLine(punt, punt + Offset(5 * richting, -2.5), paint);
    canvas.drawLine(punt, punt + Offset(5 * richting, 2.5), paint);
  }

  void _tekenPijlVerticaal(
    Canvas canvas,
    Offset punt,
    bool naarOnder,
    Paint paint,
  ) {
    final richting = naarOnder ? 1.0 : -1.0;
    canvas.drawLine(punt, punt + Offset(-2.5, 5 * richting), paint);
    canvas.drawLine(punt, punt + Offset(2.5, 5 * richting), paint);
  }

  void _tekenMaatTekst(
    Canvas canvas,
    String tekst,
    Offset positie, {
    required bool horizontaalGecentreerd,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: _maat,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final x = horizontaalGecentreerd
        ? positie.dx - (painter.width / 2)
        : positie.dx;
    final achtergrond = Rect.fromLTWH(
      x - 3,
      positie.dy - 1,
      painter.width + 6,
      painter.height + 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(achtergrond, const Radius.circular(2)),
      Paint()..color = Colors.white,
    );
    painter.paint(canvas, Offset(x, positie.dy));
  }

  void _tekenKleinLabel(
    Canvas canvas,
    String tekst,
    Offset positie, {
    bool rechtsUitgelijnd = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        rechtsUitgelijnd ? positie.dx - painter.width : positie.dx,
        positie.dy,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant OpmetingSchuifvliegendeurPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.schaalFactor != schaalFactor;
  }
}
