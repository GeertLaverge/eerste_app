import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_schaal_controller.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_tekenvlak_maat_wijziging.dart';
import 'opmeting_raam_vulling_herkoppeling_helper.dart';

class OpmetingRaamSchaalAanpassingResultaat {
  const OpmetingRaamSchaalAanpassingResultaat({
    required this.tStijlen,
    required this.vleugels,
    required this.vullingToewijzingen,
    required this.kleinhouten,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;

  final List<OpmetingRaamKleinhout> kleinhouten;
}

class OpmetingRaamSchaalAanpassingHelper {
  const OpmetingRaamSchaalAanpassingHelper._();

  static OpmetingRaamSchaalAanpassingResultaat? bereken({
    required OpmetingRaamSchaalWijziging wijziging,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
    required List<OpmetingRaamVullingToewijzing> bestaandeVullingToewijzingen,
    required List<OpmetingRaamKleinhout> bestaandeKleinhouten,
  }) {
    final oudeBreedteMm = wijziging.oudeBreedteMm;
    final oudeHoogteMm = wijziging.oudeHoogteMm;

    final nieuweBreedteMm = wijziging.nieuweBreedteMm;
    final nieuweHoogteMm = wijziging.nieuweHoogteMm;

    if (oudeBreedteMm <= 0 ||
        oudeHoogteMm <= 0 ||
        nieuweBreedteMm <= 0 ||
        nieuweHoogteMm <= 0) {
      return null;
    }

    final minimaleKaderMaatMm = OpmetingRaamKaderHelper.kaderOffsetMm * 2;

    if (nieuweBreedteMm <= minimaleKaderMaatMm ||
        nieuweHoogteMm <= minimaleKaderMaatMm) {
      return null;
    }

    final tStijlen = List<OpmetingRaamTStijl>.from(bestaandeTStijlen);

    final vleugels = List<OpmetingRaamVleugel>.from(bestaandeVleugels);

    final vullingToewijzingen = List<OpmetingRaamVullingToewijzing>.from(
      bestaandeVullingToewijzingen,
    );

    final kleinhouten = List<OpmetingRaamKleinhout>.from(bestaandeKleinhouten);

    final oudeVulvlakken = OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: wijziging.oudeTekenvlakGrootte,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
      tStijlen: tStijlen,
      vleugels: vleugels,
    );

    final maatResultaat =
        OpmetingRaamTekenvlakMaatWijziging.pasTekeningAanNieuwBlok(
          oudeTekenvlakGrootte: wijziging.oudeTekenvlakGrootte,
          nieuweTekenvlakGrootte: wijziging.nieuweTekenvlakGrootte,
          oudeBreedteMm: oudeBreedteMm,
          oudeHoogteMm: oudeHoogteMm,
          nieuweBreedteMm: nieuweBreedteMm,
          nieuweHoogteMm: nieuweHoogteMm,
          bestaandeTStijlen: tStijlen,
          bestaandeVleugels: vleugels,
        );

    if (maatResultaat == null) {
      return null;
    }

    final nieuweVulvlakken = OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: wijziging.nieuweTekenvlakGrootte,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
      tStijlen: maatResultaat.tStijlen,
      vleugels: maatResultaat.vleugels,
    );

    if (vullingToewijzingen.isNotEmpty && nieuweVulvlakken.isEmpty) {
      return null;
    }

    final oudeBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: wijziging.oudeTekenvlakGrootte,
      breedteMm: oudeBreedteMm,
      hoogteMm: oudeHoogteMm,
    );

    final nieuweBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: wijziging.nieuweTekenvlakGrootte,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
    );

    final nieuweVullingToewijzingen =
        OpmetingRaamVullingHerkoppelingHelper.herkoppelNaVlakWijziging(
          oudeVulvlakken: oudeVulvlakken,
          nieuweVulvlakken: nieuweVulvlakken,
          bestaandeToewijzingen: vullingToewijzingen,
          oudeReferentie: oudeBuitenKader,
          nieuweReferentie: nieuweBuitenKader,
        );

    if (nieuweVullingToewijzingen.length != vullingToewijzingen.length) {
      return null;
    }

    final nieuweGevuldeVlakIds = nieuweVullingToewijzingen
        .map((toewijzing) => toewijzing.vlakId)
        .toSet();

    final nieuweKleinhouten =
        OpmetingRaamKleinhoutHelper.herkoppelKleinhoutenNaVlakWijziging(
          oudeVulvlakken: oudeVulvlakken,
          nieuweVulvlakken: nieuweVulvlakken,
          bestaandeKleinhouten: kleinhouten,
          nieuweGevuldeVlakIds: nieuweGevuldeVlakIds,
        );

    if (nieuweKleinhouten.length != kleinhouten.length) {
      return null;
    }

    return OpmetingRaamSchaalAanpassingResultaat(
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(maatResultaat.tStijlen),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(maatResultaat.vleugels),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        nieuweVullingToewijzingen,
      ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(nieuweKleinhouten),
    );
  }
}
