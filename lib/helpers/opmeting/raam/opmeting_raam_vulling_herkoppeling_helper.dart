import 'dart:ui';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamVullingHerkoppelingHelper {
  const OpmetingRaamVullingHerkoppelingHelper._();

  static List<OpmetingRaamVullingToewijzing> herkoppelNaVlakWijziging({
    required List<OpmetingRaamVulvlak> oudeVulvlakken,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required Rect oudeReferentie,
    required Rect nieuweReferentie,
  }) {
    if (bestaandeToewijzingen.isEmpty) {
      return <OpmetingRaamVullingToewijzing>[];
    }

    if (nieuweVulvlakken.isEmpty) {
      return <OpmetingRaamVullingToewijzing>[];
    }

    final oudVlakPerId = <String, OpmetingRaamVulvlak>{
      for (final vlak in oudeVulvlakken) vlak.id: vlak,
    };

    final nieuwVlakPerId = <String, OpmetingRaamVulvlak>{
      for (final vlak in nieuweVulvlakken) vlak.id: vlak,
    };

    final gebruikteNieuweVlakIds = <String>{};

    final resultaat = <OpmetingRaamVullingToewijzing>[];

    for (final toewijzing in bestaandeToewijzingen) {
      final oudVlak = oudVlakPerId[toewijzing.vlakId];

      OpmetingRaamVulvlak? nieuwVlak;

      final zelfdeIdVlak = nieuwVlakPerId[toewijzing.vlakId];

      if (zelfdeIdVlak != null &&
          !gebruikteNieuweVlakIds.contains(zelfdeIdVlak.id)) {
        nieuwVlak = zelfdeIdVlak;
      }

      if (nieuwVlak == null && oudVlak != null) {
        nieuwVlak = _vindBesteNieuwVulvlak(
          oudVlak: oudVlak,
          nieuweVulvlakken: nieuweVulvlakken,
          gebruikteNieuweVlakIds: gebruikteNieuweVlakIds,
          oudeReferentie: oudeReferentie,
          nieuweReferentie: nieuweReferentie,
        );
      }

      nieuwVlak ??= _vindVrijNieuwVulvlakZonderOudeGeometrie(
        toewijzing: toewijzing,
        nieuweVulvlakken: nieuweVulvlakken,
        gebruikteNieuweVlakIds: gebruikteNieuweVlakIds,
      );

      if (nieuwVlak == null) {
        continue;
      }

      gebruikteNieuweVlakIds.add(nieuwVlak.id);

      resultaat.add(
        OpmetingRaamVullingToewijzing(
          vlakId: nieuwVlak.id,
          werkvlakId: nieuwVlak.werkvlakId,
          opvullingId: toewijzing.opvullingId,
          naam: toewijzing.naam,
          kleurWaarde: toewijzing.kleurWaarde,
          transparantie: toewijzing.transparantie,
        ),
      );
    }

    return resultaat;
  }

  static OpmetingRaamVulvlak? _vindVrijNieuwVulvlakZonderOudeGeometrie({
    required OpmetingRaamVullingToewijzing toewijzing,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required Set<String> gebruikteNieuweVlakIds,
  }) {
    final vrijeVlakken = nieuweVulvlakken
        .where((vlak) => !gebruikteNieuweVlakIds.contains(vlak.id))
        .toList();

    if (vrijeVlakken.isEmpty) {
      return null;
    }

    var kandidaten = vrijeVlakken
        .where((vlak) => vlak.werkvlakId == toewijzing.werkvlakId)
        .toList();

    if (kandidaten.isEmpty) {
      kandidaten = vrijeVlakken;
    }

    final gewenstVlakNummer = _leesVlakNummer(toewijzing.vlakId);

    if (gewenstVlakNummer != null) {
      for (final kandidaat in kandidaten) {
        if (_leesVlakNummer(kandidaat.id) == gewenstVlakNummer) {
          return kandidaat;
        }
      }
    }

    kandidaten.sort((eerste, tweede) {
      final bovenVergelijking = eerste.vlak.top.compareTo(tweede.vlak.top);

      if (bovenVergelijking != 0) {
        return bovenVergelijking;
      }

      final linksVergelijking = eerste.vlak.left.compareTo(tweede.vlak.left);

      if (linksVergelijking != 0) {
        return linksVergelijking;
      }

      return eerste.id.compareTo(tweede.id);
    });

    return kandidaten.first;
  }

  static int? _leesVlakNummer(String vlakId) {
    final overeenkomst = RegExp(r'_vlak_(\d+)$').firstMatch(vlakId);

    if (overeenkomst == null) {
      return null;
    }

    return int.tryParse(overeenkomst.group(1) ?? '');
  }

  static OpmetingRaamVulvlak? _vindBesteNieuwVulvlak({
    required OpmetingRaamVulvlak oudVlak,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required Set<String> gebruikteNieuweVlakIds,
    required Rect oudeReferentie,
    required Rect nieuweReferentie,
  }) {
    OpmetingRaamVulvlak? besteVlak;

    double besteScore = double.infinity;

    for (final kandidaat in nieuweVulvlakken) {
      if (gebruikteNieuweVlakIds.contains(kandidaat.id)) {
        continue;
      }

      final score = _vulvlakOvereenkomstScore(
        oudVlak: oudVlak,
        nieuwVlak: kandidaat,
        oudeReferentie: oudeReferentie,
        nieuweReferentie: nieuweReferentie,
      );

      if (score < besteScore) {
        besteScore = score;
        besteVlak = kandidaat;
      }
    }

    return besteVlak;
  }

  static double _vulvlakOvereenkomstScore({
    required OpmetingRaamVulvlak oudVlak,
    required OpmetingRaamVulvlak nieuwVlak,
    required Rect oudeReferentie,
    required Rect nieuweReferentie,
  }) {
    final werkvlakBoete = oudVlak.werkvlakId == nieuwVlak.werkvlakId
        ? 0.0
        : 1000.0;

    final oudLinks = _genormaliseerdeX(oudVlak.vlak.left, oudeReferentie);

    final oudRechts = _genormaliseerdeX(oudVlak.vlak.right, oudeReferentie);

    final oudBoven = _genormaliseerdeY(oudVlak.vlak.top, oudeReferentie);

    final oudOnder = _genormaliseerdeY(oudVlak.vlak.bottom, oudeReferentie);

    final nieuwLinks = _genormaliseerdeX(nieuwVlak.vlak.left, nieuweReferentie);

    final nieuwRechts = _genormaliseerdeX(
      nieuwVlak.vlak.right,
      nieuweReferentie,
    );

    final nieuwBoven = _genormaliseerdeY(nieuwVlak.vlak.top, nieuweReferentie);

    final nieuwOnder = _genormaliseerdeY(
      nieuwVlak.vlak.bottom,
      nieuweReferentie,
    );

    final randAfwijking =
        (oudLinks - nieuwLinks).abs() +
        (oudRechts - nieuwRechts).abs() +
        (oudBoven - nieuwBoven).abs() +
        (oudOnder - nieuwOnder).abs();

    final oudMiddenX = (oudLinks + oudRechts) / 2;
    final oudMiddenY = (oudBoven + oudOnder) / 2;

    final nieuwMiddenX = (nieuwLinks + nieuwRechts) / 2;
    final nieuwMiddenY = (nieuwBoven + nieuwOnder) / 2;

    final middenAfwijking =
        (oudMiddenX - nieuwMiddenX).abs() + (oudMiddenY - nieuwMiddenY).abs();

    return werkvlakBoete + randAfwijking * 100 + middenAfwijking * 10;
  }

  static double _genormaliseerdeX(double waarde, Rect referentie) {
    if (referentie.width <= 0) {
      return 0;
    }

    return ((waarde - referentie.left) / referentie.width)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _genormaliseerdeY(double waarde, Rect referentie) {
    if (referentie.height <= 0) {
      return 0;
    }

    return ((waarde - referentie.top) / referentie.height)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
