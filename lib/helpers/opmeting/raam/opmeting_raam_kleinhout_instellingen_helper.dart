import 'opmeting_raam_kleinhout_invoer_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';

class OpmetingRaamKleinhoutInstellingenResultaat {
  const OpmetingRaamKleinhoutInstellingenResultaat({
    required this.type,
    required this.patroon,
    required this.aantalHorizontaalTekst,
    required this.aantalVerticaalTekst,
    required this.horizontaleHoogteTekst,
  });

  final OpmetingRaamKleinhoutType type;
  final OpmetingRaamKleinhoutPatroon patroon;

  final String aantalHorizontaalTekst;
  final String aantalVerticaalTekst;
  final String horizontaleHoogteTekst;
}

class OpmetingRaamKleinhoutInstellingenHelper {
  const OpmetingRaamKleinhoutInstellingenHelper._();

  static OpmetingRaamKleinhoutInstellingenResultaat? laadVoorVlak({
    required String vlakId,
    required List<OpmetingRaamKleinhout> kleinhouten,
  }) {
    OpmetingRaamKleinhout? bestaand;

    for (final kleinhout in kleinhouten) {
      if (kleinhout.vlakId == vlakId) {
        bestaand = kleinhout;
        break;
      }
    }

    if (bestaand == null) {
      return null;
    }

    return OpmetingRaamKleinhoutInstellingenResultaat(
      type: bestaand.type,
      patroon: bestaand.patroon,
      aantalHorizontaalTekst: bestaand.effectiefAantalHorizontaal.toString(),
      aantalVerticaalTekst: bestaand.effectiefAantalVerticaal.toString(),
      horizontaleHoogteTekst: bestaand.horizontaleHoogteMm == null
          ? ''
          : OpmetingRaamKleinhoutInvoerHelper.formatteerMaat(
              bestaand.horizontaleHoogteMm!,
            ),
    );
  }
}
