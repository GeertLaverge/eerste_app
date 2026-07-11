import 'opmeting_raam_kleinhout_model.dart';

class OpmetingRaamKleinhoutInvoerResultaat {
  const OpmetingRaamKleinhoutInvoerResultaat({
    required this.aantalHorizontaal,
    required this.aantalVerticaal,
    required this.horizontaleHoogteMm,
    required this.foutmelding,
  });

  final int aantalHorizontaal;
  final int aantalVerticaal;
  final double? horizontaleHoogteMm;
  final String? foutmelding;

  bool get isGeldig {
    return foutmelding == null;
  }
}

class OpmetingRaamKleinhoutInvoerHelper {
  const OpmetingRaamKleinhoutInvoerHelper._();

  static OpmetingRaamKleinhoutInvoerResultaat verwerk({
    required OpmetingRaamKleinhoutPatroon patroon,
    required String aantalHorizontaalTekst,
    required String aantalVerticaalTekst,
    required String horizontaleHoogteTekst,
    required double? maximaleHoogteMm,
  }) {
    final aantalHorizontaal = int.tryParse(aantalHorizontaalTekst.trim()) ?? 0;

    final aantalVerticaal = int.tryParse(aantalVerticaalTekst.trim()) ?? 0;

    if (aantalHorizontaal < 0 || aantalVerticaal < 0) {
      return OpmetingRaamKleinhoutInvoerResultaat(
        aantalHorizontaal: aantalHorizontaal,
        aantalVerticaal: aantalVerticaal,
        horizontaleHoogteMm: null,
        foutmelding: 'Het aantal kleinhouten kan niet negatief zijn.',
      );
    }

    if (patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling) {
      final horizontaleHoogteMm = double.tryParse(
        horizontaleHoogteTekst.trim().replaceAll(',', '.'),
      );

      if (horizontaleHoogteMm == null || horizontaleHoogteMm <= 0) {
        return OpmetingRaamKleinhoutInvoerResultaat(
          aantalHorizontaal: aantalHorizontaal,
          aantalVerticaal: aantalVerticaal,
          horizontaleHoogteMm: horizontaleHoogteMm,
          foutmelding:
              'Vul een geldige hoogte in voor het horizontale kleinhout.',
        );
      }

      if (maximaleHoogteMm != null && horizontaleHoogteMm >= maximaleHoogteMm) {
        return OpmetingRaamKleinhoutInvoerResultaat(
          aantalHorizontaal: aantalHorizontaal,
          aantalVerticaal: aantalVerticaal,
          horizontaleHoogteMm: horizontaleHoogteMm,
          foutmelding:
              'De hoogte van het horizontale kleinhout moet kleiner zijn dan de hoogte van het glasvlak.',
        );
      }

      return OpmetingRaamKleinhoutInvoerResultaat(
        aantalHorizontaal: aantalHorizontaal,
        aantalVerticaal: aantalVerticaal,
        horizontaleHoogteMm: horizontaleHoogteMm,
        foutmelding: null,
      );
    }

    if (aantalHorizontaal <= 0 && aantalVerticaal <= 0) {
      return OpmetingRaamKleinhoutInvoerResultaat(
        aantalHorizontaal: aantalHorizontaal,
        aantalVerticaal: aantalVerticaal,
        horizontaleHoogteMm: null,
        foutmelding: 'Vul minstens één horizontaal of verticaal kleinhout in.',
      );
    }

    return OpmetingRaamKleinhoutInvoerResultaat(
      aantalHorizontaal: aantalHorizontaal,
      aantalVerticaal: aantalVerticaal,
      horizontaleHoogteMm: null,
      foutmelding: null,
    );
  }

  static String formatteerMaat(double waarde) {
    if (waarde == waarde.roundToDouble()) {
      return waarde.round().toString();
    }

    return waarde.toStringAsFixed(1);
  }
}
