import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../raam/opmeting_raam_kader_helper.dart';
import '../raam/opmeting_raam_model.dart';
import 'opmeting_schuifraam_model.dart';

class OpmetingSchuifraamVakGeometrie {
  const OpmetingSchuifraamVakGeometrie({
    required this.index,
    required this.type,
    required this.segmentVlak,
    required this.vleugelVlak,
    required this.glasVlak,
  });

  final int index;
  final OpmetingSchuifraamVakType type;
  final Rect segmentVlak;
  final Rect? vleugelVlak;
  final Rect glasVlak;
}

class OpmetingSchuifraamGeometrie {
  const OpmetingSchuifraamGeometrie({
    required this.buitenKader,
    required this.binnenKader,
    required this.vakken,
    required this.structuurTStijlen,
    required this.logischeVleugels,
  });

  final Rect buitenKader;
  final Rect binnenKader;
  final List<OpmetingSchuifraamVakGeometrie> vakken;
  final List<OpmetingRaamTStijl> structuurTStijlen;
  final List<OpmetingRaamVleugel> logischeVleugels;
}

class OpmetingSchuifraamTekenHelper {
  const OpmetingSchuifraamTekenHelper._();

  static const String structuurTStijlPrefix = 'schuifraam_structuur_';
  static const String vleugelPrefix = 'schuifraam_vak_';

  static const double kaderProfielMm = 50;
  static const double vleugelProfielMm = 100;
  static const double standaardRaamVleugelProfielMm = 60;
  static const double vleugelKaderOverlapMm = 20;

  static bool isStructuurTStijl(OpmetingRaamTStijl stijl) {
    return stijl.id.startsWith(structuurTStijlPrefix);
  }

  static bool isLogischeVleugel(OpmetingRaamVleugel vleugel) {
    return vleugel.id.startsWith(vleugelPrefix);
  }

  static OpmetingSchuifraamGeometrie berekenGeometrie({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingSchuifraamSamenstelling samenstelling,
  }) {
    final buiten = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    return berekenGeometrieVoorBuitenKader(
      buitenKader: buiten,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      samenstelling: samenstelling,
    );
  }

