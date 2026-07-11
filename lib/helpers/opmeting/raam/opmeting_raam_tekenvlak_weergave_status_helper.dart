import 'dart:ui';

import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_kleinhout_selectie_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_actie_helper.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTekenvlakWeergaveStatus {
  const OpmetingRaamTekenvlakWeergaveStatus({
    required this.gevuldeVlakIds,
    required this.bestaandeTStijlGeselecteerd,
    required this.kleinhoutSelectieIsVolledigGevuld,
    required this.kleinhoutSelectieHeeftKleinhouten,
    required this.alleenVerplaatsenVoorGeselecteerdeTStijl,
    required this.totaalAantalGevuldeVlakken,
  });

  final Set<String> gevuldeVlakIds;

  final bool bestaandeTStijlGeselecteerd;
  final bool kleinhoutSelectieIsVolledigGevuld;
  final bool kleinhoutSelectieHeeftKleinhouten;
  final bool alleenVerplaatsenVoorGeselecteerdeTStijl;

  final int totaalAantalGevuldeVlakken;
}

class OpmetingRaamTekenvlakWeergaveStatusHelper {
  const OpmetingRaamTekenvlakWeergaveStatusHelper._();

  static OpmetingRaamTekenvlakWeergaveStatus bereken({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingRaamLijn? geselecteerdeLijn,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    required Set<String> geselecteerdeKleinhoutVlakIds,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    final gevuldeVlakIds = vullingToewijzingen
        .map((toewijzing) => toewijzing.vlakId)
        .toSet();

    final bestaandeTStijlGeselecteerd = (geselecteerdeLijn?.id ?? '')
        .startsWith('tstijl_');

    final kleinhoutSelectieIsVolledigGevuld =
        OpmetingRaamKleinhoutSelectieHelper.selectieIsVolledigGevuld(
          geselecteerdeVlakIds: geselecteerdeKleinhoutVlakIds,
          gevuldeVlakIds: gevuldeVlakIds,
        );

    final kleinhoutSelectieHeeftKleinhouten =
        OpmetingRaamKleinhoutSelectieHelper.selectieHeeftKleinhouten(
          geselecteerdeVlakIds: geselecteerdeKleinhoutVlakIds,
          kleinhouten: kleinhouten,
        );

    final alleenVerplaatsenVoorGeselecteerdeTStijl =
        bestaandeTStijlGeselecteerd &&
        OpmetingRaamTStijlActieHelper.heeftVleugelsLangsBeideZijden(
          geselecteerdeLijn: geselecteerdeLijn,
          tekenvlakGrootte: tekenvlakGrootte,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          tStijlen: tStijlen,
          vleugels: vleugels,
        );

    final totaalAantalGevuldeVlakken = vulvlakken
        .where((vlak) => gevuldeVlakIds.contains(vlak.id))
        .length;

    return OpmetingRaamTekenvlakWeergaveStatus(
      gevuldeVlakIds: Set<String>.unmodifiable(gevuldeVlakIds),
      bestaandeTStijlGeselecteerd: bestaandeTStijlGeselecteerd,
      kleinhoutSelectieIsVolledigGevuld: kleinhoutSelectieIsVolledigGevuld,
      kleinhoutSelectieHeeftKleinhouten: kleinhoutSelectieHeeftKleinhouten,
      alleenVerplaatsenVoorGeselecteerdeTStijl:
          alleenVerplaatsenVoorGeselecteerdeTStijl,
      totaalAantalGevuldeVlakken: totaalAantalGevuldeVlakken,
    );
  }
}
