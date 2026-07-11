import 'dart:ui';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_tekening_vergelijking_helper.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamOpvullingSelectieResultaat {
  const OpmetingRaamOpvullingSelectieResultaat({
    required this.vlakGevonden,
    required this.geselecteerdeVlakIds,
    required this.geselecteerdeOpvullingId,
  });

  final bool vlakGevonden;
  final Set<String> geselecteerdeVlakIds;
  final String? geselecteerdeOpvullingId;
}

class OpmetingRaamOpvullingWijzigingResultaat {
  const OpmetingRaamOpvullingWijzigingResultaat({
    required this.actieBeschikbaar,
    required this.gewijzigd,
    required this.toewijzingen,
  });

  final bool actieBeschikbaar;
  final bool gewijzigd;

  final List<OpmetingRaamVullingToewijzing> toewijzingen;
}

class OpmetingRaamOpvullingActieHelper {
  const OpmetingRaamOpvullingActieHelper._();

  static OpmetingRaamOpvullingSelectieResultaat wisselSelectie({
    required Offset punt,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> huidigeGeselecteerdeVlakIds,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
    required List<OpmetingRaamOpvullingModel> opvullingen,
    required String? huidigeGeselecteerdeOpvullingId,
  }) {
    final resultaat = OpmetingRaamTekenvlakActies.wisselVulvlakSelectie(
      punt: punt,
      vulvlakken: vulvlakken,
      huidigeGeselecteerdeVulvlakIds: huidigeGeselecteerdeVlakIds,
      toewijzingen: toewijzingen,
      opvullingen: opvullingen,
      huidigeGeselecteerdeOpvullingId: huidigeGeselecteerdeOpvullingId,
    );

    return OpmetingRaamOpvullingSelectieResultaat(
      vlakGevonden: resultaat.vlakGevonden,
      geselecteerdeVlakIds: Set<String>.unmodifiable(
        resultaat.geselecteerdeVulvlakIds,
      ),
      geselecteerdeOpvullingId: resultaat.geselecteerdeOpvullingId,
    );
  }

  static OpmetingRaamOpvullingWijzigingResultaat pasToe({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> geselecteerdeVlakIds,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required List<OpmetingRaamOpvullingModel> opvullingen,
    required String? geselecteerdeOpvullingId,
  }) {
    final opvulling = OpmetingRaamTekenvlakActies.vindGeselecteerdeOpvulling(
      opvullingen: opvullingen,
      geselecteerdeOpvullingId: geselecteerdeOpvullingId,
    );

    if (opvulling == null) {
      return _ongewijzigd(
        actieBeschikbaar: false,
        bestaandeToewijzingen: bestaandeToewijzingen,
      );
    }

    final nieuweToewijzingen = OpmetingRaamTekenvlakActies.pasOpvullingToe(
      vulvlakken: vulvlakken,
      geselecteerdeVulvlakIds: geselecteerdeVlakIds,
      bestaandeToewijzingen: bestaandeToewijzingen,
      opvulling: opvulling,
    );

    final gewijzigd =
        !OpmetingRaamTekeningVergelijkingHelper.zelfdeVullingToewijzingen(
          bestaandeToewijzingen,
          nieuweToewijzingen,
        );

    return OpmetingRaamOpvullingWijzigingResultaat(
      actieBeschikbaar: true,
      gewijzigd: gewijzigd,
      toewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        nieuweToewijzingen,
      ),
    );
  }

  static OpmetingRaamOpvullingWijzigingResultaat verwijder({
    required Set<String> geselecteerdeVlakIds,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
  }) {
    if (geselecteerdeVlakIds.isEmpty) {
      return _ongewijzigd(
        actieBeschikbaar: false,
        bestaandeToewijzingen: bestaandeToewijzingen,
      );
    }

    final nieuweToewijzingen =
        OpmetingRaamTekenvlakActies.verwijderOpvullingUitSelectie(
          bestaandeToewijzingen: bestaandeToewijzingen,
          geselecteerdeVulvlakIds: geselecteerdeVlakIds,
        );

    final gewijzigd =
        !OpmetingRaamTekeningVergelijkingHelper.zelfdeVullingToewijzingen(
          bestaandeToewijzingen,
          nieuweToewijzingen,
        );

    return OpmetingRaamOpvullingWijzigingResultaat(
      actieBeschikbaar: true,
      gewijzigd: gewijzigd,
      toewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        nieuweToewijzingen,
      ),
    );
  }

  static Set<String> selecteerAlles(List<OpmetingRaamVulvlak> vulvlakken) {
    return Set<String>.unmodifiable(
      OpmetingRaamTekenvlakActies.selecteerAlleVulvlakken(vulvlakken),
    );
  }

  static OpmetingRaamOpvullingWijzigingResultaat _ongewijzigd({
    required bool actieBeschikbaar,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
  }) {
    return OpmetingRaamOpvullingWijzigingResultaat(
      actieBeschikbaar: actieBeschikbaar,
      gewijzigd: false,
      toewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        bestaandeToewijzingen,
      ),
    );
  }
}
