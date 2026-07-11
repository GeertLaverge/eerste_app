import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vlak_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';

class OpmetingRaamMaatWijzigingResultaat {
  const OpmetingRaamMaatWijzigingResultaat({
    required this.tStijlen,
    required this.vleugels,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;
}

class OpmetingRaamTekenvlakMaatWijziging {
  const OpmetingRaamTekenvlakMaatWijziging._();

  /// Bestaande functie voor een wijziging van de raamafmetingen
  /// terwijl het tekenvlak dezelfde grootte houdt.
  ///
  /// Deze functie blijft bestaan zodat de huidige aanroep in
  /// opmeting_raam_tekenvlak.dart voorlopig blijft compileren.
  static OpmetingRaamMaatWijzigingResultaat? pasTekeningAanNieuweKaderMaten({
    required Size tekenvlakGrootte,
    required int oudeBreedteMm,
    required int oudeHoogteMm,
    required int nieuweBreedteMm,
    required int nieuweHoogteMm,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
  }) {
    return pasTekeningAanNieuwBlok(
      oudeTekenvlakGrootte: tekenvlakGrootte,
      nieuweTekenvlakGrootte: tekenvlakGrootte,
      oudeBreedteMm: oudeBreedteMm,
      oudeHoogteMm: oudeHoogteMm,
      nieuweBreedteMm: nieuweBreedteMm,
      nieuweHoogteMm: nieuweHoogteMm,
      bestaandeTStijlen: bestaandeTStijlen,
      bestaandeVleugels: bestaandeVleugels,
    );
  }

  /// Algemene schaalfunctie voor het volledige raamblok.
  ///
  /// Deze functie wordt gebruikt wanneer:
  ///
  /// - de raamhoogte verandert;
  /// - de raambreedte verandert;
  /// - het tekenvlak groter of kleiner wordt;
  /// - de iPad van liggend naar staand draait;
  /// - de iPad van staand naar liggend draait.
  ///
  /// Alle bestaande ID's worden behouden.
  static OpmetingRaamMaatWijzigingResultaat? pasTekeningAanNieuwBlok({
    required Size oudeTekenvlakGrootte,
    required Size nieuweTekenvlakGrootte,
    required int oudeBreedteMm,
    required int oudeHoogteMm,
    required int nieuweBreedteMm,
    required int nieuweHoogteMm,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
  }) {
    if (!_isGeldigeTekenvlakGrootte(oudeTekenvlakGrootte) ||
        !_isGeldigeTekenvlakGrootte(nieuweTekenvlakGrootte)) {
      return null;
    }

    if (oudeBreedteMm <= 0 ||
        oudeHoogteMm <= 0 ||
        nieuweBreedteMm <= 0 ||
        nieuweHoogteMm <= 0) {
      return null;
    }

    final oudeBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: oudeTekenvlakGrootte,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
    );

    final oudeBinnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: oudeBuitenKader,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
    );

    final nieuweBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: nieuweTekenvlakGrootte,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
    );