  static OpmetingSchuifraamGeometrie berekenGeometrieVoorBuitenKader({
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingSchuifraamSamenstelling samenstelling,
  }) {
    final buiten = buitenKader;
    final schaalX = breedteMm <= 0 ? 0.0 : buiten.width / breedteMm;
    final schaalY = hoogteMm <= 0 ? 0.0 : buiten.height / hoogteMm;

    final kaderX = (kaderProfielMm * schaalX)
        .clamp(0.0, buiten.width / 2)
        .toDouble();
    final kaderY = (kaderProfielMm * schaalY)
        .clamp(0.0, buiten.height / 2)
        .toDouble();

    final binnen = Rect.fromLTRB(
      buiten.left + kaderX,
      buiten.top + kaderY,
      buiten.right - kaderX,
      buiten.bottom - kaderY,
    );

    final profielX = (vleugelProfielMm * schaalX)
        .clamp(0.0, binnen.width / 2)
        .toDouble();
    final profielY = (vleugelProfielMm * schaalY)
        .clamp(0.0, binnen.height / 2)
        .toDouble();

    final werkCorrectieX =
        ((vleugelProfielMm - standaardRaamVleugelProfielMm) * schaalX)
            .clamp(0.0, profielX)
            .toDouble();
    final werkCorrectieY =
        ((vleugelProfielMm - standaardRaamVleugelProfielMm) * schaalY)
            .clamp(0.0, profielY)
            .toDouble();

    final fracties = samenstelling.genormaliseerdeBreedtes;
    final verschuivingenMm =
        samenstelling.genormaliseerdeScheidingVerschuivingenMm;
    final binnenBreedteMm = math.max(
      0.0,
      breedteMm.toDouble() - (kaderProfielMm * 2),
    );
    final aantalVakken = samenstelling.vakken.length;
    final minimumVakMm = aantalVakken <= 0
        ? 0.0
        : math.min(120.0, binnenBreedteMm / (aantalVakken * 2));
    final grenzenMm = <double>[0.0];
    var cumulatiefMm = 0.0;

    for (var index = 0; index < aantalVakken - 1; index++) {
      cumulatiefMm += binnenBreedteMm * fracties[index];
      final verschuivingMm = index < verschuivingenMm.length
          ? verschuivingenMm[index]
          : 0.0;
      final minimum = grenzenMm.last + minimumVakMm;
      final resterendeVakken = aantalVakken - index - 1;
      final maximum = binnenBreedteMm - (resterendeVakken * minimumVakMm);
      final gecorrigeerdeGrens = (cumulatiefMm + verschuivingMm)
          .clamp(minimum, math.max(minimum, maximum))
          .toDouble();

      grenzenMm.add(gecorrigeerdeGrens);
    }

    grenzenMm.add(binnenBreedteMm);

    final grenzen = grenzenMm
        .map((waardeMm) {
          return binnen.left + (waardeMm * schaalX);
        })
        .toList(growable: false);

    final structuurTStijlen = <OpmetingRaamTStijl>[];
    for (var index = 1; index < grenzen.length - 1; index++) {
      final grensX = grenzen[index];
      structuurTStijlen.add(
        OpmetingRaamTStijl(
          id: '$structuurTStijlPrefix$index',
          richting: 'verticaal',
          start: Offset(grensX, binnen.top),
          einde: Offset(grensX, binnen.bottom),
          breedteMm: 1,
          werkvlakId: 'kader',
          positieFractie: binnen.width <= 0
              ? null
              : (grensX - binnen.left) / binnen.width,
        ),
      );
    }

    final vakken = <OpmetingSchuifraamVakGeometrie>[];
    final vleugels = <OpmetingRaamVleugel>[];

    for (var index = 0; index < samenstelling.vakken.length; index++) {
      final vakType = samenstelling.vakken[index];
      final segment = Rect.fromLTRB(
        grenzen[index],
        binnen.top,
        grenzen[index + 1],
        binnen.bottom,
      );

      final heeftVleugel =
          samenstelling.type == OpmetingSchuifraamType.duo ||
          vakType == OpmetingSchuifraamVakType.schuif;

      Rect? zichtbaarVleugelVlak;
      Rect glasVlak;

      if (heeftVleugel) {
        final kaderOverlapX = (vleugelKaderOverlapMm * schaalX)
            .clamp(0.0, kaderX)
            .toDouble();
        final kaderOverlapY = (vleugelKaderOverlapMm * schaalY)
            .clamp(0.0, kaderY)
            .toDouble();
        var links = segment.left;
        var rechts = segment.right;
        var boven = binnen.top - kaderOverlapY;
        var onder = binnen.bottom + kaderOverlapY;

        // Aan de buitenzijden valt de vleugel 20 mm over het kader. Omdat de
        // vleugels na het kader worden getekend, is die overlap ook zichtbaar.
        if (index == 0) {
          links -= kaderOverlapX;
        }
        if (index == samenstelling.vakken.length - 1) {
          rechts += kaderOverlapX;
        }

        // Bij vast-schuif ligt het schuivende profiel boven het vaste profiel.
        // Daardoor blijft op de raaklijn slechts één vleugelprofiel zichtbaar.
        if (vakType == OpmetingSchuifraamVakType.schuif && index > 0) {
          final vorig = samenstelling.vakken[index - 1];
          if (vorig == OpmetingSchuifraamVakType.vast) {
            links -= profielX;
          }
        }

        if (vakType == OpmetingSchuifraamVakType.schuif &&
            index < samenstelling.vakken.length - 1) {
          final volgend = samenstelling.vakken[index + 1];
          if (volgend == OpmetingSchuifraamVakType.vast) {
            rechts += profielX;
          }
        }

        zichtbaarVleugelVlak = Rect.fromLTRB(
          math.max(buiten.left, links),
          math.max(buiten.top, boven),
          math.min(buiten.right, rechts),
          math.min(buiten.bottom, onder),
        );

        glasVlak = _deflateXY(zichtbaarVleugelVlak, profielX, profielY);

        final logischVleugelVlak = Rect.fromLTRB(
          zichtbaarVleugelVlak.left + werkCorrectieX,
          zichtbaarVleugelVlak.top + werkCorrectieY,
          zichtbaarVleugelVlak.right - werkCorrectieX,
          zichtbaarVleugelVlak.bottom - werkCorrectieY,
        );

        if (logischVleugelVlak.width > 4 && logischVleugelVlak.height > 4) {
          vleugels.add(
            OpmetingRaamVleugel(
              id: '$vleugelPrefix$index',
              vlak: logischVleugelVlak,
              type: OpmetingRaamVleugelType.enkelOpenRechts,
            ),
          );
        }
      } else {
        glasVlak = segment;
      }

      vakken.add(
        OpmetingSchuifraamVakGeometrie(
          index: index,
          type: vakType,
          segmentVlak: segment,
          vleugelVlak: zichtbaarVleugelVlak,
          glasVlak: glasVlak,
        ),
      );
    }

    return OpmetingSchuifraamGeometrie(
      buitenKader: buiten,
      binnenKader: binnen,
      vakken: List<OpmetingSchuifraamVakGeometrie>.unmodifiable(vakken),
      structuurTStijlen: List<OpmetingRaamTStijl>.unmodifiable(
        structuurTStijlen,
      ),
      logischeVleugels: List<OpmetingRaamVleugel>.unmodifiable(vleugels),
    );
  }

