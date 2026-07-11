import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamKleinhoutOpschoningResultaat {
  const OpmetingRaamKleinhoutOpschoningResultaat({
    required this.kleinhouten,
    required this.geselecteerdeVlakIds,
  });

  final List<OpmetingRaamKleinhout> kleinhouten;
  final Set<String> geselecteerdeVlakIds;
}

class OpmetingRaamTekeningOpschoningResultaat {
  const OpmetingRaamTekeningOpschoningResultaat({
    required this.vullingToewijzingen,
    required this.geselecteerdeVulvlakIds,
    required this.kleinhouten,
    required this.geselecteerdeKleinhoutVlakIds,
  });

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;
  final Set<String> geselecteerdeVulvlakIds;

  final List<OpmetingRaamKleinhout> kleinhouten;
  final Set<String> geselecteerdeKleinhoutVlakIds;
}

class OpmetingRaamTekeningOpschoningHelper {
  const OpmetingRaamTekeningOpschoningHelper._();

  static OpmetingRaamTekeningOpschoningResultaat schoonAllesOp({
    required List<OpmetingRaamVulvlak> huidigeVulvlakken,
    required List<OpmetingRaamVullingToewijzing> bestaandeVullingToewijzingen,
    required Set<String> geselecteerdeVulvlakIds,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required Set<String> geselecteerdeKleinhoutVlakIds,
  }) {
    final vullingResultaat =
        OpmetingRaamTekenvlakActies.schoonVullingToewijzingenOp(
          huidigeVulvlakken: huidigeVulvlakken,
          bestaandeToewijzingen: bestaandeVullingToewijzingen,
          geselecteerdeVulvlakIds: geselecteerdeVulvlakIds,
        );

    final kleinhoutResultaat = schoonKleinhoutenOp(
      huidigeVulvlakken: huidigeVulvlakken,
      vullingToewijzingen: vullingResultaat.toewijzingen,
      bestaandeKleinhouten: bestaandeKleinhouten,
      geselecteerdeKleinhoutVlakIds: geselecteerdeKleinhoutVlakIds,
    );

    return OpmetingRaamTekeningOpschoningResultaat(
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        vullingResultaat.toewijzingen,
      ),
      geselecteerdeVulvlakIds: Set<String>.unmodifiable(
        vullingResultaat.geselecteerdeVulvlakIds,
      ),
      kleinhouten: kleinhoutResultaat.kleinhouten,
      geselecteerdeKleinhoutVlakIds: kleinhoutResultaat.geselecteerdeVlakIds,
    );
  }

  static OpmetingRaamKleinhoutOpschoningResultaat schoonKleinhoutenOp({
    required List<OpmetingRaamVulvlak> huidigeVulvlakken,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required Set<String> geselecteerdeKleinhoutVlakIds,
  }) {
    final gevuldeVlakIds = vullingToewijzingen
        .map((toewijzing) => toewijzing.vlakId)
        .toSet();

    var opgeschoondeKleinhouten =
        OpmetingRaamKleinhoutHelper.verwijderNietBestaandeKleinhouten(
          bestaandeKleinhouten: bestaandeKleinhouten,
          huidigeVulvlakken: huidigeVulvlakken,
        );

    opgeschoondeKleinhouten =
        OpmetingRaamKleinhoutHelper.verwijderKleinhoutenZonderOpvulling(
          bestaandeKleinhouten: opgeschoondeKleinhouten,
          gevuldeVlakIds: gevuldeVlakIds,
        );

    final bestaandeVlakIds = huidigeVulvlakken.map((vlak) => vlak.id).toSet();

    final opgeschoondeSelectie = Set<String>.from(
      geselecteerdeKleinhoutVlakIds,
    );

    opgeschoondeSelectie.removeWhere(
      (vlakId) =>
          !bestaandeVlakIds.contains(vlakId) ||
          !gevuldeVlakIds.contains(vlakId),
    );

    return OpmetingRaamKleinhoutOpschoningResultaat(
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(
        opgeschoondeKleinhouten,
      ),
      geselecteerdeVlakIds: Set<String>.unmodifiable(opgeschoondeSelectie),
    );
  }
}
