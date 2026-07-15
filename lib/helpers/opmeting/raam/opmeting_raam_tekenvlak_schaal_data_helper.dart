import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';
import 'opmeting_raam_vlak_helper.dart';

class OpmetingRaamTekenvlakSchaalDataHelper {
  const OpmetingRaamTekenvlakSchaalDataHelper._();

  static void schaalKaderDataBijMaatwijzigingen({
    required OpmetingKaderSamenstelling? oudeSamenstelling,
    required OpmetingKaderSamenstelling nieuweSamenstelling,
    required Size? size,
    required Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader,
    required Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader,
  }) {
    if (oudeSamenstelling == null) {
      return;
    }

    if (size == null) {
      return;
    }

    for (final nieuwKader in nieuweSamenstelling.kaders) {
      final oudKader = _zoekKaderInSamenstelling(
        samenstelling: oudeSamenstelling,
        kaderId: nieuwKader.id,
      );

      if (oudKader == null) {
        continue;
      }

      if (oudKader.breedteMm == nieuwKader.breedteMm &&
          oudKader.hoogteMm == nieuwKader.hoogteMm) {
        continue;
      }

      _schaalDataVoorKader(
        kaderId: nieuwKader.id,
        oudeBreedteMm: oudKader.breedteMm,
        oudeHoogteMm: oudKader.hoogteMm,
        nieuweBreedteMm: nieuwKader.breedteMm,
        nieuweHoogteMm: nieuwKader.hoogteMm,
        size: size,
        tStijlenPerKader: tStijlenPerKader,
        vleugelsPerKader: vleugelsPerKader,
      );
    }
  }

  static OpmetingKaderDeel? _zoekKaderInSamenstelling({
    required OpmetingKaderSamenstelling samenstelling,
    required String kaderId,
  }) {
    for (final kader in samenstelling.kaders) {
      if (kader.id == kaderId) {
        return kader;
      }
    }

    return null;
  }

  static void _schaalDataVoorKader({
    required String kaderId,
    required int oudeBreedteMm,
    required int oudeHoogteMm,
    required int nieuweBreedteMm,
    required int nieuweHoogteMm,
    required Size size,
    required Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader,
    required Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader,
  }) {
    if (oudeBreedteMm <= 0 ||
        oudeHoogteMm <= 0 ||
        nieuweBreedteMm <= 0 ||
        nieuweHoogteMm <= 0) {
      return;
    }

    final oudBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
    );

