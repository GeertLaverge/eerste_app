import 'dart:ui';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamVulvlakBerekeningHelper {
  const OpmetingRaamVulvlakBerekeningHelper._();

  static List<OpmetingRaamVulvlak> bereken({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    final vulvlakken = OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: tStijlen,
      vleugels: vleugels,
    );

    return List<OpmetingRaamVulvlak>.unmodifiable(vulvlakken);
  }
}
