// THIMACO-CONTROLE: SEKTIONALE-POORTEN-R-PROFIELEN-MAATVAST-20260729-1313
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-PAINTER-P-COMPILEFIX-20260729-1238
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TEKENING-P-EN-R-EXTRAS-20260729
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_sektionale_poort_model.dart';

class OpmetingSektionalePoortPainter extends CustomPainter {
  const OpmetingSektionalePoortPainter({required this.model});

  final OpmetingSektionalePoortModel model;

  static const Color _lijn = Color(0xFF374151);
  static const Color _maat = Color(0xFF64748B);
  static const Color _fijn = Color(0xFFCBD5E1);
  static const Color _glas = Color(0xFFE7F4FA);

  @override
  void paint(Canvas canvas, Size size) {
    final breedteMm = math.max(1, model.breedteMm);
    final hoogteMm = math.max(1, model.hoogteMm);

    const margeLinks = 54.0;
    const margeRechts = 62.0;
    const margeBoven = 24.0;
    const margeOnder = 48.0;
    final beschikbaarBreedte = math.max(
      40.0,
      size.width - margeLinks - margeRechts,
    );
    final beschikbaarHoogte = math.max(
      40.0,
      size.height - margeBoven - margeOnder,
    );
    final schaal = math.min(
      beschikbaarBreedte / breedteMm,
      beschikbaarHoogte / hoogteMm,
    );
    final deurBreedte = breedteMm * schaal;
    final deurHoogte = hoogteMm * schaal;
    final links = margeLinks + (beschikbaarBreedte - deurBreedte) / 2;
    final boven = margeBoven + (beschikbaarHoogte - deurHoogte) / 2;
    final rect = Rect.fromLTWH(links, boven, deurBreedte, deurHoogte);

    final lijnPaint = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    final fijnPaint = Paint()
      ..color = _fijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;

    // Geen normaal onderkader: onderaan uitsluitend de zwarte rubberstrip.
    final kaderPad = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom);
    canvas.drawPath(kaderPad, lijnPaint);

