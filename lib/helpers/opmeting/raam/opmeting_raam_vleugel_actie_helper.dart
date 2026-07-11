import 'dart:ui';

import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tekening_opschoning_helper.dart';
import 'opmeting_raam_tekenvlak_acties.dart';

class OpmetingRaamVleugelActieResultaat {
  const OpmetingRaamVleugelActieResultaat({
    required this.gewijzigd,
    required this.tStijlen,
    required this.vleugels,
    required this.vullingToewijzingen,
    required this.kleinhouten,
    required this.geselecteerdeVulvlakIds,
    required this.geselecteerdeKleinhoutVlakIds,
  });

  final bool gewijzigd;

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;
  final List<OpmetingRaamKleinhout> kleinhouten;

  final Set<String> geselecteerdeVulvlakIds;
  final Set<String> geselecteerdeKleinhoutVlakIds;
}

class OpmetingRaamVleugelActieHelper {
  const OpmetingRaamVleugelActieHelper._();

  static OpmetingRaamVleugelActieResultaat pasToe({
    required Offset punt,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingRaamVleugelType geselecteerdVleugelType,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
    required List<OpmetingRaamVullingToewijzing> bestaandeVullingToewijzingen,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
  }) {
    final vleugelResultaat = OpmetingRaamTekenvlakActies.pasVleugelToe(
      punt: punt,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      geselecteerdVleugelType: geselecteerdVleugelType,
      bestaandeTStijlen: bestaandeTStijlen,
      bestaandeVleugels: bestaandeVleugels,
    );

    if (!vleugelResultaat.gewijzigd) {
      return OpmetingRaamVleugelActieResultaat(
        gewijzigd: false,
        tStijlen: List<OpmetingRaamTStijl>.unmodifiable(bestaandeTStijlen),
        vleugels: List<OpmetingRaamVleugel>.unmodifiable(bestaandeVleugels),
        vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
          bestaandeVullingToewijzingen,
        ),
        kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(
          bestaandeKleinhouten,
        ),
        geselecteerdeVulvlakIds: const <String>{},
        geselecteerdeKleinhoutVlakIds: const <String>{},
      );
    }

    final nieuweVulvlakken = OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: vleugelResultaat.tStijlen,
      vleugels: vleugelResultaat.vleugels,
    );

    final opschoningResultaat =
        OpmetingRaamTekeningOpschoningHelper.schoonAllesOp(
          huidigeVulvlakken: nieuweVulvlakken,
          bestaandeVullingToewijzingen: bestaandeVullingToewijzingen,
          geselecteerdeVulvlakIds: const <String>{},
          bestaandeKleinhouten: bestaandeKleinhouten,
          geselecteerdeKleinhoutVlakIds: const <String>{},
        );

    return OpmetingRaamVleugelActieResultaat(
      gewijzigd: true,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(
        vleugelResultaat.tStijlen,
      ),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(
        vleugelResultaat.vleugels,
      ),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        opschoningResultaat.vullingToewijzingen,
      ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(
        opschoningResultaat.kleinhouten,
      ),
      geselecteerdeVulvlakIds: Set<String>.unmodifiable(
        opschoningResultaat.geselecteerdeVulvlakIds,
      ),
      geselecteerdeKleinhoutVlakIds: Set<String>.unmodifiable(
        opschoningResultaat.geselecteerdeKleinhoutVlakIds,
      ),
    );
  }
}