  static Rect _deflateXY(Rect rect, double x, double y) {
    final begrensdeX = x.clamp(0.0, rect.width / 2).toDouble();
    final begrensdeY = y.clamp(0.0, rect.height / 2).toDouble();

    return Rect.fromLTRB(
      rect.left + begrensdeX,
      rect.top + begrensdeY,
      rect.right - begrensdeX,
      rect.bottom - begrensdeY,
    );
  }

  static void tekenProfielen({
    required Canvas canvas,
    required OpmetingSchuifraamGeometrie geometrie,
  }) {
    tekenKaderProfiel(canvas: canvas, geometrie: geometrie);
    tekenVleugelProfielen(canvas: canvas, geometrie: geometrie);
  }

  static void tekenKaderProfiel({
    required Canvas canvas,
    required OpmetingSchuifraamGeometrie geometrie,
  }) {
    _tekenProfiel(
      canvas: canvas,
      buiten: geometrie.buitenKader,
      binnen: geometrie.binnenKader,
      lijnBreedte: 1.45,
    );
  }

  static void tekenVleugelProfielen({
    required Canvas canvas,
    required OpmetingSchuifraamGeometrie geometrie,
  }) {
    final vasteVakken = geometrie.vakken.where((vak) {
      return vak.type == OpmetingSchuifraamVakType.vast &&
          vak.vleugelVlak != null;
    });

    final schuifVakken = geometrie.vakken.where((vak) {
      return vak.type == OpmetingSchuifraamVakType.schuif &&
          vak.vleugelVlak != null;
    });

    // Eerst vaste vleugels, daarna schuivende vleugels. Daardoor ligt het
    // schuivende profiel zichtbaar bovenop het vaste profiel bij overlap.
    for (final vak in vasteVakken) {
      _tekenProfiel(
        canvas: canvas,
        buiten: vak.vleugelVlak!,
        binnen: vak.glasVlak,
        lijnBreedte: 1.35,
      );
    }

    for (final vak in schuifVakken) {
      _tekenProfiel(
        canvas: canvas,
        buiten: vak.vleugelVlak!,
        binnen: vak.glasVlak,
        lijnBreedte: 1.55,
      );
    }
  }

  static void tekenSymbolen({
    required Canvas canvas,
    required OpmetingSchuifraamSamenstelling samenstelling,
    required OpmetingSchuifraamGeometrie geometrie,
  }) {
    for (final vak in geometrie.vakken) {
      if (vak.glasVlak.width < 20 || vak.glasVlak.height < 20) {
        continue;
      }

      if (vak.type == OpmetingSchuifraamVakType.vast) {
        _tekenVastTekst(canvas: canvas, vlak: vak.glasVlak);
      } else {
        _tekenSchuifPijl(
          canvas: canvas,
          vlak: vak.glasVlak,
          richting: _pijlRichtingVoorVak(
            index: vak.index,
            vakken: samenstelling.vakken,
          ),
        );
      }
    }
  }