    final oudBinnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: oudBuitenKader,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
    );

    final nieuwBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
    );

    final nieuwBinnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: nieuwBuitenKader,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
    );

    if (!_isGeldigVlak(oudBinnenKader) || !_isGeldigVlak(nieuwBinnenKader)) {
      return;
    }

    final oudeTStijlen = List<OpmetingRaamTStijl>.from(
      tStijlenPerKader[kaderId] ?? const <OpmetingRaamTStijl>[],
    );

    final oudeVleugels = List<OpmetingRaamVleugel>.from(
      vleugelsPerKader[kaderId] ?? const <OpmetingRaamVleugel>[],
    );

    if (oudeTStijlen.isEmpty && oudeVleugels.isEmpty) {
      return;
    }

    final oudeDeurWerkvlakkenVoorClassificatie = _bepaalDeurVleugelWerkvlakken(
      vleugels: oudeVleugels,
      buitenKader: oudBuitenKader,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
    );

    final genormaliseerdeOudeTStijlen = oudeTStijlen.map((stijl) {
      final deurWerkvlakId = _vindDeurWerkvlakIdVoorTStijl(
        stijl: stijl,
        deurWerkvlakken: oudeDeurWerkvlakkenVoorClassificatie,
      );

      if (deurWerkvlakId == null || deurWerkvlakId == stijl.werkvlakId) {
        return stijl;
      }

      final deurWerkvlak = oudeDeurWerkvlakkenVoorClassificatie[deurWerkvlakId];
      final positieFractie = deurWerkvlak == null
          ? stijl.positieFractie
          : _positieFractieVoorTStijlInWerkvlak(
              stijl: stijl,
              werkvlak: deurWerkvlak,
            );

      return stijl.copyWith(
        werkvlakId: deurWerkvlakId,
        positieFractie: positieFractie,
      );
    }).toList();

    final oudeKaderTStijlen = genormaliseerdeOudeTStijlen.where((stijl) {
      return stijl.werkvlakId == 'kader';
    }).toList();

    final oudeHoofdVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: oudBinnenKader,
      buitenKader: oudBuitenKader,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
      tStijlen: oudeKaderTStijlen,
    );

    final oudeBronVlakkenPerVleugel = <String, Rect>{};

    for (final vleugel in oudeVleugels) {
      final bronVlak = _vindHoofdVlakVoorVleugel(
        vleugelVlak: vleugel.vlak,
        hoofdVlakken: oudeHoofdVlakken,
        binnenKader: oudBinnenKader,
      );

      if (bronVlak != null) {
        oudeBronVlakkenPerVleugel[vleugel.id] = bronVlak;
      }
    }

    final nieuweKaderTStijlen = _schaalTStijlGroep(
      oudeStijlen: oudeKaderTStijlen,
      oudWerkvlak: oudBinnenKader,
      nieuwWerkvlak: nieuwBinnenKader,
      oudBuitenKader: oudBuitenKader,
      nieuwBuitenKader: nieuwBuitenKader,
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
      binnenKader: nieuwBinnenKader,
      buitenKader: nieuwBuitenKader,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
      tStijlen: nieuweKaderTStijlen,
    );

    final nieuweVleugels = <OpmetingRaamVleugel>[];
    final verwerkteDubbeleDeurGroepen = <String>{};

    bool zelfdeDeurGroep(
      OpmetingRaamVleugel eerste,
      OpmetingRaamVleugel tweede,
    ) {
      final eersteGroep = eerste.deurVleugelGroepId.trim();
      final tweedeGroep = tweede.deurVleugelGroepId.trim();

      if (eersteGroep.isNotEmpty || tweedeGroep.isNotEmpty) {
        return eersteGroep.isNotEmpty && eersteGroep == tweedeGroep;
      }

      return eerste.id == tweede.id;
    }

    Rect doelVlakVoorOudeVleugel(OpmetingRaamVleugel oudeVleugel) {
      final oudBronVlak =
          oudeBronVlakkenPerVleugel[oudeVleugel.id] ??
          _vindHoofdVlakVoorVleugel(
            vleugelVlak: oudeVleugel.vlak,
            hoofdVlakken: oudeHoofdVlakken,
            binnenKader: oudBinnenKader,
          ) ??
          oudeVleugel.vlak;

      final nieuwHoofdVlak = _vindOvereenkomstigNieuwHoofdVlak(
        oudHoofdVlak: oudBronVlak,
        oudBinnenKader: oudBinnenKader,
        nieuwBinnenKader: nieuwBinnenKader,
        nieuweHoofdVlakken: nieuweHoofdVlakken,
      );

      return nieuwHoofdVlak ??
          _begrensVlakBinnenKader(
            vlak: _schaalRectTussenVlakken(
              rect: oudBronVlak,
              oudVlak: oudBinnenKader,
              nieuwVlak: nieuwBinnenKader,
            ),
            binnenKader: nieuwBinnenKader,
          );
    }

    Rect unionRect(Iterable<Rect> rects) {
      Rect? resultaat;

      for (final rect in rects) {
        resultaat = resultaat == null ? rect : resultaat!.expandToInclude(rect);
      }

      return resultaat ?? Rect.zero;
    }

    double splitXVoorDubbeleDeur({
      required Rect groepVlak,
      required OpmetingRaamVleugel basisVleugel,
    }) {
      if (groepVlak.width <= 0) {
        return groepVlak.center.dx;
      }

      double schaalX = 0;

      if (nieuweBreedteMm > 0 && nieuwBuitenKader.width > 0) {
        schaalX = nieuwBuitenKader.width / nieuweBreedteMm;
      }

      if (schaalX <= 0 || !schaalX.isFinite) {
        schaalX = groepVlak.width / 1000;
      }

      final verschuivingPx =
          basisVleugel.deurVleugelMiddenVerschuivingMm * schaalX;

      final minimaleVleugelBreedte = groepVlak.width * 0.22;

      return (groepVlak.center.dx + verschuivingPx)
          .clamp(
            groepVlak.left + minimaleVleugelBreedte,
            groepVlak.right - minimaleVleugelBreedte,
          )
          .toDouble();
    }

    for (final oudeVleugel in oudeVleugels) {
      if (oudeVleugel.isDeurVleugel && oudeVleugel.isDubbeleDeurVleugel) {
        final groepSleutel = oudeVleugel.deurVleugelGroepId.trim().isEmpty
            ? oudeVleugel.id
            : oudeVleugel.deurVleugelGroepId.trim();

        if (!verwerkteDubbeleDeurGroepen.add(groepSleutel)) {
          continue;
        }

        final oudeGroep = oudeVleugels.where((vleugel) {
          return vleugel.isDeurVleugel &&
              vleugel.isDubbeleDeurVleugel &&
              zelfdeDeurGroep(vleugel, oudeVleugel);
        }).toList();

        if (oudeGroep.length < 2) {
          nieuweVleugels.add(
            oudeVleugel.copyWith(vlak: doelVlakVoorOudeVleugel(oudeVleugel)),
          );
          continue;
        }

        final groepVlak = unionRect(
          oudeGroep.map((vleugel) => doelVlakVoorOudeVleugel(vleugel)),
        );

        if (groepVlak.width <= 24 || groepVlak.height <= 24) {
          for (final deel in oudeGroep) {
            nieuweVleugels.add(
              deel.copyWith(vlak: doelVlakVoorOudeVleugel(deel)),
            );
          }
          continue;
        }

        final splitX = splitXVoorDubbeleDeur(
          groepVlak: groepVlak,
          basisVleugel: oudeVleugel,
        );

        final linksVlak = Rect.fromLTRB(
          groepVlak.left,
          groepVlak.top,
          splitX,
          groepVlak.bottom,
        );

        final rechtsVlak = Rect.fromLTRB(
          splitX,
          groepVlak.top,
          groepVlak.right,
          groepVlak.bottom,
        );

        for (final deel in oudeGroep) {
          final nieuwVlak =
              deel.deurVleugelDeel == OpmetingRaamDeurVleugelDeel.links
              ? linksVlak
              : rechtsVlak;

          nieuweVleugels.add(deel.copyWith(vlak: nieuwVlak));
        }

        continue;
      }

      final doelVlak = doelVlakVoorOudeVleugel(oudeVleugel);

      final nieuwVleugelVlak = oudeVleugel.isDeurVleugel
          ? doelVlak
          : OpmetingRaamVleugelHelper.maakVleugelVlak(
              vlak: doelVlak,
              buitenKader: nieuwBuitenKader,
              breedteMm: nieuweBreedteMm,
              hoogteMm: nieuweHoogteMm,
            );

      nieuweVleugels.add(oudeVleugel.copyWith(vlak: nieuwVleugelVlak));
    }

    final oudeVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: oudeVleugels,
          buitenKader: oudBuitenKader,
          breedteMm: oudeBreedteMm,
          hoogteMm: oudeHoogteMm,
        );

    final nieuweVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: nieuweVleugels,
          buitenKader: nieuwBuitenKader,
          breedteMm: nieuweBreedteMm,
          hoogteMm: nieuweHoogteMm,
        );

    final oudeWerkvlakkenPerId = <String, Rect>{
      ...oudeVleugelWerkvlakken,
      ..._bepaalDeurVleugelWerkvlakken(
        vleugels: oudeVleugels,
        buitenKader: oudBuitenKader,
        breedteMm: oudeBreedteMm,
        hoogteMm: oudeHoogteMm,
      ),
    };

    final nieuweWerkvlakkenPerId = <String, Rect>{
      ...nieuweVleugelWerkvlakken,
      ..._bepaalDeurVleugelWerkvlakken(
        vleugels: nieuweVleugels,
        buitenKader: nieuwBuitenKader,
        breedteMm: nieuweBreedteMm,
        hoogteMm: nieuweHoogteMm,
      ),
    };

    final interneGroepen = <String, List<OpmetingRaamTStijl>>{};

    for (final stijl in genormaliseerdeOudeTStijlen) {
      if (stijl.werkvlakId == 'kader') {
        continue;
      }

      interneGroepen
          .putIfAbsent(stijl.werkvlakId, () => <OpmetingRaamTStijl>[])
          .add(stijl);
    }

    for (final entry in interneGroepen.entries) {
      final oudWerkvlak = oudeWerkvlakkenPerId[entry.key];
      final nieuwWerkvlak = nieuweWerkvlakkenPerId[entry.key];

      final bruikbaarOudWerkvlak =
          oudWerkvlak != null && _isGeldigVlak(oudWerkvlak)
          ? oudWerkvlak
          : oudBinnenKader;
      final bruikbaarNieuwWerkvlak =
          nieuwWerkvlak != null && _isGeldigVlak(nieuwWerkvlak)
          ? nieuwWerkvlak
          : nieuwBinnenKader;

      if (!_isGeldigVlak(bruikbaarOudWerkvlak) ||
          !_isGeldigVlak(bruikbaarNieuwWerkvlak)) {
        continue;
      }

      final aangepasteGroep = _schaalTStijlGroep(
        oudeStijlen: entry.value,
        oudWerkvlak: bruikbaarOudWerkvlak,
        nieuwWerkvlak: bruikbaarNieuwWerkvlak,
        oudBuitenKader: oudBuitenKader,
        nieuwBuitenKader: nieuwBuitenKader,
        oudeBreedteMm: oudeBreedteMm,
        oudeHoogteMm: oudeHoogteMm,
        nieuweBreedteMm: nieuweBreedteMm,
        nieuweHoogteMm: nieuweHoogteMm,
      );

      for (final stijl in aangepasteGroep) {
        aangepasteTStijlenPerId[stijl.id] = stijl;
      }
    }

    final nieuweAlleTStijlen = <OpmetingRaamTStijl>[];

    for (final oudeStijl in genormaliseerdeOudeTStijlen) {
      final aangepasteStijl = aangepasteTStijlenPerId[oudeStijl.id];

      if (aangepasteStijl != null) {
        nieuweAlleTStijlen.add(aangepasteStijl);
      }
    }

    tStijlenPerKader[kaderId] = List<OpmetingRaamTStijl>.unmodifiable(
      nieuweAlleTStijlen,
    );

    vleugelsPerKader[kaderId] = List<OpmetingRaamVleugel>.unmodifiable(
      nieuweVleugels,
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

      final langsteZijde = nieuwBinnenKader.longestSide > 0
          ? nieuwBinnenKader.longestSide
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
    final links = eerste.left > tweede.left ? eerste.left : tweede.left;
    final boven = eerste.top > tweede.top ? eerste.top : tweede.top;
    final rechts = eerste.right < tweede.right ? eerste.right : tweede.right;
    final onder = eerste.bottom < tweede.bottom ? eerste.bottom : tweede.bottom;

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

  static String? _vindDeurWerkvlakIdVoorTStijl({
    required OpmetingRaamTStijl stijl,
    required Map<String, Rect> deurWerkvlakken,
  }) {
    if (deurWerkvlakken.isEmpty) {
      return null;
    }

    if (deurWerkvlakken.containsKey(stijl.werkvlakId)) {
      return stijl.werkvlakId;
    }

    final controlePunt = _controlePuntVoorTStijl(stijl);
    final lijnRect = _tStijlLijnRect(stijl);

    String? besteWerkvlakId;
    var besteAfstand = double.infinity;

    for (final entry in deurWerkvlakken.entries) {
      final werkvlak = entry.value;
      final ruimWerkvlak = werkvlak.inflate(18);

      if (ruimWerkvlak.contains(controlePunt) ||
          lijnRect.overlaps(ruimWerkvlak)) {
        return entry.key;
      }

      if (stijl.werkvlakId.startsWith('deurvleugel_')) {
        final afstand = (controlePunt - werkvlak.center).distance;

        if (afstand < besteAfstand) {
          besteAfstand = afstand;
          besteWerkvlakId = entry.key;
        }
      }
    }

    return besteWerkvlakId;
  }

  static Offset _controlePuntVoorTStijl(OpmetingRaamTStijl stijl) {
    return Offset(
      (stijl.start.dx + stijl.einde.dx) / 2,
      (stijl.start.dy + stijl.einde.dy) / 2,
    );
  }

  static Rect _tStijlLijnRect(OpmetingRaamTStijl stijl) {
    const marge = 3.0;

    final left = stijl.start.dx < stijl.einde.dx
        ? stijl.start.dx
        : stijl.einde.dx;
    final right = stijl.start.dx > stijl.einde.dx
        ? stijl.start.dx
        : stijl.einde.dx;
    final top = stijl.start.dy < stijl.einde.dy
        ? stijl.start.dy
        : stijl.einde.dy;
    final bottom = stijl.start.dy > stijl.einde.dy
        ? stijl.start.dy
        : stijl.einde.dy;

    return Rect.fromLTRB(left, top, right, bottom).inflate(marge);
  }

  static Map<String, Rect> _bepaalDeurVleugelWerkvlakken({
    required List<OpmetingRaamVleugel> vleugels,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final resultaat = <String, Rect>{};

    for (final vleugel in vleugels) {
      if (!vleugel.isDeurVleugel) {
        continue;
      }

      final binnenRect = _deurVleugelBinnenRect(
        vleugel: vleugel,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      if (binnenRect == null || !_isGeldigVlak(binnenRect)) {
        continue;
      }

      resultaat['deurvleugel_${vleugel.id}'] = binnenRect;
    }

    return resultaat;
  }

  static Rect? _deurVleugelBinnenRect({
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0 || !_isGeldigVlak(buitenKader)) {
      return null;
    }

    final schaalX = buitenKader.width / breedteMm;
    final schaalY = buitenKader.height / hoogteMm;

    if (!schaalX.isFinite ||
        !schaalY.isFinite ||
        schaalX <= 0 ||
        schaalY <= 0) {
      return null;
    }

    final maximaleProfielBreedteX = buitenKader.width / 3;
    final maximaleProfielBreedteY = buitenKader.height / 3;

    if (maximaleProfielBreedteX < 5 || maximaleProfielBreedteY < 5) {
      return null;
    }

    final profielBreedteX = (vleugel.deurVleugelBreedteMm * schaalX)
        .abs()
        .clamp(5.0, maximaleProfielBreedteX)
        .toDouble();
    final profielBreedteY = (vleugel.deurVleugelBreedteMm * schaalY)
        .abs()
        .clamp(5.0, maximaleProfielBreedteY)
        .toDouble();
    final onderAfstandPx = (vleugel.deurVleugelOnderAfstandMm * schaalY)
        .abs()
        .clamp(0.0, buitenKader.height / 4)
        .toDouble();

    final deurRect = Rect.fromLTRB(
      vleugel.vlak.left,
      vleugel.vlak.top,
      vleugel.vlak.right,
      buitenKader.bottom - onderAfstandPx,
    );

    if (deurRect.width <= profielBreedteX * 2 + 8 ||
        deurRect.height <= profielBreedteY * 2 + 8) {
      return null;
    }

    return Rect.fromLTRB(
      deurRect.left + profielBreedteX,
      deurRect.top + profielBreedteY,
      deurRect.right - profielBreedteX,
      deurRect.bottom - profielBreedteY,
    );
  }

  static double _positieFractieVoorTStijlInWerkvlak({
    required OpmetingRaamTStijl stijl,
    required Rect werkvlak,
  }) {
    final opgeslagenFractie = stijl.positieFractie;

    if (opgeslagenFractie != null && opgeslagenFractie.isFinite) {
      return opgeslagenFractie.clamp(0.0, 1.0).toDouble();
    }

    if (stijl.richting == 'verticaal') {
      if (werkvlak.width <= 0) {
        return 0.5;
      }

      return ((stijl.start.dx - werkvlak.left) / werkvlak.width)
          .clamp(0.0, 1.0)
          .toDouble();
    }

    if (werkvlak.height <= 0) {
      return 0.5;
    }

    return ((stijl.start.dy - werkvlak.top) / werkvlak.height)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static OpmetingRaamLijn _lijnVoorTStijlInWerkvlak({
    required OpmetingRaamTStijl stijl,
    required Rect werkvlak,
    required double positieFractie,
  }) {
    if (stijl.richting == 'verticaal') {
      final x = (werkvlak.left + werkvlak.width * positieFractie)
          .clamp(werkvlak.left, werkvlak.right)
          .toDouble();

      return OpmetingRaamLijn(
        id: stijl.id,
        start: Offset(x, werkvlak.top),
        einde: Offset(x, werkvlak.bottom),
      );
    }

    final y = (werkvlak.top + werkvlak.height * positieFractie)
        .clamp(werkvlak.top, werkvlak.bottom)
        .toDouble();

    return OpmetingRaamLijn(
      id: stijl.id,
      start: Offset(werkvlak.left, y),
      einde: Offset(werkvlak.right, y),
    );
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
        positieFractie: stijl.positieFractie,
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

      final positieFractie = _positieFractieVoorTStijlInWerkvlak(
        stijl: oudeStijl,
        werkvlak: oudWerkvlak,
      );

      if (oudeStijl.werkvlakId.startsWith('deurvleugel_')) {
        final actueleLijn = _lijnVoorTStijlInWerkvlak(
          stijl: oudeStijl,
          werkvlak: nieuwWerkvlak,
          positieFractie: positieFractie,
        );

        definitieveStijlen.add(
          OpmetingRaamTStijl(
            id: oudeStijl.id,
            richting: oudeStijl.richting,
            start: actueleLijn.start,
            einde: actueleLijn.einde,
            breedteMm: oudeStijl.breedteMm,
            werkvlakId: oudeStijl.werkvlakId,
            positieFractie: positieFractie,
          ),
        );

        continue;
      }

      definitieveStijlen.add(
        OpmetingRaamTStijl(
          id: oudeStijl.id,
          richting: oudeStijl.richting,
          start: nieuweStart,
          einde: nieuweEinde,
          breedteMm: oudeStijl.breedteMm,
          werkvlakId: oudeStijl.werkvlakId,
          positieFractie: oudeStijl.positieFractie,
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
    const tolerantie = 5.0;

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

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.width > 0 &&
        vlak.height > 0 &&
        vlak.left.isFinite &&
        vlak.top.isFinite &&
        vlak.right.isFinite &&
        vlak.bottom.isFinite;
  }
}
