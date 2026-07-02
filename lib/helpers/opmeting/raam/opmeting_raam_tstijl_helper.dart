import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';

class OpmetingRaamTStijlHelper {
  const OpmetingRaamTStijlHelper._();

  static const double standaardBreedteMm = 90;
  static const double vleugelProfielBreedteMm = 60;
  static const double vleugelKaderOffsetMm = 60;
  static const double makelaarBreedteMm = 50;

  static const String _werkvlakLijnPrefix = 'werkvlak_';

  static Map<String, Rect> bepaalVleugelWerkvlakken({
    required List<OpmetingRaamVleugel> vleugels,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final werkvlakken = <String, Rect>{};

    if (breedteMm <= 0 ||
        hoogteMm <= 0 ||
        buitenKader.width <= 0 ||
        buitenKader.height <= 0) {
      return werkvlakken;
    }

    final profielOffsetX =
        (buitenKader.width / breedteMm) * vleugelProfielBreedteMm;

    final profielOffsetY =
        (buitenKader.height / hoogteMm) * vleugelProfielBreedteMm;

    final makelaarBreedtePx =
        (buitenKader.width / breedteMm) * makelaarBreedteMm;

    for (final vleugel in vleugels) {
      if (vleugel.type == OpmetingRaamVleugelType.geenVleugel) {
        continue;
      }

      final isDubbelWerkvlak =
          vleugel.type.isDubbel ||
          vleugel.type == OpmetingRaamVleugelType.vastDubbeleKader;

      if (isDubbelWerkvlak) {
        final middenX = vleugel.vlak.center.dx;
        final halveMakelaar = makelaarBreedtePx / 2;

        final linkerVleugelVlak = Rect.fromLTRB(
          vleugel.vlak.left,
          vleugel.vlak.top,
          middenX - halveMakelaar,
          vleugel.vlak.bottom,
        );

        final rechterVleugelVlak = Rect.fromLTRB(
          middenX + halveMakelaar,
          vleugel.vlak.top,
          vleugel.vlak.right,
          vleugel.vlak.bottom,
        );

        final linkerGlasopening = _maakGlasopening(
          vleugelVlak: linkerVleugelVlak,
          profielOffsetX: profielOffsetX,
          profielOffsetY: profielOffsetY,
        );

        final rechterGlasopening = _maakGlasopening(
          vleugelVlak: rechterVleugelVlak,
          profielOffsetX: profielOffsetX,
          profielOffsetY: profielOffsetY,
        );

        if (linkerGlasopening != null) {
          werkvlakken['vleugel_${vleugel.id}_links'] = linkerGlasopening;
        }

        if (rechterGlasopening != null) {
          werkvlakken['vleugel_${vleugel.id}_rechts'] = rechterGlasopening;
        }

        continue;
      }

      final glasopening = _maakGlasopening(
        vleugelVlak: vleugel.vlak,
        profielOffsetX: profielOffsetX,
        profielOffsetY: profielOffsetY,
      );

      if (glasopening != null) {
        werkvlakken['vleugel_${vleugel.id}_enkel'] = glasopening;
      }
    }

    return werkvlakken;
  }

  static Rect? _maakGlasopening({
    required Rect vleugelVlak,
    required double profielOffsetX,
    required double profielOffsetY,
  }) {
    final left = vleugelVlak.left + profielOffsetX;
    final top = vleugelVlak.top + profielOffsetY;
    final right = vleugelVlak.right - profielOffsetX;
    final bottom = vleugelVlak.bottom - profielOffsetY;

    if (right <= left || bottom <= top) {
      return null;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  static List<OpmetingRaamLijn> selecteerbareStartLijnen({
    required Rect binnenKader,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    List<OpmetingRaamVleugel> vleugels = const <OpmetingRaamVleugel>[],
  }) {
    final kaderLijnen = <OpmetingRaamLijn>[
      OpmetingRaamLijn(
        id: 'binnen_boven',
        start: binnenKader.topLeft,
        einde: binnenKader.topRight,
      ),
      OpmetingRaamLijn(
        id: 'binnen_rechts',
        start: binnenKader.topRight,
        einde: binnenKader.bottomRight,
      ),
      OpmetingRaamLijn(
        id: 'binnen_onder',
        start: binnenKader.bottomLeft,
        einde: binnenKader.bottomRight,
      ),
      OpmetingRaamLijn(
        id: 'binnen_links',
        start: binnenKader.topLeft,
        einde: binnenKader.bottomLeft,
      ),
    ];

    final vleugelWerkvlakken = bepaalVleugelWerkvlakken(
      vleugels: vleugels,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final vleugelWerkvlakLijnen = <OpmetingRaamLijn>[];

    for (final entry in vleugelWerkvlakken.entries) {
      _voegWerkvlakLijnenToe(
        lijnen: vleugelWerkvlakLijnen,
        werkvlakId: entry.key,
        werkvlak: entry.value,
      );
    }

    final actieveWerkvlakIds = <String>{'kader', ...vleugelWerkvlakken.keys};

    final kaderTStijlLijnen = <OpmetingRaamLijn>[];
    final interneTStijlLijnen = <OpmetingRaamLijn>[];

    for (var index = 0; index < tStijlen.length; index++) {
      final stijl = tStijlen[index];

      if (!actieveWerkvlakIds.contains(stijl.werkvlakId)) {
        continue;
      }

      final profiel = profielRect(
        stijl: stijl,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      final doelLijst = stijl.werkvlakId == 'kader'
          ? kaderTStijlLijnen
          : interneTStijlLijnen;

      if (stijl.richting == 'verticaal') {
        doelLijst.addAll([
          OpmetingRaamLijn(
            id: 'tstijl_${index}_links',
            start: profiel.topLeft,
            einde: profiel.bottomLeft,
          ),
          OpmetingRaamLijn(
            id: 'tstijl_${index}_rechts',
            start: profiel.topRight,
            einde: profiel.bottomRight,
          ),
        ]);
      } else {
        doelLijst.addAll([
          OpmetingRaamLijn(
            id: 'tstijl_${index}_boven',
            start: profiel.topLeft,
            einde: profiel.topRight,
          ),
          OpmetingRaamLijn(
            id: 'tstijl_${index}_onder',
            start: profiel.bottomLeft,
            einde: profiel.bottomRight,
          ),
        ]);
      }
    }

    final afgedekteKaderVlakken = _bepaalAfgedekteKaderVlakken(
      vleugels: vleugels,
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final vrijeKaderLijnen = _verwijderAfgedekteLijndelen(
      lijnen: kaderLijnen,
      afgedekteVlakken: afgedekteKaderVlakken,
    );

    /*
     * Bestaande T-stijlen worden niet weggeknipt door vleugels.
     * Ze staan ook vooraan, zodat ze voorrang krijgen wanneer
     * een vleugellijn bijna op dezelfde plaats ligt.
     */
    return <OpmetingRaamLijn>[
      ...kaderTStijlLijnen,
      ...interneTStijlLijnen,
      ...vleugelWerkvlakLijnen,
      ...vrijeKaderLijnen,
    ];
  }

  static List<Rect> _bepaalAfgedekteKaderVlakken({
    required List<OpmetingRaamVleugel> vleugels,
    required Rect binnenKader,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 ||
        hoogteMm <= 0 ||
        buitenKader.width <= 0 ||
        buitenKader.height <= 0) {
      return <Rect>[];
    }

    final offsetX = (buitenKader.width / breedteMm) * vleugelKaderOffsetMm;

    final offsetY = (buitenKader.height / hoogteMm) * vleugelKaderOffsetMm;

    final afgedekteVlakken = <Rect>[];

    for (final vleugel in vleugels) {
      if (vleugel.type == OpmetingRaamVleugelType.geenVleugel) {
        continue;
      }

      final left = (vleugel.vlak.left - offsetX)
          .clamp(binnenKader.left, binnenKader.right)
          .toDouble();

      final top = (vleugel.vlak.top - offsetY)
          .clamp(binnenKader.top, binnenKader.bottom)
          .toDouble();

      final right = (vleugel.vlak.right + offsetX)
          .clamp(binnenKader.left, binnenKader.right)
          .toDouble();

      final bottom = (vleugel.vlak.bottom + offsetY)
          .clamp(binnenKader.top, binnenKader.bottom)
          .toDouble();

      if (right <= left || bottom <= top) {
        continue;
      }

      afgedekteVlakken.add(Rect.fromLTRB(left, top, right, bottom));
    }

    return afgedekteVlakken;
  }

  static List<OpmetingRaamLijn> _verwijderAfgedekteLijndelen({
    required List<OpmetingRaamLijn> lijnen,
    required List<Rect> afgedekteVlakken,
  }) {
    var resultaat = List<OpmetingRaamLijn>.from(lijnen);

    for (final afgedektVlak in afgedekteVlakken) {
      final volgendeLijnen = <OpmetingRaamLijn>[];

      for (final lijn in resultaat) {
        volgendeLijnen.addAll(
          _knipLijnRondAfgedektVlak(lijn: lijn, afgedektVlak: afgedektVlak),
        );
      }

      resultaat = volgendeLijnen;
    }

    return resultaat;
  }

  static List<OpmetingRaamLijn> _knipLijnRondAfgedektVlak({
    required OpmetingRaamLijn lijn,
    required Rect afgedektVlak,
  }) {
    const tolerantie = 3.0;
    const minimaleLijnLengte = 4.0;

    final blokkade = afgedektVlak.inflate(tolerantie);

    if (lijn.isHorizontaal) {
      final y = lijn.start.dy;

      final lijnLinks = lijn.start.dx < lijn.einde.dx
          ? lijn.start.dx
          : lijn.einde.dx;

      final lijnRechts = lijn.start.dx > lijn.einde.dx
          ? lijn.start.dx
          : lijn.einde.dx;

      final ligtVerticaalBinnenBlokkade =
          y >= blokkade.top && y <= blokkade.bottom;

      final heeftHorizontaleOverlap =
          lijnRechts > blokkade.left && lijnLinks < blokkade.right;

      if (!ligtVerticaalBinnenBlokkade || !heeftHorizontaleOverlap) {
        return <OpmetingRaamLijn>[lijn];
      }

      final blokkadeLinks = blokkade.left
          .clamp(lijnLinks, lijnRechts)
          .toDouble();

      final blokkadeRechts = blokkade.right
          .clamp(lijnLinks, lijnRechts)
          .toDouble();

      if (blokkadeRechts <= blokkadeLinks) {
        return <OpmetingRaamLijn>[lijn];
      }

      final delen = <OpmetingRaamLijn>[];

      if (blokkadeLinks - lijnLinks >= minimaleLijnLengte) {
        delen.add(
          _maakHorizontaalLijnDeel(
            bron: lijn,
            links: lijnLinks,
            rechts: blokkadeLinks,
            y: y,
          ),
        );
      }

      if (lijnRechts - blokkadeRechts >= minimaleLijnLengte) {
        delen.add(
          _maakHorizontaalLijnDeel(
            bron: lijn,
            links: blokkadeRechts,
            rechts: lijnRechts,
            y: y,
          ),
        );
      }

      return delen;
    }

    final x = lijn.start.dx;

    final lijnBoven = lijn.start.dy < lijn.einde.dy
        ? lijn.start.dy
        : lijn.einde.dy;

    final lijnOnder = lijn.start.dy > lijn.einde.dy
        ? lijn.start.dy
        : lijn.einde.dy;

    final ligtHorizontaalBinnenBlokkade =
        x >= blokkade.left && x <= blokkade.right;

    final heeftVerticaleOverlap =
        lijnOnder > blokkade.top && lijnBoven < blokkade.bottom;

    if (!ligtHorizontaalBinnenBlokkade || !heeftVerticaleOverlap) {
      return <OpmetingRaamLijn>[lijn];
    }

    final blokkadeBoven = blokkade.top.clamp(lijnBoven, lijnOnder).toDouble();

    final blokkadeOnder = blokkade.bottom
        .clamp(lijnBoven, lijnOnder)
        .toDouble();

    if (blokkadeOnder <= blokkadeBoven) {
      return <OpmetingRaamLijn>[lijn];
    }

    final delen = <OpmetingRaamLijn>[];

    if (blokkadeBoven - lijnBoven >= minimaleLijnLengte) {
      delen.add(
        _maakVerticaalLijnDeel(
          bron: lijn,
          boven: lijnBoven,
          onder: blokkadeBoven,
          x: x,
        ),
      );
    }

    if (lijnOnder - blokkadeOnder >= minimaleLijnLengte) {
      delen.add(
        _maakVerticaalLijnDeel(
          bron: lijn,
          boven: blokkadeOnder,
          onder: lijnOnder,
          x: x,
        ),
      );
    }

    return delen;
  }

  static OpmetingRaamLijn _maakHorizontaalLijnDeel({
    required OpmetingRaamLijn bron,
    required double links,
    required double rechts,
    required double y,
  }) {
    final looptNaarRechts = bron.start.dx <= bron.einde.dx;

    return OpmetingRaamLijn(
      id: bron.id,
      start: looptNaarRechts ? Offset(links, y) : Offset(rechts, y),
      einde: looptNaarRechts ? Offset(rechts, y) : Offset(links, y),
    );
  }

  static OpmetingRaamLijn _maakVerticaalLijnDeel({
    required OpmetingRaamLijn bron,
    required double boven,
    required double onder,
    required double x,
  }) {
    final looptNaarBeneden = bron.start.dy <= bron.einde.dy;

    return OpmetingRaamLijn(
      id: bron.id,
      start: looptNaarBeneden ? Offset(x, boven) : Offset(x, onder),
      einde: looptNaarBeneden ? Offset(x, onder) : Offset(x, boven),
    );
  }

  static void _voegWerkvlakLijnenToe({
    required List<OpmetingRaamLijn> lijnen,
    required String werkvlakId,
    required Rect werkvlak,
  }) {
    lijnen.addAll([
      OpmetingRaamLijn(
        id: '$_werkvlakLijnPrefix${werkvlakId}_boven',
        start: werkvlak.topLeft,
        einde: werkvlak.topRight,
      ),
      OpmetingRaamLijn(
        id: '$_werkvlakLijnPrefix${werkvlakId}_rechts',
        start: werkvlak.topRight,
        einde: werkvlak.bottomRight,
      ),
      OpmetingRaamLijn(
        id: '$_werkvlakLijnPrefix${werkvlakId}_onder',
        start: werkvlak.bottomLeft,
        einde: werkvlak.bottomRight,
      ),
      OpmetingRaamLijn(
        id: '$_werkvlakLijnPrefix${werkvlakId}_links',
        start: werkvlak.topLeft,
        einde: werkvlak.bottomLeft,
      ),
    ]);
  }

  static OpmetingRaamLijn? vindLijn({
    required Offset punt,
    required List<OpmetingRaamLijn> lijnen,
    double maxAfstand = 20,
  }) {
    OpmetingRaamLijn? besteLijn;
    var besteAfstand = double.infinity;

    for (final lijn in lijnen) {
      final afstand = afstandTotLijnstuk(
        punt: punt,
        start: lijn.start,
        einde: lijn.einde,
      );

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        besteLijn = lijn;
      }
    }

    if (besteLijn != null && besteAfstand <= maxAfstand) {
      return besteLijn;
    }

    return null;
  }

  static Offset positieOpLijn({
    required OpmetingRaamLijn lijn,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required double positieMm,
  }) {
    if (!_isBinnenKaderLijn(lijn.id)) {
      return _positieLokaalOpLijn(
        lijn: lijn,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        positieType: positieType,
        positieMm: positieMm,
      );
    }

    if (lijn.isHorizontaal) {
      final totaalMm = breedteMm.toDouble();

      if (totaalMm <= 0) {
        return lijn.start;
      }

      final mm = _positieMm(
        positieType: positieType,
        positieMm: positieMm,
        totaalMm: totaalMm,
      );

      final x = buitenKader.left + (buitenKader.width * (mm / totaalMm));

      return Offset(
        _begrensWaarde(waarde: x, eerste: lijn.start.dx, tweede: lijn.einde.dx),
        lijn.start.dy,
      );
    }

    final totaalMm = hoogteMm.toDouble();

    if (totaalMm <= 0) {
      return lijn.start;
    }

    final mm = _positieMm(
      positieType: positieType,
      positieMm: positieMm,
      totaalMm: totaalMm,
    );

    final y = buitenKader.top + (buitenKader.height * (mm / totaalMm));

    return Offset(
      lijn.start.dx,
      _begrensWaarde(waarde: y, eerste: lijn.start.dy, tweede: lijn.einde.dy),
    );
  }

  static Offset _positieLokaalOpLijn({
    required OpmetingRaamLijn lijn,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required double positieMm,
  }) {
    final totaalMm = _lengteMmVoorLijn(
      lijn: lijn,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    if (totaalMm <= 0) {
      return lijn.start;
    }

    final berekendeMm = _positieMm(
      positieType: positieType,
      positieMm: positieMm,
      totaalMm: totaalMm,
    );

    final begrensdeMm = berekendeMm.clamp(0.0, totaalMm).toDouble();

    final fractie = begrensdeMm / totaalMm;

    return Offset(
      lijn.start.dx + ((lijn.einde.dx - lijn.start.dx) * fractie),
      lijn.start.dy + ((lijn.einde.dy - lijn.start.dy) * fractie),
    );
  }

  static OpmetingRaamTStijl maakHaakseTStijl({
    required OpmetingRaamLijn startLijn,
    required Offset startPunt,
    required Rect binnenKader,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    List<OpmetingRaamVleugel> vleugels = const <OpmetingRaamVleugel>[],
  }) {
    final vleugelWerkvlakken = bepaalVleugelWerkvlakken(
      vleugels: vleugels,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final werkvlakken = <String, Rect>{
      'kader': binnenKader,
      ...vleugelWerkvlakken,
    };

    final werkvlakId =
        _werkvlakIdVanLijn(lijn: startLijn, tStijlen: bestaandeTStijlen) ??
        'kader';

    final lokaalWerkvlak = werkvlakken[werkvlakId] ?? binnenKader;

    final alleStopLijnen = selecteerbareStartLijnen(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: bestaandeTStijlen,
      vleugels: vleugels,
    );

    final stopLijnen = alleStopLijnen.where((lijn) {
      final lijnWerkvlakId = _werkvlakIdVanLijn(
        lijn: lijn,
        tStijlen: bestaandeTStijlen,
      );

      return lijnWerkvlakId == werkvlakId;
    }).toList();

    if (startLijn.isHorizontaal) {
      final naarBeneden = _moetVerticaalNaarBeneden(startLijn);

      final mogelijkeStops = stopLijnen.where((lijn) {
        if (!lijn.isHorizontaal) {
          return false;
        }

        if ((lijn.start.dy - startLijn.start.dy).abs() < 1) {
          return false;
        }

        final minX = lijn.start.dx < lijn.einde.dx
            ? lijn.start.dx
            : lijn.einde.dx;

        final maxX = lijn.start.dx > lijn.einde.dx
            ? lijn.start.dx
            : lijn.einde.dx;

        if (startPunt.dx < minX || startPunt.dx > maxX) {
          return false;
        }

        return naarBeneden
            ? lijn.start.dy > startPunt.dy
            : lijn.start.dy < startPunt.dy;
      }).toList();

      mogelijkeStops.sort((a, b) {
        final afstandA = (a.start.dy - startPunt.dy).abs();

        final afstandB = (b.start.dy - startPunt.dy).abs();

        return afstandA.compareTo(afstandB);
      });

      final eindY = mogelijkeStops.isEmpty
          ? (naarBeneden ? lokaalWerkvlak.bottom : lokaalWerkvlak.top)
          : mogelijkeStops.first.start.dy;

      return OpmetingRaamTStijl(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        richting: 'verticaal',
        start: startPunt,
        einde: Offset(startPunt.dx, eindY),
        breedteMm: standaardBreedteMm,
        werkvlakId: werkvlakId,
      );
    }

    final naarRechts = _moetHorizontaalNaarRechts(startLijn);

    final mogelijkeStops = stopLijnen.where((lijn) {
      if (!lijn.isVerticaal) {
        return false;
      }

      if ((lijn.start.dx - startLijn.start.dx).abs() < 1) {
        return false;
      }

      final minY = lijn.start.dy < lijn.einde.dy
          ? lijn.start.dy
          : lijn.einde.dy;

      final maxY = lijn.start.dy > lijn.einde.dy
          ? lijn.start.dy
          : lijn.einde.dy;

      if (startPunt.dy < minY || startPunt.dy > maxY) {
        return false;
      }

      return naarRechts
          ? lijn.start.dx > startPunt.dx
          : lijn.start.dx < startPunt.dx;
    }).toList();

    mogelijkeStops.sort((a, b) {
      final afstandA = (a.start.dx - startPunt.dx).abs();

      final afstandB = (b.start.dx - startPunt.dx).abs();

      return afstandA.compareTo(afstandB);
    });

    final eindX = mogelijkeStops.isEmpty
        ? (naarRechts ? lokaalWerkvlak.right : lokaalWerkvlak.left)
        : mogelijkeStops.first.start.dx;

    return OpmetingRaamTStijl(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      richting: 'horizontaal',
      start: startPunt,
      einde: Offset(eindX, startPunt.dy),
      breedteMm: standaardBreedteMm,
      werkvlakId: werkvlakId,
    );
  }

  static bool _moetVerticaalNaarBeneden(OpmetingRaamLijn lijn) {
    if (lijn.id == 'binnen_boven') {
      return true;
    }

    if (lijn.id == 'binnen_onder') {
      return false;
    }

    final werkvlakRand = _werkvlakRandVanLijn(lijn.id);

    if (werkvlakRand == 'boven') {
      return true;
    }

    if (werkvlakRand == 'onder') {
      return false;
    }

    if (lijn.id.endsWith('_onder')) {
      return true;
    }

    if (lijn.id.endsWith('_boven')) {
      return false;
    }

    return true;
  }

  static bool _moetHorizontaalNaarRechts(OpmetingRaamLijn lijn) {
    if (lijn.id == 'binnen_links') {
      return true;
    }

    if (lijn.id == 'binnen_rechts') {
      return false;
    }

    final werkvlakRand = _werkvlakRandVanLijn(lijn.id);

    if (werkvlakRand == 'links') {
      return true;
    }

    if (werkvlakRand == 'rechts') {
      return false;
    }

    if (lijn.id.endsWith('_rechts')) {
      return true;
    }

    if (lijn.id.endsWith('_links')) {
      return false;
    }

    return true;
  }

  static void tekenTStijl({
    required Canvas canvas,
    required OpmetingRaamTStijl stijl,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final profiel = profielRect(
      stijl: stijl,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final vulling = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(profiel, vulling);
    canvas.drawRect(profiel, lijn);
  }

  static Rect profielRect({
    required OpmetingRaamTStijl stijl,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) {
      return Rect.fromPoints(stijl.start, stijl.einde);
    }

    if (stijl.richting == 'horizontaal') {
      final breedtePx = (buitenKader.height / hoogteMm) * stijl.breedteMm;

      final halveBreedte = breedtePx / 2;

      final left = stijl.start.dx < stijl.einde.dx
          ? stijl.start.dx
          : stijl.einde.dx;

      final right = stijl.start.dx > stijl.einde.dx
          ? stijl.start.dx
          : stijl.einde.dx;

      return Rect.fromLTRB(
        left,
        stijl.start.dy - halveBreedte,
        right,
        stijl.start.dy + halveBreedte,
      );
    }

    final breedtePx = (buitenKader.width / breedteMm) * stijl.breedteMm;

    final halveBreedte = breedtePx / 2;

    final top = stijl.start.dy < stijl.einde.dy
        ? stijl.start.dy
        : stijl.einde.dy;

    final bottom = stijl.start.dy > stijl.einde.dy
        ? stijl.start.dy
        : stijl.einde.dy;

    return Rect.fromLTRB(
      stijl.start.dx - halveBreedte,
      top,
      stijl.start.dx + halveBreedte,
      bottom,
    );
  }

  static int? vindTStijlIndex({
    required Offset punt,
    required List<OpmetingRaamTStijl> tStijlen,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    for (var i = tStijlen.length - 1; i >= 0; i--) {
      final profiel = profielRect(
        stijl: tStijlen[i],
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      if (profiel.inflate(8).contains(punt)) {
        return i;
      }
    }

    return null;
  }

  static bool heeftVleugelLangsBeideZijden({
    required int tStijlIndex,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (tStijlIndex < 0 ||
        tStijlIndex >= tStijlen.length ||
        breedteMm <= 0 ||
        hoogteMm <= 0 ||
        buitenKader.width <= 0 ||
        buitenKader.height <= 0) {
      return false;
    }

    final stijl = tStijlen[tStijlIndex];

    /*
     * Alleen T-stijlen in het hoofdkader kunnen een
     * afzonderlijke vleugel langs beide zijden hebben.
     */
    if (stijl.werkvlakId != 'kader') {
      return false;
    }

    final profiel = profielRect(
      stijl: stijl,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final geldigeVleugels = vleugels.where(
      (vleugel) => vleugel.type != OpmetingRaamVleugelType.geenVleugel,
    );

    if (stijl.richting == 'verticaal') {
      final maximaleAfstand =
          (buitenKader.width / breedteMm) * (vleugelKaderOffsetMm + 50);

      var vleugelLinks = false;
      var vleugelRechts = false;

      for (final vleugel in geldigeVleugels) {
        final overlapBoven = profiel.top > vleugel.vlak.top
            ? profiel.top
            : vleugel.vlak.top;

        final overlapOnder = profiel.bottom < vleugel.vlak.bottom
            ? profiel.bottom
            : vleugel.vlak.bottom;

        if (overlapOnder - overlapBoven <= 3) {
          continue;
        }

        if (vleugel.vlak.center.dx < profiel.center.dx) {
          final afstand = profiel.left - vleugel.vlak.right;

          if (afstand >= -3 && afstand <= maximaleAfstand) {
            vleugelLinks = true;
          }
        }

        if (vleugel.vlak.center.dx > profiel.center.dx) {
          final afstand = vleugel.vlak.left - profiel.right;

          if (afstand >= -3 && afstand <= maximaleAfstand) {
            vleugelRechts = true;
          }
        }

        if (vleugelLinks && vleugelRechts) {
          return true;
        }
      }

      return false;
    }

    final maximaleAfstand =
        (buitenKader.height / hoogteMm) * (vleugelKaderOffsetMm + 50);

    var vleugelBoven = false;
    var vleugelOnder = false;

    for (final vleugel in geldigeVleugels) {
      final overlapLinks = profiel.left > vleugel.vlak.left
          ? profiel.left
          : vleugel.vlak.left;

      final overlapRechts = profiel.right < vleugel.vlak.right
          ? profiel.right
          : vleugel.vlak.right;

      if (overlapRechts - overlapLinks <= 3) {
        continue;
      }

      if (vleugel.vlak.center.dy < profiel.center.dy) {
        final afstand = profiel.top - vleugel.vlak.bottom;

        if (afstand >= -3 && afstand <= maximaleAfstand) {
          vleugelBoven = true;
        }
      }

      if (vleugel.vlak.center.dy > profiel.center.dy) {
        final afstand = vleugel.vlak.top - profiel.bottom;

        if (afstand >= -3 && afstand <= maximaleAfstand) {
          vleugelOnder = true;
        }
      }

      if (vleugelBoven && vleugelOnder) {
        return true;
      }
    }

    return false;
  }

  static bool magTStijlWissen({
    required int index,
    required List<OpmetingRaamTStijl> tStijlen,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (index < 0 || index >= tStijlen.length) {
      return false;
    }

    final teWissenStijl = tStijlen[index];

    final profiel = profielRect(
      stijl: teWissenStijl,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    ).inflate(2);

    for (var i = 0; i < tStijlen.length; i++) {
      if (i == index) {
        continue;
      }

      final andereStijl = tStijlen[i];

      if (andereStijl.werkvlakId != teWissenStijl.werkvlakId) {
        continue;
      }

      if (profiel.contains(andereStijl.start) ||
          profiel.contains(andereStijl.einde)) {
        return false;
      }
    }

    return true;
  }

  static String? _werkvlakIdVanLijn({
    required OpmetingRaamLijn lijn,
    required List<OpmetingRaamTStijl> tStijlen,
  }) {
    if (_isBinnenKaderLijn(lijn.id)) {
      return 'kader';
    }

    final werkvlakRand = _werkvlakRandVanLijn(lijn.id);

    if (werkvlakRand != null) {
      final suffix = '_$werkvlakRand';
      final beginIndex = _werkvlakLijnPrefix.length;
      final eindIndex = lijn.id.length - suffix.length;

      if (eindIndex > beginIndex) {
        return lijn.id.substring(beginIndex, eindIndex);
      }
    }

    final tStijlIndex = _tStijlIndexVanLijnId(lijn.id);

    if (tStijlIndex != null &&
        tStijlIndex >= 0 &&
        tStijlIndex < tStijlen.length) {
      return tStijlen[tStijlIndex].werkvlakId;
    }

    return null;
  }

  static int? _tStijlIndexVanLijnId(String lijnId) {
    final match = RegExp(
      r'^tstijl_(\d+)_(links|rechts|boven|onder)$',
    ).firstMatch(lijnId);

    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1) ?? '');
  }

  static bool _isBinnenKaderLijn(String lijnId) {
    switch (lijnId) {
      case 'binnen_boven':
      case 'binnen_rechts':
      case 'binnen_onder':
      case 'binnen_links':
        return true;

      default:
        return false;
    }
  }

  static String? _werkvlakRandVanLijn(String lijnId) {
    if (!lijnId.startsWith(_werkvlakLijnPrefix)) {
      return null;
    }

    const randen = <String>['boven', 'rechts', 'onder', 'links'];

    for (final rand in randen) {
      if (lijnId.endsWith('_$rand')) {
        return rand;
      }
    }

    return null;
  }

  static double _positieMm({
    required String positieType,
    required double positieMm,
    required double totaalMm,
  }) {
    switch (positieType) {
      case '1/2':
      case '2/4':
        return totaalMm / 2;

      case '1/3':
        return totaalMm / 3;

      case '2/3':
        return totaalMm * 2 / 3;

      case '1/4':
        return totaalMm / 4;

      case '3/4':
        return totaalMm * 3 / 4;

      case 'mm':
      default:
        return positieMm;
    }
  }

  static double _lengteMmVoorLijn({
    required OpmetingRaamLijn lijn,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (lijn.isHorizontaal) {
      if (breedteMm <= 0 || buitenKader.width <= 0) {
        return 0;
      }

      final pixelsPerMm = buitenKader.width / breedteMm;

      final lengtePx = (lijn.einde.dx - lijn.start.dx).abs();

      return lengtePx / pixelsPerMm;
    }

    if (hoogteMm <= 0 || buitenKader.height <= 0) {
      return 0;
    }

    final pixelsPerMm = buitenKader.height / hoogteMm;

    final lengtePx = (lijn.einde.dy - lijn.start.dy).abs();

    return lengtePx / pixelsPerMm;
  }

  static double _begrensWaarde({
    required double waarde,
    required double eerste,
    required double tweede,
  }) {
    final minimum = eerste < tweede ? eerste : tweede;

    final maximum = eerste > tweede ? eerste : tweede;

    return waarde.clamp(minimum, maximum).toDouble();
  }

  static double afstandTotLijnstuk({
    required Offset punt,
    required Offset start,
    required Offset einde,
  }) {
    final dx = einde.dx - start.dx;
    final dy = einde.dy - start.dy;

    if (dx == 0 && dy == 0) {
      return (punt - start).distance;
    }

    final t =
        (((punt.dx - start.dx) * dx) + ((punt.dy - start.dy) * dy)) /
        ((dx * dx) + (dy * dy));

    final begrensd = t.clamp(0.0, 1.0).toDouble();

    final projectie = Offset(
      start.dx + (begrensd * dx),
      start.dy + (begrensd * dy),
    );

    return (punt - projectie).distance;
  }
}
