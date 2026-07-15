import 'opmeting_deurpaneel_model.dart';

class OpmetingDeurpaneelFilterHelper {
  const OpmetingDeurpaneelFilterHelper._();

  static List<OpmetingDeurpaneel> filterVoorKeuze({
    required Iterable<OpmetingDeurpaneel> panelen,
    required OpmetingDeurpaneelUitvoering uitvoering,
    required String zoekTekst,
    bool toonInactievePanelen = false,
  }) {
    final zoek = zoekTekst.trim().toLowerCase();

    final resultaat = panelen.where((paneel) {
      if (!toonInactievePanelen && !paneel.actief) {
        return false;
      }

      if (!paneel.isToegelatenVoor(uitvoering)) {
        return false;
      }

      if (zoek.isEmpty) {
        return true;
      }

      return paneel.zoekTekst.contains(zoek);
    }).toList();

    resultaat.sort(_vergelijkPanelen);

    return resultaat;
  }

  static List<OpmetingDeurpaneel> filterVoorBeheer({
    required Iterable<OpmetingDeurpaneel> panelen,
    required String zoekTekst,
    bool toonInactievePanelen = true,
  }) {
    final zoek = zoekTekst.trim().toLowerCase();

    final resultaat = panelen.where((paneel) {
      if (!toonInactievePanelen && !paneel.actief) {
        return false;
      }

      if (zoek.isEmpty) {
        return true;
      }

      return paneel.zoekTekst.contains(zoek);
    }).toList();

    resultaat.sort(_vergelijkPanelen);

    return resultaat;
  }

  static int _vergelijkPanelen(
    OpmetingDeurpaneel eerste,
    OpmetingDeurpaneel tweede,
  ) {
    final naamVergelijking = eerste.naam.toLowerCase().compareTo(
      tweede.naam.toLowerCase(),
    );

    if (naamVergelijking != 0) {
      return naamVergelijking;
    }

    return eerste.id.toLowerCase().compareTo(tweede.id.toLowerCase());
  }
}
