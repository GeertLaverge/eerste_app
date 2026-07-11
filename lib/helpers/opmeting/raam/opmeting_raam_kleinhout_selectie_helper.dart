import 'dart:ui';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamKleinhoutSelectieHelper {
  const OpmetingRaamKleinhoutSelectieHelper._();

  static bool selectieHeeftKleinhouten({
    required Set<String> geselecteerdeVlakIds,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    return geselecteerdeVlakIds.any(
      (vlakId) => kleinhouten.any((kleinhout) => kleinhout.vlakId == vlakId),
    );
  }

  static bool selectieIsVolledigGevuld({
    required Set<String> geselecteerdeVlakIds,
    required Set<String> gevuldeVlakIds,
  }) {
    if (geselecteerdeVlakIds.isEmpty) {
      return false;
    }

    return geselecteerdeVlakIds.every(gevuldeVlakIds.contains);
  }

  static double? kleinsteGeselecteerdeVlakHoogteMm({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> geselecteerdeVlakIds,
  }) {
    if (hoogteMm <= 0) {
      return null;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    if (buitenKader.height <= 0) {
      return null;
    }

    final pixelsPerMm = buitenKader.height / hoogteMm;

    if (pixelsPerMm <= 0) {
      return null;
    }

    double? kleinsteHoogteMm;

    for (final vlak in vulvlakken) {
      if (!geselecteerdeVlakIds.contains(vlak.id)) {
        continue;
      }

      final vlakHoogteMm = vlak.vlak.height / pixelsPerMm;

      if (kleinsteHoogteMm == null || vlakHoogteMm < kleinsteHoogteMm) {
        kleinsteHoogteMm = vlakHoogteMm;
      }
    }

    return kleinsteHoogteMm;
  }
}