  static double? schuifMaatReferentieX(OpmetingSchuifraamGeometrie geometrie) {
    final schuifVakken = geometrie.vakken
        .where((vak) => vak.type == OpmetingSchuifraamVakType.schuif)
        .toList(growable: false);

    if (schuifVakken.isEmpty) {
      return null;
    }

    // Bij de gebruikelijke opbouw V-S of S-V moet de kettingmaat tot aan
    // de echte scheidings-/middenstijl lopen. We gebruiken daarom de grens
    // van de segmenten en niet het midden van het zichtbare vleugelvlak.
    // Het vleugelvlak bevat immers de profieloverlap en zou de maatlijn
    // verkeerd verschuiven. Bij 1/2 geeft dit exact twee gelijke maten.
    if (geometrie.vakken.length == 2 && schuifVakken.length == 1) {
      final schuifVak = schuifVakken.first;

      return schuifVak.index == 0
          ? schuifVak.segmentVlak.right
          : schuifVak.segmentVlak.left;
    }

    // Bij meerdere schuifdelen gebruiken we het midden van de volledige
    // logische schuifzone. Ook hier worden de segmentvlakken gebruikt, zodat
    // de zichtbare profieloverlap geen invloed heeft op de maatvoering.
    final links = schuifVakken
        .map((vak) => vak.segmentVlak.left)
        .reduce(math.min);
    final rechts = schuifVakken
        .map((vak) => vak.segmentVlak.right)
        .reduce(math.max);

    return (links + rechts) / 2;
  }

