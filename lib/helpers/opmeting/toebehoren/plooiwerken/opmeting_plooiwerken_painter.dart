// THIMACO-CONTROLE: PLOOIWERKEN-LAKLIJN-VOLGENS-AFWERKING-20260728
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_plooiwerken_model.dart';

class OpmetingPlooiwerkenPainter extends CustomPainter {
  const OpmetingPlooiwerkenPainter({required this.model});

  final OpmetingPlooiwerkenModel model;

  static const Color _lijnKleur = Color(0xFF374151);
  static const Color _maatKleur = Color(0xFF475569);
  static const Color _hulpKleur = Color(0xFFCBD5E1);
  static const Color _lakKleur = Color(0xFFDC2626);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final geometrie = _bouwGeometrie(model);
    if (geometrie.punten.length < 2) return;

    final binnenRect = Rect.fromLTWH(
      54,
      48,
      math.max(1.0, size.width - 108),
      math.max(1.0, size.height - 96),
    );
    final transformatie = _berekenTransformatie(
      punten: geometrie.punten,
      doelRect: binnenRect,
    );
    final canvasPunten = geometrie.punten
        .map(transformatie.naarCanvas)
        .toList(growable: false);

    _tekenLakzijden(canvas, canvasPunten);
    _tekenPlooiwerk(canvas, canvasPunten);
    _tekenMaatvoering(canvas, canvasPunten, geometrie.lengtesMm);
    _tekenHoekWaarden(canvas, canvasPunten);
    _tekenHulpmiddel(
      canvas: canvas,
      size: size,
      geometrie: geometrie,
      canvasPunten: canvasPunten,
    );
  }

  _PlooiGeometrie _bouwGeometrie(OpmetingPlooiwerkenModel model) {
    final lengtes = model.actieveLengtesMm;
    final hoeken = model.actieveHoekenGraden;
    final punten = <Offset>[Offset.zero];
    final getekendeLengtes = <int>[];

    var richting = 0.0;

    for (var index = 0; index < lengtes.length; index++) {
      final lengte = lengtes[index];
      if (lengte == null || lengte <= 0) break;

      if (index > 0) {
        final hoek = hoeken[index - 1];
        if (hoek == null) break;
        richting = richting + math.pi - _radialen(hoek.toDouble());
      }

      final vorig = punten.last;
      final volgend = Offset(
        vorig.dx + math.cos(richting) * lengte,
        vorig.dy + math.sin(richting) * lengte,
      );
      punten.add(volgend);
      getekendeLengtes.add(lengte);
    }

    final rotatie = -_radialen(model.tekeningRotatieGraden.toDouble());
    final geroteerdePunten = punten
        .map((punt) {
          return Offset(
            punt.dx * math.cos(rotatie) - punt.dy * math.sin(rotatie),
            punt.dx * math.sin(rotatie) + punt.dy * math.cos(rotatie),
          );
        })
        .toList(growable: false);

    double? hulprichting;
    final getekendeSegmenten = getekendeLengtes.length;
    if (getekendeSegmenten > 0 && getekendeSegmenten < model.aantalZijden) {
      var laatsteRichting = 0.0;
      for (var index = 1; index < getekendeSegmenten; index++) {
        final hoek = hoeken[index - 1];
        if (hoek == null) break;
        laatsteRichting =
            laatsteRichting + math.pi - _radialen(hoek.toDouble());
      }

      final volgendeHoek = hoeken[getekendeSegmenten - 1];
      if (volgendeHoek != null) {
        hulprichting =
            laatsteRichting +
            math.pi -
            _radialen(volgendeHoek.toDouble()) +
            rotatie;
      }
    }

    return _PlooiGeometrie(
      punten: geroteerdePunten,
      lengtesMm: getekendeLengtes,
      hulprichting: hulprichting,
      heeftVolgendePlooi:
          getekendeSegmenten > 0 && getekendeSegmenten < model.aantalZijden,
    );
  }

  void _tekenPlooiwerk(Canvas canvas, List<Offset> punten) {
    final paint = Paint()
      ..color = _lijnKleur
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(punten.first.dx, punten.first.dy);
    for (final punt in punten.skip(1)) {
      path.lineTo(punt.dx, punt.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _tekenLakzijden(Canvas canvas, List<Offset> punten) {
    if (!model.toonLakAanduiding || punten.length < 2) return;

    if (model.lakzijde == OpmetingPlooiwerkenLakzijde.zijde1 ||
        model.lakzijde == OpmetingPlooiwerkenLakzijde.beideZijden) {
      _tekenOffsetZijde(canvas, punten, zijde: 1);
    }
    if (model.lakzijde == OpmetingPlooiwerkenLakzijde.zijde2 ||
        model.lakzijde == OpmetingPlooiwerkenLakzijde.beideZijden) {
      _tekenOffsetZijde(canvas, punten, zijde: -1);
    }
  }

  void _tekenOffsetZijde(
    Canvas canvas,
    List<Offset> punten, {
    required double zijde,
  }) {
    const afstand = 8.0;
    if (punten.length < 2) return;

    final richtingen = <Offset>[];
    final normalen = <Offset>[];

    for (var index = 0; index < punten.length - 1; index++) {
      final richting = punten[index + 1] - punten[index];
      final eenheid = _eenheidsVector(richting);
      if (eenheid == null) continue;
      richtingen.add(eenheid);
      normalen.add(
        Offset(-eenheid.dy * afstand * zijde, eenheid.dx * afstand * zijde),
      );
    }

    if (richtingen.isEmpty) return;

    final paint = Paint()
      ..color = _lakKleur
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(
        punten.first.dx + normalen.first.dx,
        punten.first.dy + normalen.first.dy,
      );

    for (var index = 1; index < punten.length - 1; index++) {
      final hoekPunt = punten[index];
      final vorigeRichting = richtingen[index - 1];
      final volgendeRichting = richtingen[index];
      final vorigeNormaal = normalen[index - 1];
      final volgendeNormaal = normalen[index];
      final vorigeOffset = hoekPunt + vorigeNormaal;
      final volgendeOffset = hoekPunt + volgendeNormaal;

      final snijpunt = _snijpuntVanLijnen(
        vorigeOffset,
        vorigeRichting,
        volgendeOffset,
        volgendeRichting,
      );

      if (snijpunt != null && (snijpunt - hoekPunt).distance <= afstand * 4.0) {
        path.lineTo(snijpunt.dx, snijpunt.dy);
        continue;
      }

      path.lineTo(vorigeOffset.dx, vorigeOffset.dy);
      final straal = math.max(1.0, vorigeNormaal.distance);
      final startHoek = math.atan2(vorigeNormaal.dy, vorigeNormaal.dx);
      final eindHoek = math.atan2(volgendeNormaal.dy, volgendeNormaal.dx);
      final sweep = _kortsteHoekVerschil(startHoek, eindHoek);
      path.arcTo(
        Rect.fromCircle(center: hoekPunt, radius: straal),
        startHoek,
        sweep,
        false,
      );
    }

    final laatste = punten.last + normalen.last;
    path.lineTo(laatste.dx, laatste.dy);
    canvas.drawPath(path, paint);
  }

  Offset? _snijpuntVanLijnen(
    Offset eerstePunt,
    Offset eersteRichting,
    Offset tweedePunt,
    Offset tweedeRichting,
  ) {
    final noemer = _kruisProduct(eersteRichting, tweedeRichting);
    if (noemer.abs() <= 0.0001) return null;

    final verschil = tweedePunt - eerstePunt;
    final factor = _kruisProduct(verschil, tweedeRichting) / noemer;
    return eerstePunt + eersteRichting * factor;
  }

  double _kruisProduct(Offset eerste, Offset tweede) {
    return eerste.dx * tweede.dy - eerste.dy * tweede.dx;
  }

  double _kortsteHoekVerschil(double start, double einde) {
    var verschil = einde - start;
    while (verschil > math.pi) {
      verschil -= math.pi * 2;
    }
    while (verschil < -math.pi) {
      verschil += math.pi * 2;
    }
    return verschil;
  }

  void _tekenMaatvoering(
    Canvas canvas,
    List<Offset> punten,
    List<int> lengtesMm,
  ) {
    for (
      var index = 0;
      index < punten.length - 1 && index < lengtesMm.length;
      index++
    ) {
      final begin = punten[index];
      final eind = punten[index + 1];
      final richting = eind - begin;
      final lengte = richting.distance;
      if (lengte <= 0.001) continue;

      final normaal = Offset(-richting.dy / lengte, richting.dx / lengte);
      const maatAfstand = 23.0;
      final maatBegin = begin + normaal * maatAfstand;
      final maatEind = eind + normaal * maatAfstand;

      final paint = Paint()
        ..color = _maatKleur
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(maatBegin, maatEind, paint);
      canvas.drawLine(begin + normaal * 5, maatBegin, paint);
      canvas.drawLine(eind + normaal * 5, maatEind, paint);
      _tekenPijlpunt(canvas, maatBegin, maatEind, paint);
      _tekenPijlpunt(canvas, maatEind, maatBegin, paint);

      final midden = Offset(
        (maatBegin.dx + maatEind.dx) / 2,
        (maatBegin.dy + maatEind.dy) / 2,
      );
      _tekenTekst(
        canvas,
        '${lengtesMm[index]} mm',
        midden,
        kleur: _maatKleur,
        achtergrond: Colors.white,
        fontSize: 11,
      );
    }
  }

  void _tekenHoekWaarden(Canvas canvas, List<Offset> punten) {
    final hoeken = model.actieveHoekenGraden;
    final aantalHoeken = math.min(hoeken.length, punten.length - 2);

    for (var index = 0; index < aantalHoeken; index++) {
      final hoek = hoeken[index];
      if (hoek == null) continue;

      final hoekPunt = punten[index + 1];
      final naarVorige = _eenheidsVector(punten[index] - hoekPunt);
      final naarVolgende = _eenheidsVector(punten[index + 2] - hoekPunt);
      if (naarVorige == null || naarVolgende == null) continue;

      var tekstRichting = naarVorige + naarVolgende;
      final genormaliseerd = _eenheidsVector(tekstRichting);
      if (genormaliseerd == null) {
        tekstRichting = Offset(naarVorige.dy, -naarVorige.dx);
      } else {
        tekstRichting = genormaliseerd;
      }

      final positie = hoekPunt + tekstRichting * 22;
      _tekenTekst(
        canvas,
        '$hoek°',
        positie,
        kleur: _maatKleur,
        achtergrond: Colors.white.withValues(alpha: 0.94),
        fontSize: 11,
        vet: true,
      );
    }
  }

  Offset? _eenheidsVector(Offset vector) {
    final lengte = vector.distance;
    if (lengte <= 0.0001) return null;
    return vector / lengte;
  }

  void _tekenHulpmiddel({
    required Canvas canvas,
    required Size size,
    required _PlooiGeometrie geometrie,
    required List<Offset> canvasPunten,
  }) {
    if (!geometrie.heeftVolgendePlooi || canvasPunten.length < 2) return;

    final draaipunt = canvasPunten.last;
    final vorige = canvasPunten[canvasPunten.length - 2];
    final richting = draaipunt - vorige;
    final lengte = richting.distance;
    if (lengte <= 0.001) return;

    final eenheid = richting / lengte;
    const straal = 31.0;
    final cirkelMidden = draaipunt + eenheid * straal;
    final hulpPaint = Paint()
      ..color = _hulpKleur
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(cirkelMidden, straal, hulpPaint);
    canvas.drawCircle(draaipunt, 2.4, Paint()..color = _hulpKleur);

    final tekstPunt = draaipunt + Offset(eenheid.dy, -eenheid.dx) * 14;
    _tekenTekst(
      canvas,
      '0°',
      tekstPunt,
      kleur: _hulpKleur,
      achtergrond: Colors.white.withValues(alpha: 0.9),
      fontSize: 12,
      vet: true,
    );

    final hulprichting = geometrie.hulprichting;
    if (hulprichting == null) return;

    final canvasRichting = Offset(
      math.cos(hulprichting),
      -math.sin(hulprichting),
    );
    final doelRect = Rect.fromLTWH(
      16,
      16,
      math.max(1.0, size.width - 32),
      math.max(1.0, size.height - 32),
    );
    final afstand = _afstandTotRand(draaipunt, canvasRichting, doelRect);
    if (afstand <= 8) return;

    canvas.drawLine(
      draaipunt,
      draaipunt + canvasRichting * (afstand - 8),
      hulpPaint..strokeWidth = 1.4,
    );
  }

  _PlooiTransformatie _berekenTransformatie({
    required List<Offset> punten,
    required Rect doelRect,
  }) {
    var minX = punten.first.dx;
    var maxX = punten.first.dx;
    var minY = punten.first.dy;
    var maxY = punten.first.dy;

    for (final punt in punten.skip(1)) {
      minX = math.min(minX, punt.dx);
      maxX = math.max(maxX, punt.dx);
      minY = math.min(minY, punt.dy);
      maxY = math.max(maxY, punt.dy);
    }

    final bronBreedte = math.max(1.0, maxX - minX);
    final bronHoogte = math.max(1.0, maxY - minY);
    final schaal = math.min(
      doelRect.width / bronBreedte,
      doelRect.height / bronHoogte,
    );

    final getekendeBreedte = (maxX - minX) * schaal;
    final getekendeHoogte = (maxY - minY) * schaal;
    final links = doelRect.left + (doelRect.width - getekendeBreedte) / 2;
    final boven = doelRect.top + (doelRect.height - getekendeHoogte) / 2;

    return _PlooiTransformatie(
      schaal: schaal,
      minX: minX,
      maxY: maxY,
      links: links,
      boven: boven,
    );
  }

  double _afstandTotRand(Offset start, Offset richting, Rect rect) {
    final kandidaten = <double>[];

    if (richting.dx > 0.0001) {
      kandidaten.add((rect.right - start.dx) / richting.dx);
    } else if (richting.dx < -0.0001) {
      kandidaten.add((rect.left - start.dx) / richting.dx);
    }
    if (richting.dy > 0.0001) {
      kandidaten.add((rect.bottom - start.dy) / richting.dy);
    } else if (richting.dy < -0.0001) {
      kandidaten.add((rect.top - start.dy) / richting.dy);
    }

    return kandidaten
        .where((waarde) => waarde.isFinite && waarde > 0)
        .fold<double>(double.infinity, math.min);
  }

  void _tekenPijlpunt(
    Canvas canvas,
    Offset punt,
    Offset richtingNaar,
    Paint paint,
  ) {
    final richting = richtingNaar - punt;
    final lengte = richting.distance;
    if (lengte <= 0.001) return;

    final eenheid = richting / lengte;
    final normaal = Offset(-eenheid.dy, eenheid.dx);
    const pijlLengte = 7.0;
    const pijlBreedte = 3.2;
    canvas.drawLine(
      punt,
      punt + eenheid * pijlLengte + normaal * pijlBreedte,
      paint,
    );
    canvas.drawLine(
      punt,
      punt + eenheid * pijlLengte - normaal * pijlBreedte,
      paint,
    );
  }

  void _tekenTekst(
    Canvas canvas,
    String tekst,
    Offset midden, {
    required Color kleur,
    required Color achtergrond,
    required double fontSize,
    bool vet = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: TextStyle(
          color: kleur,
          fontSize: fontSize,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final rect = Rect.fromCenter(
      center: midden,
      width: painter.width + 8,
      height: painter.height + 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = achtergrond,
    );
    painter.paint(
      canvas,
      Offset(midden.dx - painter.width / 2, midden.dy - painter.height / 2),
    );
  }

  double _radialen(double graden) => graden * math.pi / 180.0;

  @override
  bool shouldRepaint(covariant OpmetingPlooiwerkenPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}

class _PlooiGeometrie {
  const _PlooiGeometrie({
    required this.punten,
    required this.lengtesMm,
    required this.heeftVolgendePlooi,
    required this.hulprichting,
  });

  final List<Offset> punten;
  final List<int> lengtesMm;
  final bool heeftVolgendePlooi;
  final double? hulprichting;
}

class _PlooiTransformatie {
  const _PlooiTransformatie({
    required this.schaal,
    required this.minX,
    required this.maxY,
    required this.links,
    required this.boven,
  });

  final double schaal;
  final double minX;
  final double maxY;
  final double links;
  final double boven;

  Offset naarCanvas(Offset punt) {
    return Offset(
      links + (punt.dx - minX) * schaal,
      boven + (maxY - punt.dy) * schaal,
    );
  }
}
