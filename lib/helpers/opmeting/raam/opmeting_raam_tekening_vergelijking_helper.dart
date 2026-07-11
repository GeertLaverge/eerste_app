import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';

class OpmetingRaamTekeningVergelijkingHelper {
  const OpmetingRaamTekeningVergelijkingHelper._();

  static bool zelfdeVullingToewijzingen(
    List<OpmetingRaamVullingToewijzing> eerste,
    List<OpmetingRaamVullingToewijzing> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.vlakId != tweedeItem.vlakId ||
          eersteItem.werkvlakId != tweedeItem.werkvlakId ||
          eersteItem.opvullingId != tweedeItem.opvullingId ||
          eersteItem.naam != tweedeItem.naam ||
          eersteItem.kleurWaarde != tweedeItem.kleurWaarde ||
          eersteItem.transparantie != tweedeItem.transparantie) {
        return false;
      }
    }

    return true;
  }

  static bool zelfdeKleinhouten(
    List<OpmetingRaamKleinhout> eerste,
    List<OpmetingRaamKleinhout> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.id != tweedeItem.id ||
          eersteItem.vlakId != tweedeItem.vlakId ||
          eersteItem.werkvlakId != tweedeItem.werkvlakId ||
          eersteItem.type != tweedeItem.type ||
          eersteItem.patroon != tweedeItem.patroon ||
          eersteItem.effectiefAantalHorizontaal !=
              tweedeItem.effectiefAantalHorizontaal ||
          eersteItem.effectiefAantalVerticaal !=
              tweedeItem.effectiefAantalVerticaal ||
          eersteItem.horizontaleHoogteMm != tweedeItem.horizontaleHoogteMm ||
          eersteItem.breedteMm != tweedeItem.breedteMm) {
        return false;
      }
    }

    return true;
  }
}