    final rubberHoogte = math.max(4.0, math.min(10.0, deurHoogte * 0.018));
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left,
        rect.bottom - rubberHoogte,
        rect.width,
        rubberHoogte,
      ),
      Paint()..color = Colors.black,
    );

    final paneelRect = Rect.fromLTRB(
      rect.left + 3,
      rect.top + 3,
      rect.right - 3,
      rect.bottom - rubberHoogte - 1,
    );

    switch (model.modelType) {
      case OpmetingSektionalePoortModelType.g:
        _tekenHorizontaleVerdeling(canvas, paneelRect, 4, lijnPaint);
        break;
      case OpmetingSektionalePoortModelType.w:
        _tekenHorizontaleVerdeling(canvas, paneelRect, 8, lijnPaint);
        break;
      case OpmetingSektionalePoortModelType.s:
        _tekenTypeS(canvas, paneelRect, lijnPaint, schaal);
        break;
      case OpmetingSektionalePoortModelType.r:
        _tekenHorizontaleVerdeling(canvas, paneelRect, 4, lijnPaint);
        _tekenVerticaleGroeven(canvas, paneelRect, schaal, fijnPaint);
        _tekenTypeRExtras(canvas, paneelRect, lijnPaint, schaal);
        break;
      case OpmetingSektionalePoortModelType.n:
        _tekenHorizontaleVerdeling(canvas, paneelRect, 12, lijnPaint);
        break;
      case OpmetingSektionalePoortModelType.v:
        _tekenHorizontaleVerdeling(canvas, paneelRect, 4, lijnPaint);
        _tekenFijneHorizontaleLijnen(canvas, paneelRect, schaal, fijnPaint);
        break;
      case OpmetingSektionalePoortModelType.k:
        _tekenKassettes(canvas, paneelRect, lijnPaint);
        break;
      case OpmetingSektionalePoortModelType.p:
        _tekenTypeP(canvas, paneelRect, lijnPaint);
        break;
    }

    _tekenMaatvoering(canvas, rect, model.breedteMm, model.hoogteMm);
    _tekenModelLabel(canvas, rect);
  }

  void _tekenHorizontaleVerdeling(
    Canvas canvas,
    Rect rect,
    int aantalVakken,
    Paint paint,
  ) {
    for (var index = 1; index < aantalVakken; index++) {
      final y = rect.top + rect.height * index / aantalVakken;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _tekenTypeS(Canvas canvas, Rect rect, Paint paint, double schaal) {
    final extraAfstand = math.max(4.0, 100 * schaal);
    for (var index = 1; index < 4; index++) {
      final hoofdY = rect.top + rect.height * index / 4;
      canvas.drawLine(
        Offset(rect.left, hoofdY),
        Offset(rect.right, hoofdY),
        paint,
      );
      final extraY = hoofdY - extraAfstand;
      if (extraY > rect.top + 2) {
        canvas.drawLine(
          Offset(rect.left, extraY),
          Offset(rect.right, extraY),
          paint,
        );
      }
    }
  }

  void _tekenVerticaleGroeven(
    Canvas canvas,
    Rect rect,
    double schaal,
    Paint paint,
  ) {
    final afstand = math.max(5.0, 100 * schaal);
    for (var x = rect.left + afstand; x < rect.right - 1; x += afstand) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
  }

  void _tekenFijneHorizontaleLijnen(
    Canvas canvas,
    Rect rect,
    double schaal,
    Paint paint,
  ) {
    final afstand = math.max(2.3, 20 * schaal);
    for (var y = rect.top + afstand; y < rect.bottom - 1; y += afstand) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _tekenKassettes(Canvas canvas, Rect rect, Paint paint) {
    const rijen = 4;
    const kolommen = 4;
    final rijHoogte = rect.height / rijen;
    final kolomBreedte = rect.width / kolommen;
    final buitenMargeX = math.max(4.0, kolomBreedte * 0.12);
    final buitenMargeY = math.max(4.0, rijHoogte * 0.18);

    for (var rij = 0; rij < rijen; rij++) {
      for (var kolom = 0; kolom < kolommen; kolom++) {
        final cassette = Rect.fromLTWH(
          rect.left + kolom * kolomBreedte + buitenMargeX,
          rect.top + rij * rijHoogte + buitenMargeY,
          kolomBreedte - buitenMargeX * 2,
          rijHoogte - buitenMargeY * 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cassette, const Radius.circular(1.5)),
          paint,
        );
        final binnen = cassette.deflate(
          math.max(2.0, cassette.shortestSide * 0.08),
        );
        canvas.drawRect(
          binnen,
          Paint()
            ..color = _fijn
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7,
        );
      }
    }
  }

  void _tekenTypeP(Canvas canvas, Rect rect, Paint paint) {
    final aantalPanelen = model.aantalPanelen
        .clamp(
          OpmetingSektionalePoortModel.aantalPanelenMinimum,
          OpmetingSektionalePoortModel.aantalPanelenMaximum,
        )
        .toInt();
    _tekenHorizontaleVerdeling(canvas, rect, aantalPanelen, paint);

    final glasPaint = Paint()
      ..color = _glas
      ..style = PaintingStyle.fill;
    final aluPaint = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final glasLijnPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final paneelHoogte = rect.height / aantalPanelen;

    for (final nummer in model.geldigeGlasPaneelNummers) {
      final indexVanafBoven = aantalPanelen - nummer;
      final paneel = Rect.fromLTWH(
        rect.left,
        rect.top + indexVanafBoven * paneelHoogte,
        rect.width,
        paneelHoogte,
      );
      final kader = paneel.deflate(math.max(3.0, paneel.shortestSide * 0.08));
      canvas.drawRect(kader, glasPaint);
      canvas.drawRect(kader, aluPaint);
      final eersteStijl = kader.left + kader.width / 3;
      final tweedeStijl = kader.left + kader.width * 2 / 3;
      canvas.drawLine(
        Offset(eersteStijl, kader.top),
        Offset(eersteStijl, kader.bottom),
        glasLijnPaint,
      );
      canvas.drawLine(
        Offset(tweedeStijl, kader.top),
        Offset(tweedeStijl, kader.bottom),
        glasLijnPaint,
      );
    }
  }

  void _tekenTypeRExtras(Canvas canvas, Rect rect, Paint paint, double schaal) {
    if (model.rVierkantRaamMetKleinhouten) {
      final aantal = model.rAantalVierkanteRamen.clamp(
        OpmetingSektionalePoortModel.rAantalVierkanteRamenMinimum,
        OpmetingSektionalePoortModel.rAantalVierkanteRamenMaximum,
      );
      _tekenVierkantRaam(
        canvas,
        rect,
        schaal,
        zijde: model.rRaam1Zijde,
        afstandMm: model.rRaam1AfstandMm,
      );
      if (aantal >= 2) {
        _tekenVierkantRaam(
          canvas,
          rect,
          schaal,
          zijde: model.rRaam2Zijde,
          afstandMm: model.rRaam2AfstandMm,
        );
      }
    }

    if (model.rPlintOnderaan) {
      final hoogte = math.min(
        rect.height,
        math.max(3.0, OpmetingSektionalePoortModel.rPlintHoogteMm * schaal),
      );
      final plint = Rect.fromLTWH(
        rect.left,
        rect.bottom - hoogte,
        rect.width,
        hoogte,
      );
      canvas.drawRect(plint, Paint()..color = Colors.white);
      canvas.drawRect(
        plint,
        Paint()
          ..color = _lijn
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    if (model.rVoetjeMetMakelaar) {
      final breedte = math.min(
        rect.width,
        math.max(4.0, OpmetingSektionalePoortModel.rMakelaarBreedteMm * schaal),
      );
      final makelaar = Rect.fromLTWH(
        rect.center.dx - breedte / 2,
        rect.top,
        breedte,
        rect.height,
      );
      canvas.drawRect(makelaar, Paint()..color = Colors.white);
      canvas.drawRect(
        makelaar,
        Paint()
          ..color = _lijn
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7,
      );

      final voetHoogte = math.min(
        makelaar.height,
        math.max(5.0, OpmetingSektionalePoortModel.rVoetjeHoogteMm * schaal),
      );
      final voetje = Rect.fromLTWH(
        makelaar.left,
        makelaar.bottom - voetHoogte,
        makelaar.width,
        voetHoogte,
      );
      canvas.drawRect(voetje, Paint()..color = Colors.black);
      canvas.drawLine(
        Offset(makelaar.left, voetje.top),
        Offset(makelaar.right, voetje.top),
        paint,
      );
    }
  }

  void _tekenVierkantRaam(
    Canvas canvas,
    Rect poortRect,
    double schaal, {
    required OpmetingSektionalePoortRaamZijde zijde,
    required int afstandMm,
  }) {
    final bovenstePaneel = Rect.fromLTRB(
      poortRect.left,
      poortRect.top,
      poortRect.right,
      poortRect.top + poortRect.height / 4,
    );
    final buitenmaat = math.min(
      math.min(bovenstePaneel.width, bovenstePaneel.height),
      math.max(
        12.0,
        OpmetingSektionalePoortModel.rVierkantRaamBuitenmaatMm * schaal,
      ),
    );
    final maximaleAfstandPx = math.max(0.0, poortRect.width - buitenmaat);
    final afstandPx = (math.max(0, afstandMm) * schaal).clamp(
      0.0,
      maximaleAfstandPx,
    );
    final links = zijde == OpmetingSektionalePoortRaamZijde.links
        ? poortRect.left + afstandPx
        : poortRect.right - afstandPx - buitenmaat;
    final boven = bovenstePaneel.center.dy - buitenmaat / 2;
    final buitenKader = Rect.fromLTWH(links, boven, buitenmaat, buitenmaat);

    canvas.drawRect(buitenKader, Paint()..color = Colors.white);
    canvas.drawRect(
      buitenKader,
      Paint()
        ..color = _lijn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final kaderDikte = math.min(
      buitenmaat / 3,
      math.max(
        2.0,
        OpmetingSektionalePoortModel.rVierkantRaamKaderdikteMm * schaal,
      ),
    );
    final glas = buitenKader.deflate(kaderDikte);
    if (glas.width <= 0 || glas.height <= 0) return;

    canvas.drawRect(glas, Paint()..color = _glas);
    canvas.drawRect(
      glas,
      Paint()
        ..color = _lijn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.drawLine(
      Offset(glas.center.dx, glas.top),
      Offset(glas.center.dx, glas.bottom),
      Paint()
        ..color = _lijn
        ..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(glas.left, glas.center.dy),
      Offset(glas.right, glas.center.dy),
      Paint()
        ..color = _lijn
        ..strokeWidth = 1.0,
    );
  }

  void _tekenMaatvoering(
    Canvas canvas,
    Rect rect,
    int breedteMm,
    int hoogteMm,
  ) {
    final paint = Paint()
      ..color = _maat
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final y = rect.bottom + 26;
    canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    canvas.drawLine(
      Offset(rect.left, rect.bottom + 4),
      Offset(rect.left, y + 4),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom + 4),
      Offset(rect.right, y + 4),
      paint,
    );
    _pijl(canvas, Offset(rect.left, y), const Offset(1, 0), paint);
    _pijl(canvas, Offset(rect.right, y), const Offset(-1, 0), paint);
    _tekst(
      canvas,
      '$breedteMm mm',
      Offset(rect.center.dx, y + 4),
      uitlijning: TextAlign.center,
      kleur: _maat,
      grootte: 10,
    );

    final x = rect.right + 28;
    canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    canvas.drawLine(
      Offset(rect.right + 4, rect.top),
      Offset(x + 4, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right + 4, rect.bottom),
      Offset(x + 4, rect.bottom),
      paint,
    );
    _pijl(canvas, Offset(x, rect.top), const Offset(0, 1), paint);
    _pijl(canvas, Offset(x, rect.bottom), const Offset(0, -1), paint);

    canvas.save();
    canvas.translate(x + 13, rect.center.dy);
    canvas.rotate(-math.pi / 2);
    _tekst(
      canvas,
      '$hoogteMm mm',
      Offset.zero,
      uitlijning: TextAlign.center,
      kleur: _maat,
      grootte: 10,
    );
    canvas.restore();
  }

  void _tekenModelLabel(Canvas canvas, Rect rect) {
    _tekst(
      canvas,
      'Type ${model.modelType.label}',
      Offset(rect.center.dx, math.max(2.0, rect.top - 19)),
      uitlijning: TextAlign.center,
      kleur: _lijn,
      grootte: 11,
      vet: true,
    );
  }

  void _pijl(Canvas canvas, Offset punt, Offset richting, Paint paint) {
    const lengte = 6.0;
    const breedte = 3.0;
    final normaal = Offset(-richting.dy, richting.dx);
    final pad = Path()
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(
        punt.dx + richting.dx * lengte + normaal.dx * breedte,
        punt.dy + richting.dy * lengte + normaal.dy * breedte,
      )
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(
        punt.dx + richting.dx * lengte - normaal.dx * breedte,
        punt.dy + richting.dy * lengte - normaal.dy * breedte,
      );
    canvas.drawPath(pad, paint);
  }

  void _tekst(
    Canvas canvas,
    String tekst,
    Offset midden, {
    TextAlign uitlijning = TextAlign.left,
    Color kleur = _lijn,
    double grootte = 10,
    bool vet = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: TextStyle(
          color: kleur,
          fontSize: grootte,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: uitlijning,
    )..layout();

    final dx = uitlijning == TextAlign.center
        ? midden.dx - painter.width / 2
        : midden.dx;
    final dy = midden.dy - painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant OpmetingSektionalePoortPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}