    final nieuweBinnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: nieuweBuitenKader,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
    );

    if (!_isGeldigVlak(oudeBuitenKader) ||
        !_isGeldigVlak(oudeBinnenKader) ||
        !_isGeldigVlak(nieuweBuitenKader) ||
        !_isGeldigVlak(nieuweBinnenKader)) {
      return null;
    }

    if (bestaandeTStijlen.isEmpty && bestaandeVleugels.isEmpty) {
      return const OpmetingRaamMaatWijzigingResultaat(
        tStijlen: <OpmetingRaamTStijl>[],
        vleugels: <OpmetingRaamVleugel>[],
      );
    }

    final oudeKaderTStijlen = bestaandeTStijlen
        .where((stijl) => stijl.werkvlakId == 'kader')
        .toList();

    final oudeHoofdVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: oudeBinnenKader,
      buitenKader: oudeBuitenKader,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
      tStijlen: oudeKaderTStijlen,
    );

    final oudeBronVlakkenPerVleugel = <String, Rect>{};

    for (final vleugel in bestaandeVleugels) {
      final bronVlak = _vindHoofdVlakVoorVleugel(
        vleugelVlak: vleugel.vlak,
        hoofdVlakken: oudeHoofdVlakken,
        binnenKader: oudeBinnenKader,
      );

      if (bronVlak != null) {
        oudeBronVlakkenPerVleugel[vleugel.id] = bronVlak;
      }
    }

    final nieuweKaderTStijlen = _schaalTStijlGroep(
      oudeStijlen: oudeKaderTStijlen,
      oudWerkvlak: oudeBinnenKader,
      nieuwWerkvlak: nieuweBinnenKader,
      oudBuitenKader: oudeBuitenKader,
      nieuwBuitenKader: nieuweBuitenKader,
      oudeBreedteMm: oudeBreedteMm,
      oudeHoogteMm: oudeHoogteMm,
      nieuweBreedteMm: nieuweBreedteMm,
      nieuweHoogteMm: nieuweHoogteMm,
    );

    final aangepasteTStijlenPerId = <String, OpmetingRaamTStijl>{};

    for (final stijl in nieuweKaderTStijlen) {
      aangepasteTStijlenPerId[stijl.id] = stijl;
    }

    final nieuweHoofdVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: nieuweBinnenKader,
      buitenKader: nieuweBuitenKader,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
      tStijlen: nieuweKaderTStijlen,
    );

    final nieuweVleugels = <OpmetingRaamVleugel>[];

    for (final oudeVleugel in bestaandeVleugels) {
      final oudBronVlak = oudeBronVlakkenPerVleugel[oudeVleugel.id];

      Rect nieuwVleugelVlak;

      if (oudBronVlak != null) {
        final nieuwHoofdVlak = _vindOvereenkomstigNieuwHoofdVlak(
          oudHoofdVlak: oudBronVlak,
          oudBinnenKader: oudeBinnenKader,
          nieuwBinnenKader: nieuweBinnenKader,
          nieuweHoofdVlakken: nieuweHoofdVlakken,
        );

        final doelVlak =
            nieuwHoofdVlak ??
            _begrensVlakBinnenKader(
              vlak: _schaalRectTussenVlakken(
                rect: oudBronVlak,
                oudVlak: oudeBinnenKader,
                nieuwVlak: nieuweBinnenKader,
              ),
              binnenKader: nieuweBinnenKader,
            );

        final berekendVleugelVlak = OpmetingRaamVleugelHelper.maakVleugelVlak(
          vlak: doelVlak,
          buitenKader: nieuweBuitenKader,
          breedteMm: nieuweBreedteMm,
          hoogteMm: nieuweHoogteMm,
        );

        if (_isGeldigVlak(berekendVleugelVlak)) {
          nieuwVleugelVlak = berekendVleugelVlak;
        } else {
          nieuwVleugelVlak = _schaalVleugelRechtstreeks(
            oudeVleugelVlak: oudeVleugel.vlak,
            oudeBinnenKader: oudeBinnenKader,
            nieuweBinnenKader: nieuweBinnenKader,
          );
        }
      } else {
        /*
         * Veiligheidsfallback:
         *
         * Wanneer het oorspronkelijke hoofdvlak niet meer
         * gevonden wordt, mag de vleugel niet verdwijnen.
         * Daarom schalen we de bestaande vleugel rechtstreeks
         * mee als onderdeel van het volledige raamblok.
         */
        nieuwVleugelVlak = _schaalVleugelRechtstreeks(
          oudeVleugelVlak: oudeVleugel.vlak,
          oudeBinnenKader: oudeBinnenKader,
          nieuweBinnenKader: nieuweBinnenKader,
        );
      }

      nieuweVleugels.add(
        OpmetingRaamVleugel(
          id: oudeVleugel.id,
          vlak: nieuwVleugelVlak,
          type: oudeVleugel.type,
        ),
      );
    }

    final oudeVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: bestaandeVleugels,
          buitenKader: oudeBuitenKader,
          breedteMm: oudeBreedteMm,
          hoogteMm: oudeHoogteMm,
        );

    final nieuweVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: nieuweVleugels,
          buitenKader: nieuweBuitenKader,
          breedteMm: nieuweBreedteMm,
          hoogteMm: nieuweHoogteMm,
        );

    final interneTStijlGroepen = <String, List<OpmetingRaamTStijl>>{};

    for (final stijl in bestaandeTStijlen) {
      if (stijl.werkvlakId == 'kader') {
        continue;
      }

      interneTStijlGroepen
          .putIfAbsent(stijl.werkvlakId, () => <OpmetingRaamTStijl>[])
          .add(stijl);
    }

    for (final entry in interneTStijlGroepen.entries) {
      final oudWerkvlak = oudeVleugelWerkvlakken[entry.key];

      final nieuwWerkvlak = nieuweVleugelWerkvlakken[entry.key];

      if (oudWerkvlak != null &&
          nieuwWerkvlak != null &&
          _isGeldigVlak(oudWerkvlak) &&
          _isGeldigVlak(nieuwWerkvlak)) {
        final aangepasteGroep = _schaalTStijlGroep(
          oudeStijlen: entry.value,
          oudWerkvlak: oudWerkvlak,
          nieuwWerkvlak: nieuwWerkvlak,
          oudBuitenKader: oudeBuitenKader,
          nieuwBuitenKader: nieuweBuitenKader,
          oudeBreedteMm: oudeBreedteMm,
          oudeHoogteMm: oudeHoogteMm,
          nieuweBreedteMm: nieuweBreedteMm,
          nieuweHoogteMm: nieuweHoogteMm,
        );

        for (final stijl in aangepasteGroep) {
          aangepasteTStijlenPerId[stijl.id] = stijl;
        }

        continue;
      }

      /*
       * Een interne T-stijl mag nooit verdwijnen doordat
       * het bijbehorende vleugelwerkvlak tijdelijk niet
       * gevonden wordt tijdens een schermrotatie.
       *
       * Daarom schalen we hem in dat geval als onderdeel
       * van het volledige buitenkader.
       */
      for (final stijl in entry.value) {
        aangepasteTStijlenPerId[stijl.id] = _schaalLosseTStijl(
          stijl: stijl,
          oudVlak: oudeBuitenKader,
          nieuwVlak: nieuweBuitenKader,
        );
      }
    }

    final nieuweAlleTStijlen = <OpmetingRaamTStijl>[];

    /*
     * De oorspronkelijke volgorde blijft behouden.
     * Dat is belangrijk voor aansluitingen en vlak-ID's.
     */
    for (final oudeStijl in bestaandeTStijlen) {
      final aangepasteStijl = aangepasteTStijlenPerId[oudeStijl.id];

      if (aangepasteStijl != null) {
        nieuweAlleTStijlen.add(aangepasteStijl);
      } else {
        /*
         * Laatste veiligheid:
         * geen enkele T-stijl mag verloren gaan.
         */
        nieuweAlleTStijlen.add(
          _schaalLosseTStijl(
            stijl: oudeStijl,
            oudVlak: oudeBuitenKader,
            nieuwVlak: nieuweBuitenKader,
          ),
        );
      }
    }

    return OpmetingRaamMaatWijzigingResultaat(
      tStijlen: nieuweAlleTStijlen,
      vleugels: nieuweVleugels,
    );
  }

  static Rect _schaalVleugelRechtstreeks({
    required Rect oudeVleugelVlak,
    required Rect oudeBinnenKader,
    required Rect nieuweBinnenKader,
  }) {
    return _begrensVlakBinnenKader(
      vlak: _schaalRectTussenVlakken(
        rect: oudeVleugelVlak,
        oudVlak: oudeBinnenKader,
        nieuwVlak: nieuweBinnenKader,
      ),
      binnenKader: nieuweBinnenKader,
    );
  }

  static OpmetingRaamTStijl _schaalLosseTStijl({
    required OpmetingRaamTStijl stijl,
    required Rect oudVlak,
    required Rect nieuwVlak,
  }) {
    return OpmetingRaamTStijl(
      id: stijl.id,
      richting: stijl.richting,
      start: _schaalPuntTussenVlakken(
        punt: stijl.start,
        oudVlak: oudVlak,
        nieuwVlak: nieuwVlak,
      ),
      einde: _schaalPuntTussenVlakken(
        punt: stijl.einde,
        oudVlak: oudVlak,
        nieuwVlak: nieuwVlak,
      ),
      breedteMm: stijl.breedteMm,
      werkvlakId: stijl.werkvlakId,
    );
  }

  static Rect? _vindHoofdVlakVoorVleugel({
    required Rect vleugelVlak,
    required List<Rect> hoofdVlakken,
    required Rect binnenKader,
  }) {
    if (hoofdVlakken.isEmpty) {
      return null;
    }

    Rect? besteVlak;
    double besteScore = double.infinity;

    for (final kandidaat in hoofdVlakken) {
      final overlap = _overlapOppervlakte(vleugelVlak, kandidaat);

      if (overlap <= 0) {
        continue;
      }

      final vleugelOppervlakte = _oppervlakte(vleugelVlak);

      final kandidaatOppervlakte = _oppervlakte(kandidaat);

      if (vleugelOppervlakte <= 0 || kandidaatOppervlakte <= 0) {
        continue;
      }

      final dekkingVleugel = overlap / vleugelOppervlakte;

      final dekkingKandidaat = overlap / kandidaatOppervlakte;

      final randAfwijking = _genormaliseerdeRandAfwijking(
        eerste: vleugelVlak,
        tweede: kandidaat,
        referentie: binnenKader,
      );

      final middenBoete = kandidaat.inflate(2).contains(vleugelVlak.center)
          ? 0.0
          : 100.0;

      final score =
          (1 - dekkingVleugel) * 1000 +
          (1 - dekkingKandidaat) * 100 +
          randAfwijking * 10 +
          middenBoete;

      if (score < besteScore) {
        besteScore = score;
        besteVlak = kandidaat;
      }
    }

    if (besteVlak != null) {
      return besteVlak;
    }

    final middenVlak = OpmetingRaamVlakHelper.vindVlak(
      punt: vleugelVlak.center,
      vlakken: hoofdVlakken,
    );

    if (middenVlak != null) {
      return middenVlak;
    }

    return _vindDichtstbijzijndeVlak(
      doelVlak: vleugelVlak,
      doelReferentie: binnenKader,
      kandidaatVlakken: hoofdVlakken,
      kandidaatReferentie: binnenKader,
    );
  }

  static Rect? _vindOvereenkomstigNieuwHoofdVlak({
    required Rect oudHoofdVlak,
    required Rect oudBinnenKader,
    required Rect nieuwBinnenKader,
    required List<Rect> nieuweHoofdVlakken,
  }) {
    if (nieuweHoofdVlakken.isEmpty) {
      return null;
    }

    final verwachtMidden = _schaalPuntTussenVlakken(
      punt: oudHoofdVlak.center,
      oudVlak: oudBinnenKader,
      nieuwVlak: nieuwBinnenKader,
    );

    Rect? besteVlak;
    double besteScore = double.infinity;

    for (final kandidaat in nieuweHoofdVlakken) {
      final randAfwijking = _genormaliseerdeRandAfwijkingTussenKaders(
        oudVlak: oudHoofdVlak,
        oudReferentie: oudBinnenKader,
        nieuwVlak: kandidaat,
        nieuwReferentie: nieuwBinnenKader,
      );

      final randHandtekeningBoete = _randHandtekeningBoete(
        oudVlak: oudHoofdVlak,
        oudReferentie: oudBinnenKader,
        nieuwVlak: kandidaat,
        nieuwReferentie: nieuwBinnenKader,
      );

      final middenBoete = kandidaat.inflate(2).contains(verwachtMidden)
          ? 0.0
          : 25.0;

      final langsteZijde = nieuwBinnenKader.size.longestSide > 0
          ? nieuwBinnenKader.size.longestSide
          : 1.0;

      final middenAfstand =
          (kandidaat.center - verwachtMidden).distance / langsteZijde;

      final score =
          randAfwijking * 100 +
          randHandtekeningBoete +
          middenBoete +
          middenAfstand;

      if (score < besteScore) {
        besteScore = score;
        besteVlak = kandidaat;
      }
    }

    return besteVlak;
  }

  static Rect? _vindDichtstbijzijndeVlak({
    required Rect doelVlak,
    required Rect doelReferentie,
    required List<Rect> kandidaatVlakken,
    required Rect kandidaatReferentie,
  }) {
    Rect? besteVlak;
    double besteScore = double.infinity;

    for (final kandidaat in kandidaatVlakken) {
      final score = _genormaliseerdeRandAfwijkingTussenKaders(
        oudVlak: doelVlak,
        oudReferentie: doelReferentie,
        nieuwVlak: kandidaat,
        nieuwReferentie: kandidaatReferentie,
      );

      if (score < besteScore) {
        besteScore = score;
        besteVlak = kandidaat;
      }
    }

    return besteVlak;
  }

  static double _genormaliseerdeRandAfwijking({
    required Rect eerste,
    required Rect tweede,
    required Rect referentie,
  }) {
    return _genormaliseerdeRandAfwijkingTussenKaders(
      oudVlak: eerste,
      oudReferentie: referentie,
      nieuwVlak: tweede,
      nieuwReferentie: referentie,
    );
  }

  static double _genormaliseerdeRandAfwijkingTussenKaders({
    required Rect oudVlak,
    required Rect oudReferentie,
    required Rect nieuwVlak,
    required Rect nieuwReferentie,
  }) {
    final oudLinks = _genormaliseerdeX(oudVlak.left, oudReferentie);

    final oudRechts = _genormaliseerdeX(oudVlak.right, oudReferentie);

    final oudBoven = _genormaliseerdeY(oudVlak.top, oudReferentie);

    final oudOnder = _genormaliseerdeY(oudVlak.bottom, oudReferentie);

    final nieuwLinks = _genormaliseerdeX(nieuwVlak.left, nieuwReferentie);

    final nieuwRechts = _genormaliseerdeX(nieuwVlak.right, nieuwReferentie);

    final nieuwBoven = _genormaliseerdeY(nieuwVlak.top, nieuwReferentie);

    final nieuwOnder = _genormaliseerdeY(nieuwVlak.bottom, nieuwReferentie);

    return (oudLinks - nieuwLinks).abs() +
        (oudRechts - nieuwRechts).abs() +
        (oudBoven - nieuwBoven).abs() +
        (oudOnder - nieuwOnder).abs();
  }

  static double _randHandtekeningBoete({
    required Rect oudVlak,
    required Rect oudReferentie,
    required Rect nieuwVlak,
    required Rect nieuwReferentie,
  }) {
    const tolerantie = 3.0;

    final oudRaaktLinks =
        (oudVlak.left - oudReferentie.left).abs() <= tolerantie;

    final oudRaaktRechts =
        (oudVlak.right - oudReferentie.right).abs() <= tolerantie;

    final oudRaaktBoven = (oudVlak.top - oudReferentie.top).abs() <= tolerantie;

    final oudRaaktOnder =
        (oudVlak.bottom - oudReferentie.bottom).abs() <= tolerantie;

    final nieuwRaaktLinks =
        (nieuwVlak.left - nieuwReferentie.left).abs() <= tolerantie;

    final nieuwRaaktRechts =
        (nieuwVlak.right - nieuwReferentie.right).abs() <= tolerantie;

    final nieuwRaaktBoven =
        (nieuwVlak.top - nieuwReferentie.top).abs() <= tolerantie;

    final nieuwRaaktOnder =
        (nieuwVlak.bottom - nieuwReferentie.bottom).abs() <= tolerantie;

    var boete = 0.0;

    if (oudRaaktLinks != nieuwRaaktLinks) {
      boete += 20;
    }

    if (oudRaaktRechts != nieuwRaaktRechts) {
      boete += 20;
    }

    if (oudRaaktBoven != nieuwRaaktBoven) {
      boete += 20;
    }

    if (oudRaaktOnder != nieuwRaaktOnder) {
      boete += 20;
    }

    return boete;
  }

  static double _genormaliseerdeX(double x, Rect referentie) {
    if (referentie.width <= 0) {
      return 0;
    }

    return ((x - referentie.left) / referentie.width)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _genormaliseerdeY(double y, Rect referentie) {
    if (referentie.height <= 0) {
      return 0;
    }

    return ((y - referentie.top) / referentie.height)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _oppervlakte(Rect vlak) {
    if (!_isGeldigVlak(vlak)) {
      return 0;
    }

    return vlak.width * vlak.height;
  }

  static double _overlapOppervlakte(Rect eerste, Rect tweede) {
    final links = math.max(eerste.left, tweede.left);

    final boven = math.max(eerste.top, tweede.top);

    final rechts = math.min(eerste.right, tweede.right);

    final onder = math.min(eerste.bottom, tweede.bottom);

    if (rechts <= links || onder <= boven) {
      return 0;
    }

    return (rechts - links) * (onder - boven);
  }

  static Rect _begrensVlakBinnenKader({
    required Rect vlak,
    required Rect binnenKader,
  }) {
    final links = vlak.left
        .clamp(binnenKader.left, binnenKader.right)
        .toDouble();

    final boven = vlak.top
        .clamp(binnenKader.top, binnenKader.bottom)
        .toDouble();

    final rechts = vlak.right
        .clamp(binnenKader.left, binnenKader.right)
        .toDouble();

    final onder = vlak.bottom
        .clamp(binnenKader.top, binnenKader.bottom)
        .toDouble();

    if (rechts <= links || onder <= boven) {
      return binnenKader;
    }

    return Rect.fromLTRB(links, boven, rechts, onder);
  }

  static List<OpmetingRaamTStijl> _schaalTStijlGroep({
    required List<OpmetingRaamTStijl> oudeStijlen,
    required Rect oudWerkvlak,
    required Rect nieuwWerkvlak,
    required Rect oudBuitenKader,
    required Rect nieuwBuitenKader,
    required int oudeBreedteMm,
    required int oudeHoogteMm,
    required int nieuweBreedteMm,
    required int nieuweHoogteMm,
  }) {
    if (oudeStijlen.isEmpty) {
      return <OpmetingRaamTStijl>[];
    }

    final voorlopigeStijlen = oudeStijlen.map((stijl) {
      return OpmetingRaamTStijl(
        id: stijl.id,
        richting: stijl.richting,
        start: _schaalPuntTussenVlakken(
          punt: stijl.start,
          oudVlak: oudWerkvlak,
          nieuwVlak: nieuwWerkvlak,
        ),
        einde: _schaalPuntTussenVlakken(
          punt: stijl.einde,
          oudVlak: oudWerkvlak,
          nieuwVlak: nieuwWerkvlak,
        ),
        breedteMm: stijl.breedteMm,
        werkvlakId: stijl.werkvlakId,
      );
    }).toList();

    final definitieveStijlen = <OpmetingRaamTStijl>[];

    for (var index = 0; index < oudeStijlen.length; index++) {
      final oudeStijl = oudeStijlen[index];

      final voorlopigeStijl = voorlopigeStijlen[index];

      final nieuweStart = _pasAansluitingAan(
        oudPunt: oudeStijl.start,
        voorlopigNieuwPunt: voorlopigeStijl.start,
        richting: oudeStijl.richting,
        eigenIndex: index,
        oudeStijlen: oudeStijlen,
        nieuweStijlen: voorlopigeStijlen,
        oudWerkvlak: oudWerkvlak,
        nieuwWerkvlak: nieuwWerkvlak,
        oudBuitenKader: oudBuitenKader,
        nieuwBuitenKader: nieuwBuitenKader,
        oudeBreedteMm: oudeBreedteMm,
        oudeHoogteMm: oudeHoogteMm,
        nieuweBreedteMm: nieuweBreedteMm,
        nieuweHoogteMm: nieuweHoogteMm,
      );

      final nieuweEinde = _pasAansluitingAan(
        oudPunt: oudeStijl.einde,
        voorlopigNieuwPunt: voorlopigeStijl.einde,
        richting: oudeStijl.richting,
        eigenIndex: index,
        oudeStijlen: oudeStijlen,
        nieuweStijlen: voorlopigeStijlen,
        oudWerkvlak: oudWerkvlak,
        nieuwWerkvlak: nieuwWerkvlak,
        oudBuitenKader: oudBuitenKader,
        nieuwBuitenKader: nieuwBuitenKader,
        oudeBreedteMm: oudeBreedteMm,
        oudeHoogteMm: oudeHoogteMm,
        nieuweBreedteMm: nieuweBreedteMm,
        nieuweHoogteMm: nieuweHoogteMm,
      );

      definitieveStijlen.add(
        OpmetingRaamTStijl(
          id: oudeStijl.id,
          richting: oudeStijl.richting,
          start: nieuweStart,
          einde: nieuweEinde,
          breedteMm: oudeStijl.breedteMm,
          werkvlakId: oudeStijl.werkvlakId,
        ),
      );
    }

    return definitieveStijlen;
  }

  static Offset _pasAansluitingAan({
    required Offset oudPunt,
    required Offset voorlopigNieuwPunt,
    required String richting,
    required int eigenIndex,
    required List<OpmetingRaamTStijl> oudeStijlen,
    required List<OpmetingRaamTStijl> nieuweStijlen,
    required Rect oudWerkvlak,
    required Rect nieuwWerkvlak,
    required Rect oudBuitenKader,
    required Rect nieuwBuitenKader,
    required int oudeBreedteMm,
    required int oudeHoogteMm,
    required int nieuweBreedteMm,
    required int nieuweHoogteMm,
  }) {
    final tolerantie = math.max(5.0, oudWerkvlak.size.shortestSide * 0.012);

    double besteAfstand = double.infinity;

    double? nieuweCoordinaat;

    void probeerAansluiting({
      required double oudeCoordinaat,
      required double nieuweWaarde,
    }) {
      final puntCoordinaat = richting == 'verticaal' ? oudPunt.dy : oudPunt.dx;

      final afstand = (puntCoordinaat - oudeCoordinaat).abs();

      if (afstand <= tolerantie && afstand < besteAfstand) {
        besteAfstand = afstand;
        nieuweCoordinaat = nieuweWaarde;
      }
    }

    if (richting == 'verticaal') {
      probeerAansluiting(
        oudeCoordinaat: oudWerkvlak.top,
        nieuweWaarde: nieuwWerkvlak.top,
      );

      probeerAansluiting(
        oudeCoordinaat: oudWerkvlak.bottom,
        nieuweWaarde: nieuwWerkvlak.bottom,
      );

      for (var index = 0; index < oudeStijlen.length; index++) {
        if (index == eigenIndex) {
          continue;
        }

        final andereOudeStijl = oudeStijlen[index];

        if (andereOudeStijl.richting != 'horizontaal') {
          continue;
        }

        final oudProfiel = OpmetingRaamTStijlHelper.profielRect(
          stijl: andereOudeStijl,
          buitenKader: oudBuitenKader,
          breedteMm: oudeBreedteMm,
          hoogteMm: oudeHoogteMm,
        );

        if (oudPunt.dx < oudProfiel.left - tolerantie ||
            oudPunt.dx > oudProfiel.right + tolerantie) {
          continue;
        }

        final nieuwProfiel = OpmetingRaamTStijlHelper.profielRect(
          stijl: nieuweStijlen[index],
          buitenKader: nieuwBuitenKader,
          breedteMm: nieuweBreedteMm,
          hoogteMm: nieuweHoogteMm,
        );

        probeerAansluiting(
          oudeCoordinaat: oudProfiel.top,
          nieuweWaarde: nieuwProfiel.top,
        );

        probeerAansluiting(
          oudeCoordinaat: oudProfiel.bottom,
          nieuweWaarde: nieuwProfiel.bottom,
        );
      }

      if (nieuweCoordinaat == null) {
        return voorlopigNieuwPunt;
      }

      return Offset(voorlopigNieuwPunt.dx, nieuweCoordinaat!);
    }

    probeerAansluiting(
      oudeCoordinaat: oudWerkvlak.left,
      nieuweWaarde: nieuwWerkvlak.left,
    );

    probeerAansluiting(
      oudeCoordinaat: oudWerkvlak.right,
      nieuweWaarde: nieuwWerkvlak.right,
    );

    for (var index = 0; index < oudeStijlen.length; index++) {
      if (index == eigenIndex) {
        continue;
      }

      final andereOudeStijl = oudeStijlen[index];

      if (andereOudeStijl.richting != 'verticaal') {
        continue;
      }

      final oudProfiel = OpmetingRaamTStijlHelper.profielRect(
        stijl: andereOudeStijl,
        buitenKader: oudBuitenKader,
        breedteMm: oudeBreedteMm,
        hoogteMm: oudeHoogteMm,
      );

      if (oudPunt.dy < oudProfiel.top - tolerantie ||
          oudPunt.dy > oudProfiel.bottom + tolerantie) {
        continue;
      }

      final nieuwProfiel = OpmetingRaamTStijlHelper.profielRect(
        stijl: nieuweStijlen[index],
        buitenKader: nieuwBuitenKader,
        breedteMm: nieuweBreedteMm,
        hoogteMm: nieuweHoogteMm,
      );

      probeerAansluiting(
        oudeCoordinaat: oudProfiel.left,
        nieuweWaarde: nieuwProfiel.left,
      );

      probeerAansluiting(
        oudeCoordinaat: oudProfiel.right,
        nieuweWaarde: nieuwProfiel.right,
      );
    }

    if (nieuweCoordinaat == null) {
      return voorlopigNieuwPunt;
    }

    return Offset(nieuweCoordinaat!, voorlopigNieuwPunt.dy);
  }

  static Offset _schaalPuntTussenVlakken({
    required Offset punt,
    required Rect oudVlak,
    required Rect nieuwVlak,
  }) {
    if (!_isGeldigVlak(oudVlak) || !_isGeldigVlak(nieuwVlak)) {
      return punt;
    }

    final fractieX = ((punt.dx - oudVlak.left) / oudVlak.width)
        .clamp(0.0, 1.0)
        .toDouble();

    final fractieY = ((punt.dy - oudVlak.top) / oudVlak.height)
        .clamp(0.0, 1.0)
        .toDouble();

    return Offset(
      nieuwVlak.left + nieuwVlak.width * fractieX,
      nieuwVlak.top + nieuwVlak.height * fractieY,
    );
  }

  static Rect _schaalRectTussenVlakken({
    required Rect rect,
    required Rect oudVlak,
    required Rect nieuwVlak,
  }) {
    final nieuweLinkerBovenhoek = _schaalPuntTussenVlakken(
      punt: rect.topLeft,
      oudVlak: oudVlak,
      nieuwVlak: nieuwVlak,
    );

    final nieuweRechterOnderhoek = _schaalPuntTussenVlakken(
      punt: rect.bottomRight,
      oudVlak: oudVlak,
      nieuwVlak: nieuwVlak,
    );

    return Rect.fromLTRB(
      nieuweLinkerBovenhoek.dx,
      nieuweLinkerBovenhoek.dy,
      nieuweRechterOnderhoek.dx,
      nieuweRechterOnderhoek.dy,
    );
  }

  static bool _isGeldigeTekenvlakGrootte(Size size) {
    return size.width > 0 &&
        size.height > 0 &&
        size.width.isFinite &&
        size.height.isFinite;
  }

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.width > 0 &&
        vlak.height > 0 &&
        vlak.left.isFinite &&
        vlak.top.isFinite &&
        vlak.right.isFinite &&
        vlak.bottom.isFinite;
  }
}
