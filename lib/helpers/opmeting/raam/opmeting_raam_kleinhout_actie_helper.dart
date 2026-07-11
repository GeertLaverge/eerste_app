import 'dart:ui';

import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_invoer_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_kleinhout_selectie_helper.dart';
import 'opmeting_raam_tekening_vergelijking_helper.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamKleinhoutVlakSelectieResultaat {
  const OpmetingRaamKleinhoutVlakSelectieResultaat({
    required this.vlakGevonden,
    required this.foutmelding,
    required this.geselecteerdeVlakIds,
    required this.instellingenVlakId,
  });

  final bool vlakGevonden;
  final String? foutmelding;

  final Set<String> geselecteerdeVlakIds;

  /// Alleen ingevuld wanneer een vlak nieuw aan de selectie werd toegevoegd.
  final String? instellingenVlakId;
}

class OpmetingRaamKleinhoutWijzigingResultaat {
  const OpmetingRaamKleinhoutWijzigingResultaat({
    required this.actieBeschikbaar,
    required this.gewijzigd,
    required this.foutmelding,
    required this.kleinhouten,
  });

  final bool actieBeschikbaar;
  final bool gewijzigd;
  final String? foutmelding;

  final List<OpmetingRaamKleinhout> kleinhouten;
}

class OpmetingRaamKleinhoutActieHelper {
  const OpmetingRaamKleinhoutActieHelper._();

  static OpmetingRaamKleinhoutVlakSelectieResultaat wisselVlakSelectie({
    required Offset punt,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> gevuldeVlakIds,
    required Set<String> huidigeGeselecteerdeVlakIds,
  }) {
    final vulvlak = OpmetingRaamVullingHelper.vindVulvlak(
      punt: punt,
      vulvlakken: vulvlakken,
    );

    if (vulvlak == null) {
      return OpmetingRaamKleinhoutVlakSelectieResultaat(
        vlakGevonden: false,
        foutmelding: null,
        geselecteerdeVlakIds: Set<String>.unmodifiable(
          huidigeGeselecteerdeVlakIds,
        ),
        instellingenVlakId: null,
      );
    }

    if (!gevuldeVlakIds.contains(vulvlak.id)) {
      return OpmetingRaamKleinhoutVlakSelectieResultaat(
        vlakGevonden: true,
        foutmelding:
            'Kleinhouten kunnen alleen geplaatst worden wanneer het glasvlak een opvulling heeft.',
        geselecteerdeVlakIds: Set<String>.unmodifiable(
          huidigeGeselecteerdeVlakIds,
        ),
        instellingenVlakId: null,
      );
    }

    final nieuweSelectie = Set<String>.from(huidigeGeselecteerdeVlakIds);

    final wordtToegevoegd = !nieuweSelectie.contains(vulvlak.id);

    if (wordtToegevoegd) {
      nieuweSelectie.add(vulvlak.id);
    } else {
      nieuweSelectie.remove(vulvlak.id);
    }

    return OpmetingRaamKleinhoutVlakSelectieResultaat(
      vlakGevonden: true,
      foutmelding: null,
      geselecteerdeVlakIds: Set<String>.unmodifiable(nieuweSelectie),
      instellingenVlakId: wordtToegevoegd ? vulvlak.id : null,
    );
  }

  static Set<String> selecteerAlleGevuldeVlakken({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> gevuldeVlakIds,
  }) {
    final bestaandeVlakIds = vulvlakken.map((vlak) => vlak.id).toSet();

    return Set<String>.unmodifiable(
      gevuldeVlakIds.where(bestaandeVlakIds.contains),
    );
  }