  static void tekenBreedteMaatvoering({
    required Canvas canvas,
    required OpmetingSchuifraamGeometrie geometrie,
    required int breedteMm,
    required double maatLijnY,
    required double totaleMaatLijnY,
  }) {
    final buiten = geometrie.buitenKader;
    final middenX = schuifMaatReferentieX(geometrie);

    if (buiten.width <= 0 || breedteMm <= 0 || middenX == null) {
      return;
    }

    final begrensdMiddenX = middenX
        .clamp(buiten.left + 1, buiten.right - 1)
        .toDouble();
    final linksMm = ((begrensdMiddenX - buiten.left) / buiten.width * breedteMm)
        .round();
    final rechtsMm = math.max(0, breedteMm - linksMm);
    final hulplijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (final x in <double>[buiten.left, begrensdMiddenX, buiten.right]) {
      canvas.drawLine(
        Offset(x, buiten.bottom + 2),
        Offset(x, maatLijnY + 5),
        hulplijn,
      );
    }

    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: buiten.left,
      eindeX: begrensdMiddenX,
      y: maatLijnY,
      tekst: '$linksMm',
      buitenmaat: false,
    );
    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: begrensdMiddenX,
      eindeX: buiten.right,
      y: maatLijnY,
      tekst: '$rechtsMm',
      buitenmaat: false,
    );

    canvas.drawLine(
      Offset(buiten.left, buiten.bottom + 2),
      Offset(buiten.left, totaleMaatLijnY + 6),
      hulplijn,
    );
    canvas.drawLine(
      Offset(buiten.right, buiten.bottom + 2),
      Offset(buiten.right, totaleMaatLijnY + 6),
      hulplijn,
    );

    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: buiten.left,
      eindeX: buiten.right,
      y: totaleMaatLijnY,
      tekst: '$breedteMm mm',
      buitenmaat: true,
    );
  }

  static int _pijlRichtingVoorVak({
    required int index,
    required List<OpmetingSchuifraamVakType> vakken,
  }) {
    var afstandLinks = 999;
    var afstandRechts = 999;

    for (var i = index - 1; i >= 0; i--) {
      if (vakken[i] == OpmetingSchuifraamVakType.vast) {
        afstandLinks = index - i;
        break;
      }
    }

    for (var i = index + 1; i < vakken.length; i++) {
      if (vakken[i] == OpmetingSchuifraamVakType.vast) {
        afstandRechts = i - index;
        break;
      }
    }

    if (afstandLinks < afstandRechts) {
      return -1;
    }

    if (afstandRechts < afstandLinks) {
      return 1;
    }

    return index < vakken.length / 2 ? -1 : 1;
  }

  static void _tekenVastTekst({required Canvas canvas, required Rect vlak}) {
    final painter = TextPainter(
      text: const TextSpan(
        text: 'VAST',
        style: TextStyle(
          color: Color(0xFF111827),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(1, vlak.width));

    painter.paint(
      canvas,
      Offset(vlak.left + 8, vlak.bottom - painter.height - 8),
    );
  }

  static void _tekenSchuifPijl({
    required Canvas canvas,
    required Rect vlak,
    required int richting,
  }) {
    final beschikbareLengte = math.max(24.0, vlak.width - 28.0);
    final lengte = math.min(
      beschikbareLengte,
      math.min(vlak.width * 0.54, 96.0),
    );
    final verticaleMarge = math.min(18.0, vlak.height * 0.12);
    final y = (vlak.center.dy + verticaleMarge)
        .clamp(vlak.top + 14.0, vlak.bottom - 14.0)
        .toDouble();
    final zijMarge = math.min(14.0, math.max(8.0, vlak.width * 0.08));
    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Het hef-symbool staat dicht tegen de binnenkant van het kader. De
    // verticale lijn eindigt exact op de horizontale pijllijn, zodat er een
    // duidelijke L-vorm ontstaat zonder dat het nummer van de opvulling wordt
    // geraakt.
    final staartX = richting < 0 ? vlak.right - zijMarge : vlak.left + zijMarge;
    final puntX = richting < 0
        ? math.max(vlak.left + 8.0, staartX - lengte)
        : math.min(vlak.right - 8.0, staartX + lengte);

    canvas.drawLine(Offset(staartX, y), Offset(puntX, y), lijn);
    canvas.drawLine(Offset(staartX, y), Offset(staartX, y + 12), lijn);

    final basisX = richting < 0 ? puntX + 10 : puntX - 10;
    final pad = Path()
      ..moveTo(puntX, y)
      ..lineTo(basisX, y - 6)
      ..lineTo(basisX, y + 6)
      ..close();

    canvas.drawPath(
      pad,
      Paint()
        ..color = const Color(0xFF111827)
        ..style = PaintingStyle.fill,
    );
  }

  static void _tekenHorizontaleMaat({
    required Canvas canvas,
    required double startX,
    required double eindeX,
    required double y,
    required String tekst,
    required bool buitenmaat,
  }) {
    if (eindeX - startX <= 0) {
      return;
    }

    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = buitenmaat ? 1 : 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(startX, y), Offset(eindeX, y), lijn);

    final lengte = eindeX - startX;
    final pijlBinnen = lengte >= 18;
    final pijlGrootte = buitenmaat ? 5.2 : 4.2;

    _tekenHorizontalePijlPunt(
      canvas: canvas,
      punt: Offset(startX, y),
      wijstNaarRechts: true,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );
    _tekenHorizontalePijlPunt(
      canvas: canvas,
      punt: Offset(eindeX, y),
      wijstNaarRechts: false,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontSize: buitenmaat ? 10 : 9,
          fontWeight: buitenmaat ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final midden = Offset((startX + eindeX) / 2, y);
    final tekstRect = Rect.fromCenter(
      center: midden,
      width: painter.width + 6,
      height: painter.height + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(tekstRect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.96)
        ..style = PaintingStyle.fill,
    );
    painter.paint(
      canvas,
      Offset(midden.dx - painter.width / 2, midden.dy - painter.height / 2),
    );
  }

  static void _tekenHorizontalePijlPunt({
    required Canvas canvas,
    required Offset punt,
    required bool wijstNaarRechts,
    required bool pijlBinnen,
    required double grootte,
  }) {
    final richting = wijstNaarRechts
        ? (pijlBinnen ? 1.0 : -1.0)
        : (pijlBinnen ? -1.0 : 1.0);
    final pad = Path()
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(punt.dx + richting * grootte, punt.dy - grootte * 0.55)
      ..lineTo(punt.dx + richting * grootte, punt.dy + grootte * 0.55)
      ..close();

    canvas.drawPath(
      pad,
      Paint()
        ..color = const Color(0xFF111827)
        ..style = PaintingStyle.fill,
    );
  }

  static void _tekenProfiel({
    required Canvas canvas,
    required Rect buiten,
    required Rect binnen,
    required double lijnBreedte,
  }) {
    if (buiten.width <= 0 || buiten.height <= 0) {
      return;
    }

    final vulling = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = lijnBreedte
      ..style = PaintingStyle.stroke;
    final verstek = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final profielPad = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(buiten);

    if (binnen.width > 0 && binnen.height > 0) {
      profielPad.addRect(binnen);
    }

    canvas.drawPath(profielPad, vulling);
    canvas.drawRect(buiten, lijn);

    if (binnen.width > 0 && binnen.height > 0) {
      canvas.drawRect(binnen, lijn);
      canvas.drawLine(buiten.topLeft, binnen.topLeft, verstek);
      canvas.drawLine(buiten.topRight, binnen.topRight, verstek);
      canvas.drawLine(buiten.bottomLeft, binnen.bottomLeft, verstek);
      canvas.drawLine(buiten.bottomRight, binnen.bottomRight, verstek);
    }
  }
}
