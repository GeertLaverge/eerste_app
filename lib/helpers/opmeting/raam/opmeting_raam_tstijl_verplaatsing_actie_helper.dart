import 'dart:ui';

import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_tstijl_verplaats_helper.dart';

class OpmetingRaamTStijlVerplaatsingActieResultaat {
  const OpmetingRaamTStijlVerplaatsingActieResultaat({
    required this.gewijzigd,
    required this.foutmelding,
    required this.tStijlen,
    required this.vleugels,
    required this.vullingToewijzingen,
    required this.kleinhouten,
  });

  final bool gewijzigd;
  final String? foutmelding;

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;

  final List<OpmetingRaamKleinhout> kleinhouten;
}

class OpmetingRaamTStijlVerplaatsingActieHelper {
  const OpmetingRaamTStijlVerplaatsingActieHelper._();

  static OpmetingRaamTStijlVerplaatsingActieResultaat verplaats({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required String positieTekst,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
    required List<OpmetingRaamVullingToewijzing> bestaandeVullingToewijzingen,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
  }) {
    final index = OpmetingRaamTekenvlakActies.indexVanGeselecteerdeTStijlLijn(
      geselecteerdeLijn,
    );

    if (index == null) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        kleinhouten: bestaandeKleinhouten,
      );
    }

    final oudeVulvlakken = OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: bestaandeTStijlen,
      vleugels: bestaandeVleugels,
    );

    final verplaatsResultaat =
        OpmetingRaamTStijlVerplaatsHelper.verplaatsTStijl(
          tekenvlakGrootte: tekenvlakGrootte,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          tStijlIndex: index,
          positieType: positieType,
          positieTekst: positieTekst,
          bestaandeTStijlen: bestaandeTStijlen,
          bestaandeVleugels: bestaandeVleugels,
          bestaandeVullingToewijzingen: bestaandeVullingToewijzingen,
        );

    if (!verplaatsResultaat.gewijzigd) {
      return _ongewijzigd(
        foutmelding: verplaatsResultaat.foutmelding,
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        kleinhouten: bestaandeKleinhouten,
      );
    }

    final nieuweVulvlakken = OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: verplaatsResultaat.tStijlen,
      vleugels: verplaatsResultaat.vleugels,
    );

    final nieuweGevuldeVlakIds = verplaatsResultaat.vullingToewijzingen
        .map((toewijzing) => toewijzing.vlakId)
        .toSet();

    final nieuweKleinhouten =
        OpmetingRaamKleinhoutHelper.herkoppelKleinhoutenNaVlakWijziging(
          oudeVulvlakken: oudeVulvlakken,
          nieuweVulvlakken: nieuweVulvlakken,
          bestaandeKleinhouten: bestaandeKleinhouten,
          nieuweGevuldeVlakIds: nieuweGevuldeVlakIds,
        );

    return OpmetingRaamTStijlVerplaatsingActieResultaat(
      gewijzigd: true,
      foutmelding: null,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(
        verplaatsResultaat.tStijlen,
      ),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(
        verplaatsResultaat.vleugels,
      ),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        verplaatsResultaat.vullingToewijzingen,
      ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(nieuweKleinhouten),
    );
  }

  static OpmetingRaamTStijlVerplaatsingActieResultaat _ongewijzigd({
    String? foutmelding,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    return OpmetingRaamTStijlVerplaatsingActieResultaat(
      gewijzigd: false,
      foutmelding: foutmelding,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(tStijlen),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(vleugels),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        vullingToewijzingen,
      ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(kleinhouten),
    );
  }
}
