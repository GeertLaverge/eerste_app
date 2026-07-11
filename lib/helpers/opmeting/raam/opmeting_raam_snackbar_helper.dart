import 'package:flutter/material.dart';

class OpmetingRaamSnackBarHelper {
  const OpmetingRaamSnackBarHelper._();

  static bool toonFoutIndienAanwezig(BuildContext context, String? melding) {
    final tekst = melding?.trim();

    if (tekst == null || tekst.isEmpty) {
      return false;
    }

    toonFout(context, tekst);

    return true;
  }

  static void toonFout(BuildContext context, String melding) {
    _toon(
      context: context,
      melding: melding,
      achtergrondkleur: const Color(0xFFDC2626),
    );
  }

  static void toonWaarschuwing(BuildContext context, String melding) {
    _toon(
      context: context,
      melding: melding,
      achtergrondkleur: const Color(0xFFB45309),
    );
  }

  static void _toon({
    required BuildContext context,
    required String melding,
    required Color achtergrondkleur,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(melding), backgroundColor: achtergrondkleur),
    );
  }
}
