import 'package:flutter/material.dart';

import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamKleinhoutLegendaItem {
  const OpmetingRaamKleinhoutLegendaItem({
    required this.nummer,
    required this.type,
    required this.patroon,
    required this.aantalHorizontaal,
    required this.aantalVerticaal,
    required this.horizontaleHoogteMm,
    required this.vlakIds,
  });

  final int nummer;
  final OpmetingRaamKleinhoutType type;
  final OpmetingRaamKleinhoutPatroon patroon;

  final int aantalHorizontaal;
  final int aantalVerticaal;

  final double? horizontaleHoogteMm;
  final List<String> vlakIds;

  String get aantalSamenvatting {
    return 'hor $aantalHorizontaal · vert $aantalVerticaal';
  }

  String get volledigeSamenvatting {
    return '${type.korteNaam} · $aantalSamenvatting';
  }
}

class OpmetingRaamKleinhoutHelper {
  const OpmetingRaamKleinhoutHelper._();

  static const double profielBreedteMm = 25;
  static const int maximumAantalPerRichting = 30;

  static OpmetingRaamKleinhout? vindVoorVlak({
    required String vlakId,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    for (final kleinhout in kleinhouten) {
      if (kleinhout.vlakId == vlakId) {
        return kleinhout;
      }
    }

    return null;
  }

  static bool heeftKleinhoutVoorVlak({
    required String vlakId,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    return vindVoorVlak(vlakId: vlakId, kleinhouten: kleinhouten) != null;
  }

  static List<OpmetingRaamKleinhout> pasKleinhoutenToe({
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required Iterable<OpmetingRaamVulvlak> geselecteerdeVlakken,
    required Set<String> gevuldeVlakIds,
    required OpmetingRaamKleinhoutType type,
    required OpmetingRaamKleinhoutPatroon patroon,
    required int aantalHorizontaal,
    required int aantalVerticaal,
    required double? horizontaleHoogteMm,
  }) {
    final geldigeVlakken = geselecteerdeVlakken
        .where((vlak) => gevuldeVlakIds.contains(vlak.id))
        .toList();

    if (geldigeVlakken.isEmpty) {
      return List<OpmetingRaamKleinhout>.from(bestaandeKleinhouten);
    }

    final geselecteerdeIds = geldigeVlakken.map((vlak) => vlak.id).toSet();

    final bestaandPerVlakId = <String, OpmetingRaamKleinhout>{
      for (final kleinhout in bestaandeKleinhouten) kleinhout.vlakId: kleinhout,
    };

    final resultaat = bestaandeKleinhouten
        .where((kleinhout) => !geselecteerdeIds.contains(kleinhout.vlakId))
        .toList();

    final horizontaal = patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling
        ? 1
        : _begrensAantal(aantalHorizontaal);

    final verticaal = _begrensAantal(aantalVerticaal);

    for (var index = 0; index < geldigeVlakken.length; index++) {
      final vlak = geldigeVlakken[index];
      final bestaand = bestaandPerVlakId[vlak.id];

      resultaat.add(
        OpmetingRaamKleinhout(
          id: bestaand?.id ?? '${DateTime.now().microsecondsSinceEpoch}_$index',
          vlakId: vlak.id,
          werkvlakId: vlak.werkvlakId,
          type: type,
          patroon: patroon,
          aantalHorizontaal: horizontaal,
          aantalVerticaal: verticaal,
          horizontaleHoogteMm:
              patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling
              ? horizontaleHoogteMm
              : null,
          breedteMm: profielBreedteMm,
        ),
      );
    }

    resultaat.sort((eerste, tweede) {
      return eerste.vlakId.compareTo(tweede.vlakId);
    });

    return resultaat;
  }

  static List<OpmetingRaamKleinhout> verwijderKleinhoutenUitVlakken({
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required Iterable<String> vlakIds,
  }) {
    final teVerwijderenIds = vlakIds.toSet();

    return bestaandeKleinhouten
        .where((kleinhout) => !teVerwijderenIds.contains(kleinhout.vlakId))
        .toList();
  }

  static List<OpmetingRaamKleinhout> verwijderKleinhoutenZonderOpvulling({
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required Set<String> gevuldeVlakIds,
  }) {
    return bestaandeKleinhouten
        .where((kleinhout) => gevuldeVlakIds.contains(kleinhout.vlakId))
        .toList();
  }

  static List<OpmetingRaamKleinhout> verwijderNietBestaandeKleinhouten({
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required List<OpmetingRaamVulvlak> huidigeVulvlakken,
  }) {
    final bestaandeVlakIds = huidigeVulvlakken.map((vlak) => vlak.id).toSet();

    return bestaandeKleinhouten
        .where((kleinhout) => bestaandeVlakIds.contains(kleinhout.vlakId))
        .toList();
  }

  static List<OpmetingRaamKleinhout> herkoppelKleinhoutenNaVlakWijziging({
    required List<OpmetingRaamVulvlak> oudeVulvlakken,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required Set<String> nieuweGevuldeVlakIds,
  }) {
    if (bestaandeKleinhouten.isEmpty ||
        nieuweVulvlakken.isEmpty ||
        nieuweGevuldeVlakIds.isEmpty) {
      return <OpmetingRaamKleinhout>[];
    }

    final oudVlakPerId = <String, OpmetingRaamVulvlak>{
      for (final vlak in oudeVulvlakken) vlak.id: vlak,
    };

    final beschikbareNieuweVlakken = nieuweVulvlakken
        .where((vlak) => nieuweGevuldeVlakIds.contains(vlak.id))
        .toList();

    if (beschikbareNieuweVlakken.isEmpty) {
      return <OpmetingRaamKleinhout>[];
    }

    /*
     * De referentievlakken omvatten alle oude en nieuwe
     * glasvlakken. Daardoor kunnen de posities als fracties
     * tussen 0 en 1 vergeleken worden.
     *
     * Dit blijft correct wanneer het tekenvlak van liggend
     * naar staand of van staand naar liggend verandert.
     */
    final oudeReferentie = _omsluitendeRechthoek(
      oudeVulvlakken.map((vlak) => vlak.vlak),
    );

    final nieuweReferentie = _omsluitendeRechthoek(
      nieuweVulvlakken.map((vlak) => vlak.vlak),
    );

    final gebruikteNieuweVlakIds = <String>{};
    final resultaat = <OpmetingRaamKleinhout>[];

    for (final bestaand in bestaandeKleinhouten) {
      final oudVlak = oudVlakPerId[bestaand.vlakId];

      final nieuwVlak = _vindBesteNieuweVlak(
        bestaand: bestaand,
        oudVlak: oudVlak,
        nieuweVulvlakken: beschikbareNieuweVlakken,
        gebruikteNieuweVlakIds: gebruikteNieuweVlakIds,
        oudeReferentie: oudeReferentie,
        nieuweReferentie: nieuweReferentie,
      );

      if (nieuwVlak == null) {
        continue;
      }

      gebruikteNieuweVlakIds.add(nieuwVlak.id);

      /*
       * copyWith behoudt de oorspronkelijke kleinhout-ID,
       * het type, het patroon, de aantallen, de hoogte en
       * de profielbreedte.
       *
       * Alleen de koppeling met het nieuwe vlak verandert.
       */
      resultaat.add(
        bestaand.copyWith(
          vlakId: nieuwVlak.id,
          werkvlakId: nieuwVlak.werkvlakId,
        ),
      );
    }

    resultaat.sort((eerste, tweede) {
      return eerste.vlakId.compareTo(tweede.vlakId);
    });

    return resultaat;
  }

  static OpmetingRaamVulvlak? _vindBesteNieuweVlak({
    required OpmetingRaamKleinhout bestaand,
    required OpmetingRaamVulvlak? oudVlak,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required Set<String> gebruikteNieuweVlakIds,
    required Rect? oudeReferentie,
    required Rect? nieuweReferentie,
  }) {
    final vrijeVlakken = nieuweVulvlakken
        .where((vlak) => !gebruikteNieuweVlakIds.contains(vlak.id))
        .toList();

    if (vrijeVlakken.isEmpty) {
      return null;
    }

    /*
     * Een identieke vlak-ID is altijd de eerste keuze.
     * Bij een gewone schermrotatie blijven de IDs normaal
     * ongewijzigd.
     */
    for (final vlak in vrijeVlakken) {
      if (vlak.id == bestaand.vlakId) {
        return vlak;
      }
    }

    /*
     * Daarna zoeken we eerst binnen hetzelfde kader- of
     * vleugelwerkvlak.
     */
    var kandidaten = vrijeVlakken
        .where((vlak) => vlak.werkvlakId == bestaand.werkvlakId)
        .toList();

    if (kandidaten.isEmpty) {
      kandidaten = vrijeVlakken;
    }

    if (oudVlak == null) {
      kandidaten.sort((eerste, tweede) {
        return eerste.id.compareTo(tweede.id);
      });

      return kandidaten.first;
    }

    kandidaten.sort((eerste, tweede) {
      final eersteScore = _berekenVlakScore(
        oudVlak: oudVlak.vlak,
        nieuwVlak: eerste.vlak,
        oudeReferentie: oudeReferentie,
        nieuweReferentie: nieuweReferentie,
      );

      final tweedeScore = _berekenVlakScore(
        oudVlak: oudVlak.vlak,
        nieuwVlak: tweede.vlak,
        oudeReferentie: oudeReferentie,
        nieuweReferentie: nieuweReferentie,
      );

      final scoreVergelijking = tweedeScore.compareTo(eersteScore);

      if (scoreVergelijking != 0) {
        return scoreVergelijking;
      }

      return eerste.id.compareTo(tweede.id);
    });

    return kandidaten.first;
  }

  static List<OpmetingRaamKleinhoutLegendaItem> bepaalLegenda({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    final bestaandeVlakIds = vulvlakken.map((vlak) => vlak.id).toSet();

    final groepen = <String, List<OpmetingRaamKleinhout>>{};

    for (final kleinhout in kleinhouten) {
      if (!bestaandeVlakIds.contains(kleinhout.vlakId)) {
        continue;
      }

      final groepId = _maakLegendaGroepId(kleinhout);

      groepen
          .putIfAbsent(groepId, () => <OpmetingRaamKleinhout>[])
          .add(kleinhout);
    }

    final legenda = <OpmetingRaamKleinhoutLegendaItem>[];

    var nummer = 1;

    for (final groep in groepen.values) {
      if (groep.isEmpty) {
        continue;
      }

      final eerste = groep.first;

      legenda.add(
        OpmetingRaamKleinhoutLegendaItem(
          nummer: nummer,
          type: eerste.type,
          patroon: eerste.patroon,
          aantalHorizontaal: eerste.effectiefAantalHorizontaal,
          aantalVerticaal: eerste.effectiefAantalVerticaal,
          horizontaleHoogteMm: eerste.horizontaleHoogteMm,
          vlakIds: groep.map((kleinhout) => kleinhout.vlakId).toList(),
        ),
      );

      nummer++;
    }

    return legenda;
  }

  static void tekenKleinhouten({
    required Canvas canvas,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamKleinhout> kleinhouten,
    Set<String> geselecteerdeVlakIds = const <String>{},
  }) {
    if (breedteMm <= 0 ||
        hoogteMm <= 0 ||
        buitenKader.width <= 0 ||
        buitenKader.height <= 0) {
      return;
    }

    final vlakPerId = <String, OpmetingRaamVulvlak>{
      for (final vlak in vulvlakken) vlak.id: vlak,
    };

    for (final kleinhout in kleinhouten) {
      final vulvlak = vlakPerId[kleinhout.vlakId];

      if (vulvlak == null ||
          vulvlak.vlak.width <= 0 ||
          vulvlak.vlak.height <= 0) {
        continue;
      }

      _tekenKleinhoutInVlak(
        canvas: canvas,
        vlak: vulvlak.vlak,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        kleinhout: kleinhout,
      );

      if (geselecteerdeVlakIds.contains(vulvlak.id)) {
        final selectieLijn = Paint()
          ..color = const Color(0xFF0B7A3B)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawRect(vulvlak.vlak.deflate(1), selectieLijn);
      }
    }
  }

  static void _tekenKleinhoutInVlak({
    required Canvas canvas,
    required Rect vlak,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingRaamKleinhout kleinhout,
  }) {
    final verticaleBreedtePx =
        (buitenKader.width / breedteMm) * kleinhout.breedteMm;

    final horizontaleBreedtePx =
        (buitenKader.height / hoogteMm) * kleinhout.breedteMm;

    if (verticaleBreedtePx <= 0 || horizontaleBreedtePx <= 0) {
      return;
    }

    canvas.save();
    canvas.clipRect(vlak);

    if (kleinhout.patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling) {
      _tekenBovenverdeling(
        canvas: canvas,
        vlak: vlak,
        buitenKader: buitenKader,
        hoogteMm: hoogteMm,
        verticaleBreedtePx: verticaleBreedtePx,
        horizontaleBreedtePx: horizontaleBreedtePx,
        kleinhout: kleinhout,
      );
    } else {
      _tekenVolledigRaster(
        canvas: canvas,
        vlak: vlak,
        verticaleBreedtePx: verticaleBreedtePx,
        horizontaleBreedtePx: horizontaleBreedtePx,
        kleinhout: kleinhout,
      );
    }

    canvas.restore();
  }

  static void _tekenBovenverdeling({
    required Canvas canvas,
    required Rect vlak,
    required Rect buitenKader,
    required int hoogteMm,
    required double verticaleBreedtePx,
    required double horizontaleBreedtePx,
    required OpmetingRaamKleinhout kleinhout,
  }) {
    final hoogteInMm = kleinhout.horizontaleHoogteMm;

    if (hoogteInMm == null || hoogteInMm <= 0) {
      return;
    }

    final pixelsPerMm = buitenKader.height / hoogteMm;

    final minimumY = vlak.top + (horizontaleBreedtePx / 2);

    final maximumY = vlak.bottom - (horizontaleBreedtePx / 2);

    if (maximumY <= minimumY) {
      return;
    }

    final horizontaleY = (vlak.top + (hoogteInMm * pixelsPerMm))
        .clamp(minimumY, maximumY)
        .toDouble();

    _tekenHorizontaalProfiel(
      canvas: canvas,
      vlak: vlak,
      middenY: horizontaleY,
      profielBreedtePx: horizontaleBreedtePx,
      type: kleinhout.type,
    );

    final aantalVerticaal = kleinhout.effectiefAantalVerticaal;

    if (aantalVerticaal <= 0) {
      return;
    }

    for (var index = 1; index <= aantalVerticaal; index++) {
      final fractie = index / (aantalVerticaal + 1);

      final x = vlak.left + (vlak.width * fractie);

      _tekenVerticaalProfiel(
        canvas: canvas,
        boven: vlak.top,
        onder: horizontaleY,
        middenX: x,
        profielBreedtePx: verticaleBreedtePx,
        type: kleinhout.type,
      );
    }
  }

  static void _tekenVolledigRaster({
    required Canvas canvas,
    required Rect vlak,
    required double verticaleBreedtePx,
    required double horizontaleBreedtePx,
    required OpmetingRaamKleinhout kleinhout,
  }) {
    final aantalHorizontaal = kleinhout.effectiefAantalHorizontaal;

    final aantalVerticaal = kleinhout.effectiefAantalVerticaal;

    for (var index = 1; index <= aantalHorizontaal; index++) {
      final fractie = index / (aantalHorizontaal + 1);

      final y = vlak.top + (vlak.height * fractie);

      _tekenHorizontaalProfiel(
        canvas: canvas,
        vlak: vlak,
        middenY: y,
        profielBreedtePx: horizontaleBreedtePx,
        type: kleinhout.type,
      );
    }

    for (var index = 1; index <= aantalVerticaal; index++) {
      final fractie = index / (aantalVerticaal + 1);

      final x = vlak.left + (vlak.width * fractie);

      _tekenVerticaalProfiel(
        canvas: canvas,
        boven: vlak.top,
        onder: vlak.bottom,
        middenX: x,
        profielBreedtePx: verticaleBreedtePx,
        type: kleinhout.type,
      );
    }
  }

  static void _tekenHorizontaalProfiel({
    required Canvas canvas,
    required Rect vlak,
    required double middenY,
    required double profielBreedtePx,
    required OpmetingRaamKleinhoutType type,
  }) {
    final profiel = Rect.fromLTRB(
      vlak.left,
      middenY - (profielBreedtePx / 2),
      vlak.right,
      middenY + (profielBreedtePx / 2),
    );

    _tekenProfiel(
      canvas: canvas,
      profiel: profiel,
      type: type,
      horizontaal: true,
    );
  }

  static void _tekenVerticaalProfiel({
    required Canvas canvas,
    required double boven,
    required double onder,
    required double middenX,
    required double profielBreedtePx,
    required OpmetingRaamKleinhoutType type,
  }) {
    final profiel = Rect.fromLTRB(
      middenX - (profielBreedtePx / 2),
      boven,
      middenX + (profielBreedtePx / 2),
      onder,
    );

    _tekenProfiel(
      canvas: canvas,
      profiel: profiel,
      type: type,
      horizontaal: false,
    );
  }

  static void _tekenProfiel({
    required Canvas canvas,
    required Rect profiel,
    required OpmetingRaamKleinhoutType type,
    required bool horizontaal,
  }) {
    switch (type) {
      case OpmetingRaamKleinhoutType.opGlasRecht:
        final vulling = Paint()
          ..color = Colors.white.withOpacity(0.92)
          ..style = PaintingStyle.fill;

        final rand = Paint()
          ..color = const Color(0xFF374151)
          ..strokeWidth = 0.9
          ..style = PaintingStyle.stroke;

        canvas.drawRect(profiel, vulling);

        canvas.drawRect(profiel, rand);

        break;

      case OpmetingRaamKleinhoutType.opGlasSteelLook:
        final vulling = Paint()
          ..color = const Color(0xFF202124)
          ..style = PaintingStyle.fill;

        final rand = Paint()
          ..color = Colors.black
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

        canvas.drawRect(profiel, vulling);

        canvas.drawRect(profiel, rand);

        break;

      case OpmetingRaamKleinhoutType.inGlas:
        final vulling = Paint()
          ..color = const Color(0xFF9CA3AF).withOpacity(0.24)
          ..style = PaintingStyle.fill;

        final rand = Paint()
          ..color = const Color(0xFF6B7280)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

        final middenLijn = Paint()
          ..color = const Color(0xFF6B7280)
          ..strokeWidth = 0.6;

        canvas.drawRect(profiel, vulling);

        canvas.drawRect(profiel, rand);

        if (horizontaal) {
          canvas.drawLine(
            Offset(profiel.left, profiel.center.dy),
            Offset(profiel.right, profiel.center.dy),
            middenLijn,
          );
        } else {
          canvas.drawLine(
            Offset(profiel.center.dx, profiel.top),
            Offset(profiel.center.dx, profiel.bottom),
            middenLijn,
          );
        }

        break;
    }
  }

  static int _begrensAantal(int aantal) {
    return aantal.clamp(0, maximumAantalPerRichting).toInt();
  }

  static String _maakLegendaGroepId(OpmetingRaamKleinhout kleinhout) {
    return '${kleinhout.type.name}_'
        '${kleinhout.patroon.name}_'
        '${kleinhout.effectiefAantalHorizontaal}_'
        '${kleinhout.effectiefAantalVerticaal}_'
        '${kleinhout.horizontaleHoogteMm?.toStringAsFixed(1) ?? ''}';
  }

  /// Vergelijkt oude en nieuwe glasvlakken relatief binnen
  /// hun volledige raamblok.
  ///
  /// Daardoor blijft de score bruikbaar wanneer het scherm
  /// van verhouding of oriëntatie verandert.
  static double _berekenVlakScore({
    required Rect oudVlak,
    required Rect nieuwVlak,
    required Rect? oudeReferentie,
    required Rect? nieuweReferentie,
  }) {
    final genormaliseerdOudVlak = _normaliseerRect(
      vlak: oudVlak,
      referentie: oudeReferentie,
    );

    final genormaliseerdNieuwVlak = _normaliseerRect(
      vlak: nieuwVlak,
      referentie: nieuweReferentie,
    );

    if (genormaliseerdOudVlak == null || genormaliseerdNieuwVlak == null) {
      return _berekenRuweVlakScore(oudVlak, nieuwVlak);
    }

    final randVerschil =
        (genormaliseerdOudVlak.left - genormaliseerdNieuwVlak.left).abs() +
        (genormaliseerdOudVlak.right - genormaliseerdNieuwVlak.right).abs() +
        (genormaliseerdOudVlak.top - genormaliseerdNieuwVlak.top).abs() +
        (genormaliseerdOudVlak.bottom - genormaliseerdNieuwVlak.bottom).abs();

    final randScore = 1 - (randVerschil / 4).clamp(0.0, 1.0).toDouble();

    final middenAfstand =
        (genormaliseerdOudVlak.center - genormaliseerdNieuwVlak.center)
            .distance;

    const maximaleGenormaliseerdeAfstand = 1.4142135623730951;

    final middenScore =
        1 -
        (middenAfstand / maximaleGenormaliseerdeAfstand)
            .clamp(0.0, 1.0)
            .toDouble();

    final breedteScore =
        1 -
        (genormaliseerdOudVlak.width - genormaliseerdNieuwVlak.width)
            .abs()
            .clamp(0.0, 1.0)
            .toDouble();

    final hoogteScore =
        1 -
        (genormaliseerdOudVlak.height - genormaliseerdNieuwVlak.height)
            .abs()
            .clamp(0.0, 1.0)
            .toDouble();

    return randScore * 0.50 +
        middenScore * 0.25 +
        breedteScore * 0.125 +
        hoogteScore * 0.125;
  }

  static double _berekenRuweVlakScore(Rect oudVlak, Rect nieuwVlak) {
    final overlap = _overlapOppervlakte(oudVlak, nieuwVlak);

    final oudeOppervlakte = _oppervlakte(oudVlak);

    final nieuweOppervlakte = _oppervlakte(nieuwVlak);

    final overlapScore = oudeOppervlakte > 0 && nieuweOppervlakte > 0
        ? (overlap / oudeOppervlakte) + (overlap / nieuweOppervlakte)
        : 0.0;

    final gezamenlijkeGrenzen = oudVlak.expandToInclude(nieuwVlak);

    final maximaleAfstand = gezamenlijkeGrenzen.size.longestSide > 0
        ? gezamenlijkeGrenzen.size.longestSide
        : 1.0;

    final middenAfstand = (oudVlak.center - nieuwVlak.center).distance;

    final middenScore =
        1 - (middenAfstand / maximaleAfstand).clamp(0.0, 1.0).toDouble();

    return overlapScore * 10 + middenScore;
  }

  static Rect? _omsluitendeRechthoek(Iterable<Rect> vlakken) {
    Rect? resultaat;

    for (final vlak in vlakken) {
      if (!_isGeldigVlak(vlak)) {
        continue;
      }

      resultaat = resultaat == null ? vlak : resultaat.expandToInclude(vlak);
    }

    return resultaat;
  }

  static Rect? _normaliseerRect({
    required Rect vlak,
    required Rect? referentie,
  }) {
    if (!_isGeldigVlak(vlak) ||
        referentie == null ||
        !_isGeldigVlak(referentie)) {
      return null;
    }

    final links = ((vlak.left - referentie.left) / referentie.width)
        .clamp(0.0, 1.0)
        .toDouble();

    final rechts = ((vlak.right - referentie.left) / referentie.width)
        .clamp(0.0, 1.0)
        .toDouble();

    final boven = ((vlak.top - referentie.top) / referentie.height)
        .clamp(0.0, 1.0)
        .toDouble();

    final onder = ((vlak.bottom - referentie.top) / referentie.height)
        .clamp(0.0, 1.0)
        .toDouble();

    if (rechts <= links || onder <= boven) {
      return null;
    }

    return Rect.fromLTRB(links, boven, rechts, onder);
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

  static double _oppervlakte(Rect vlak) {
    if (!_isGeldigVlak(vlak)) {
      return 0;
    }

    return vlak.width * vlak.height;
  }

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.left.isFinite &&
        vlak.top.isFinite &&
        vlak.right.isFinite &&
        vlak.bottom.isFinite &&
        vlak.width > 0 &&
        vlak.height > 0;
  }
}