  static OpmetingRaamKleinhoutWijzigingResultaat pasToe({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> geselecteerdeVlakIds,
    required Set<String> gevuldeVlakIds,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
    required OpmetingRaamKleinhoutType type,
    required OpmetingRaamKleinhoutPatroon patroon,
    required String aantalHorizontaalTekst,
    required String aantalVerticaalTekst,
    required String horizontaleHoogteTekst,
  }) {
    if (geselecteerdeVlakIds.isEmpty ||
        !OpmetingRaamKleinhoutSelectieHelper.selectieIsVolledigGevuld(
          geselecteerdeVlakIds: geselecteerdeVlakIds,
          gevuldeVlakIds: gevuldeVlakIds,
        )) {
      return _ongewijzigd(
        actieBeschikbaar: false,
        bestaandeKleinhouten: bestaandeKleinhouten,
      );
    }

    final maximaleHoogteMm =
        patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling
        ? OpmetingRaamKleinhoutSelectieHelper.kleinsteGeselecteerdeVlakHoogteMm(
            tekenvlakGrootte: tekenvlakGrootte,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
            vulvlakken: vulvlakken,
            geselecteerdeVlakIds: geselecteerdeVlakIds,
          )
        : null;

    final invoerResultaat = OpmetingRaamKleinhoutInvoerHelper.verwerk(
      patroon: patroon,
      aantalHorizontaalTekst: aantalHorizontaalTekst,
      aantalVerticaalTekst: aantalVerticaalTekst,
      horizontaleHoogteTekst: horizontaleHoogteTekst,
      maximaleHoogteMm: maximaleHoogteMm,
    );

    if (!invoerResultaat.isGeldig) {
      return _ongewijzigd(
        actieBeschikbaar: true,
        foutmelding: invoerResultaat.foutmelding,
        bestaandeKleinhouten: bestaandeKleinhouten,
      );
    }

    final geselecteerdeVlakken = vulvlakken.where(
      (vlak) => geselecteerdeVlakIds.contains(vlak.id),
    );

    final nieuweKleinhouten = OpmetingRaamKleinhoutHelper.pasKleinhoutenToe(
      bestaandeKleinhouten: bestaandeKleinhouten,
      geselecteerdeVlakken: geselecteerdeVlakken,
      gevuldeVlakIds: gevuldeVlakIds,
      type: type,
      patroon: patroon,
      aantalHorizontaal: invoerResultaat.aantalHorizontaal,
      aantalVerticaal: invoerResultaat.aantalVerticaal,
      horizontaleHoogteMm: invoerResultaat.horizontaleHoogteMm,
    );

    final gewijzigd = !OpmetingRaamTekeningVergelijkingHelper.zelfdeKleinhouten(
      bestaandeKleinhouten,
      nieuweKleinhouten,
    );

    return OpmetingRaamKleinhoutWijzigingResultaat(
      actieBeschikbaar: true,
      gewijzigd: gewijzigd,
      foutmelding: null,
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(nieuweKleinhouten),
    );
  }

  static OpmetingRaamKleinhoutWijzigingResultaat verwijder({
    required Set<String> geselecteerdeVlakIds,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
  }) {
    if (geselecteerdeVlakIds.isEmpty) {
      return _ongewijzigd(
        actieBeschikbaar: false,
        bestaandeKleinhouten: bestaandeKleinhouten,
      );
    }

    final nieuweKleinhouten =
        OpmetingRaamKleinhoutHelper.verwijderKleinhoutenUitVlakken(
          bestaandeKleinhouten: bestaandeKleinhouten,
          vlakIds: geselecteerdeVlakIds,
        );

    final gewijzigd = !OpmetingRaamTekeningVergelijkingHelper.zelfdeKleinhouten(
      bestaandeKleinhouten,
      nieuweKleinhouten,
    );

    return OpmetingRaamKleinhoutWijzigingResultaat(
      actieBeschikbaar: true,
      gewijzigd: gewijzigd,
      foutmelding: null,
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(nieuweKleinhouten),
    );
  }

  static OpmetingRaamKleinhoutWijzigingResultaat _ongewijzigd({
    required bool actieBeschikbaar,
    String? foutmelding,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
  }) {
    return OpmetingRaamKleinhoutWijzigingResultaat(
      actieBeschikbaar: actieBeschikbaar,
      gewijzigd: false,
      foutmelding: foutmelding,
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(
        bestaandeKleinhouten,
      ),
    );
  }
}
